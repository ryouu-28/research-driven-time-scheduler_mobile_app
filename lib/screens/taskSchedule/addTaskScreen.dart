import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/taskModel.dart';
import '../../models/userPreferencesModel.dart';
import '../../controllers/taskController.dart';
import '../../utils/surveyAnalyzer.dart';

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
  
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  DateTime? startTime;
  DateTime? endTime;
  int priority = 2;
  String category = 'Study';
  bool scheduleNotification = true;

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
    scheduleNotification = widget.preferences.needsReminders;
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

    try {
      // Add task with optional notification
      await taskController.addTask(task, scheduleNotification: scheduleNotification);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              scheduleNotification
                  ? 'Task added with reminder!'
                  : 'Task added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 15),

              // Category
              DropdownButtonFormField<String>(
                value: category,
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
                  color: Colors.grey.shade100,
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
              const SizedBox(height: 20),

              // Notification toggle
              SwitchListTile(
                title: const Text('Remind me before this task'),
                subtitle: Text(
                  scheduleNotification
                      ? 'You\'ll get a reminder 15 minutes before'
                      : 'No reminder will be scheduled',
                ),
                value: scheduleNotification,
                onChanged: (value) {
                  setState(() {
                    scheduleNotification = value;
                  });
                },
                secondary: const Icon(Icons.notifications_active),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
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
    );
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