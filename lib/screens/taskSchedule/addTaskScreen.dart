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
    final timeSlot = SurveyAnalyzer.getRecommendedTimeSlot(
      widget.preferences.preferredTimeSlot,
    );
    
    // Use the selected date instead of widget.selectedDate
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

  // ADD THIS: Date picker function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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