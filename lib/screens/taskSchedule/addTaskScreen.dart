import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/taskModel.dart';
import '../../models/userPreferencesModel.dart';
import '../../controllers/taskController.dart';
import '../../utils/surveyAnalyzer.dart';
import '../../services/notification.dart';

class AddTaskScreen extends StatefulWidget {
  final UserPreferencesModel preferences;
  final DateTime selectedDate;

  const AddTaskScreen({
    super.key,
    required this.preferences,
    required this.selectedDate,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TaskController taskController = TaskController();
  final NotificationService notificationService = NotificationService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  DateTime? startTime;
  DateTime? endTime;
  int priority = 2;
  String category = 'Study';

  final List<String> categories = [
    'Study',
    'Assignment',
    'Project',
    'Reading',
    'Practice',
    'Review',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _setDefaultTimes();
  }

  void _setDefaultTimes() {
    final timeSlot = SurveyAnalyzer.getRecommendedTimeSlot(
      widget.preferences.preferredTimeSlot,
    );
    
    startTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      timeSlot['start']!,
      0,
    );
    
    endTime = startTime!.add(
      Duration(minutes: widget.preferences.recommendedTaskDuration),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartTime ? startTime! : endTime!),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
            widget.selectedDate.day,
            picked.hour,
            picked.minute,
          );
          // Auto-adjust end time
          if (endTime!.isBefore(startTime!)) {
            endTime = startTime!.add(
              Duration(minutes: widget.preferences.recommendedTaskDuration),
            );
          }
        } else {
          endTime = DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
            widget.selectedDate.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

    Future<void> _saveTask() async {
        if (!_formKey.currentState!.validate()) return;
        if (startTime == null || endTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select start and end times')),
          );
          return;
        }

        if (endTime!.isBefore(startTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('End time must be after start time')),
          );
          return;
        }

        if (widget.preferences.scheduleStyle == 'Focus Session') {
          final hasCollision = await _checkForCollision(startTime!, endTime!);
          if (hasCollision) {
            _showCollisionDialog();
            return;
          }
        }

        final task = TaskModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: titleController.text,
          description: descriptionController.text,
          startTime: startTime!,
          endTime: endTime!,
          priority: priority,
          category: category,
          createdAt: DateTime.now(),
        );

        await taskController.addTask(task);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }

      // ✅ NEW: Check if proposed time collides with existing tasks
      Future<bool> _checkForCollision(DateTime proposedStart, DateTime proposedEnd) async {
        final existingTasks = await taskController.getTasksForDate(widget.selectedDate);
        
        for (var task in existingTasks) {
          // Check if times overlap
          // Overlap occurs if: (start1 < end2) AND (start2 < end1)
          if (proposedStart.isBefore(task.endTime) && task.startTime.isBefore(proposedEnd)) {
            return true; // Collision detected
          }
        }
        
        return false; // No collision
      }

      // ✅ NEW: Show dialog when collision is detected
      void _showCollisionDialog() {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 10),
                Text('Time Conflict'),
              ],
            ),
            content: const Text(
              'This time slot conflicts with an existing task. '
              'Focus Session mode requires non-overlapping tasks.\n\n'
              'Please choose a different time.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _suggestNextAvailableTime();
                },
                child: const Text('Suggest Time'),
              ),
            ],
          ),
        );
      }

      // ✅ NEW: Suggest next available time slot
      Future<void> _suggestNextAvailableTime() async {
        final existingTasks = await taskController.getTasksForDate(widget.selectedDate);
        
        if (existingTasks.isEmpty) return;
        
        // Sort tasks by start time
        existingTasks.sort((a, b) => a.startTime.compareTo(b.startTime));
        
        // Find the latest end time
        DateTime latestEnd = existingTasks.last.endTime;
        
        // Suggest starting after the last task
        DateTime suggestedStart = latestEnd;
        DateTime suggestedEnd = suggestedStart.add(
          Duration(minutes: widget.preferences.recommendedTaskDuration),
        );
        
        setState(() {
          startTime = suggestedStart;
          endTime = suggestedEnd;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Suggested time: ${_formatTime(suggestedStart)} - ${_formatTime(suggestedEnd)}',
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      String _formatTime(DateTime time) {
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Task', style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),),
        backgroundColor: Color(0xFFD9D9D9),
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"), 
          fit: BoxFit.cover, 
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personality tip
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.preferences.getOverwhelmed
                            ? 'Keep tasks under ${widget.preferences.recommendedTaskDuration} minutes!'
                            : 'Recommended duration: ${widget.preferences.recommendedTaskDuration} min',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Description
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  labelStyle: TextStyle(fontSize: 16, fontFamily: 'Montserrat')
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 15),

              // Category
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    category = value!;
                  });
                },
              ),
              const SizedBox(height: 15),

              // Priority
              const Text('Priority', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip('Low', 1),
                  const SizedBox(width: 10),
                  _buildPriorityChip('Medium', 2),
                  const SizedBox(width: 10),
                  _buildPriorityChip('High', 3),
                ],
              ),
              const SizedBox(height: 20),

              // Start Time
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(DateFormat('hh:mm a').format(startTime!)),
                leading: const Icon(Icons.access_time),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onTap: () => _selectTime(context, true),
              ),
              const SizedBox(height: 10),

              // End Time
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(DateFormat('hh:mm a').format(endTime!)),
                leading: const Icon(Icons.access_time),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onTap: () => _selectTime(context, false),
              ),
              const SizedBox(height: 10),

              // Duration display
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(113, 245, 245, 245),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${endTime!.difference(startTime!).inMinutes} minutes',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _saveTask,
                  child: const Text(
                    'Save Task',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildPriorityChip(String label, int value) {
    final isSelected = priority == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          priority = value;
        });
      },
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  

}

