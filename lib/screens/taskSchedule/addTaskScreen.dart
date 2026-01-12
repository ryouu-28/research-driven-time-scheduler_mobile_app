import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/taskModel.dart';
import '../../models/userPreferencesModel.dart';
import '../../controllers/taskController.dart';
import '../../services/notification.dart';
import '../../utils/surveyAnalyzer.dart';
import '../../services/smartScheduler.dart';

class AddTaskScreen extends StatefulWidget {
  final UserPreferencesModel preferences;
  final DateTime selectedDate;
  final DateTime? suggestedStart;
    final DateTime? suggestedEnd;
  

  const AddTaskScreen({
    super.key,
    required this.preferences,
    required this.selectedDate,
    this.suggestedStart,
    this.suggestedEnd,
    
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
  
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TaskController taskController = TaskController();
  
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  // ADD THIS: Store selected date separately from time
  late DateTime selectedDate;
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
    // Initialize with the passed date
    selectedDate = widget.selectedDate;
    _setDefaultTimes();
  }

  void _setDefaultTimes() {
  // Use suggested times if provided
  if (widget.suggestedStart != null && widget.suggestedEnd != null) {
    startTime = widget.suggestedStart;
    endTime = widget.suggestedEnd;
    return;
  }

  final timeSlot = SurveyAnalyzer.getRecommendedTimeSlot(
    widget.preferences.preferredTimeSlot,
  );
  
  startTime = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    timeSlot['start']!,
    0,
  );
  
  endTime = startTime!.add(
    Duration(minutes: widget.preferences.recommendedTaskDuration),
  );
}


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Update start and end times with new date
        if (startTime != null) {
          startTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            startTime!.hour,
            startTime!.minute,
          );
        }
        if (endTime != null) {
          endTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            endTime!.hour,
            endTime!.minute,
          );
        }
      });
    }
  }

 String _checkDurationTime() {
      if (endTime!.isBefore(startTime!)) {
        return 'Impossible';
      }
      final duration = endTime!.difference(startTime!).inMinutes;
      return '$duration minutes';
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
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
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
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
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

  final tasksForDay = await taskController.getTasksForDate(selectedDate);
  if (widget.preferences != null &&
      tasksForDay.length >= widget.preferences!.maxDailyTasks) {
    // Show dialog if limit reached
    TaskModel? lowestPriorityTask;
    if (tasksForDay.isNotEmpty) {
      tasksForDay.sort((a, b) => a.priority.compareTo(b.priority));
      lowestPriorityTask = tasksForDay.first;
    }

    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Limit Reached'),
        content: Text(
          'You\'ve reached your daily limit of '
          '${widget.preferences!.maxDailyTasks} tasks for '
          '${DateFormat('MMM d, yyyy').format(selectedDate)}.\n\n'
          'Consider completing existing tasks first!'
          '${lowestPriorityTask != null ? "\n\nLowest priority task: ${lowestPriorityTask.title}" : ""}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          if (lowestPriorityTask != null)
            TextButton(
              onPressed: () async {
                Navigator.pop(context, true);
                await taskController.deleteTask(lowestPriorityTask!.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Removed low priority task: ${lowestPriorityTask.title}",
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text('Remove Low Priority'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add Anyway'),
          ),
        ],
      ),
    );

    if (proceed != true) return; // User cancelled
  }

  if (widget.preferences.scheduleStyle == 'Focus Session') {
    final hasConflict = await taskController.hasTimeConflict(
      startTime!,
      endTime!,
      selectedDate,
    );

    if (hasConflict) {
      final shouldFindSlot = await showDialog<bool>(
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
            'This time slot overlaps with an existing task.\n\n'
            'Focus Session mode prevents overlapping tasks.\n\n'
            'Would you like to find the next available slot?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Find Next Slot'),
            ),
          ],
        ),
      );

      if (shouldFindSlot != true) {
        return; // User cancelled
      }

      // Find next available slot
      final duration = endTime!.difference(startTime!).inMinutes;
      final nextSlot = await taskController.findNextAvailableSlot(
        startTime!,
        duration,
        selectedDate,
      );

      if (nextSlot == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No available time slots found for today'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Update times to next available slot
      setState(() {
        startTime = nextSlot;
        endTime = nextSlot.add(Duration(minutes: duration));
      });

      // Confirm with user
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Suggested Time Slot'),
          content: Text(
            'Next available slot:\n\n'
            '${DateFormat('hh:mm a').format(startTime!)} - '
            '${DateFormat('hh:mm a').format(endTime!)}\n\n'
            'Would you like to use this time?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Use This Slot'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return; // User cancelled
      }
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

  if (widget.preferences.getOverwhelmed && 
      task.durationInMinutes > 30) {
    
    final shouldBreak = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Break Down Task?'),
        content: Text(
          'This task is ${task.durationInMinutes} minutes long.\n\n'
          'Would you like to break it into smaller 30-minute chunks?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep as One'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Break It Down'),
          ),
        ],
      ),
    );

    if (shouldBreak == true) {
      final subtasks = SmartScheduler.breakDownLargeTask(task, widget.preferences);
      
      // Save all subtasks
      for (var subtask in subtasks) {
        await taskController.addTask(subtask);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Created ${subtasks.length} subtasks'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }
  }

  // Save the task
  await taskController.addTask(task);

    final notificationService = NotificationService();
    
    if (widget.preferences.needsReminders) {
      // Schedule start notification
      await notificationService.scheduleNotification(
        task.hashCode,
        '🔔 Task Starting',
        '${task.title} is starting now!',
        task.startTime,
        task.id,
      );

      // Schedule end notification
      await notificationService.scheduleNotification(
        task.hashCode + 1,
        '✅ Task Completed',
        '${task.title} has ended!, Please Mark it as complete in the app.',
        task.endTime,
        task.id,
      );

      print('✅ Scheduled notifications for: ${task.title}');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }


  // if (mounted) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         widget.preferences.scheduleStyle == 'Focus Session'
  //             ? '✅ Task scheduled in focus session!'
  //             : '✅ Task added successfully!',
  //       ),
  //       backgroundColor: Colors.green,
  //     ),
  //   );
  //   Navigator.pop(context);
  // }
}
  
  @override
  Widget build(BuildContext context) {
    final durationTime =_checkDurationTime();
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

              // ADD THIS: Date Picker
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('EEEE, MMMM d, y').format(selectedDate)),
                leading: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 10),

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
                     durationTime,
                      style: TextStyle(fontWeight: FontWeight.w500, color: durationTime == 'Impossible' ? Colors.red : Colors.black),
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