// import 'package:flutter/material.dart';
// import 'package:research_driven_time_scheduler_mobile_app/controllers/taskController.dart';
// import 'package:research_driven_time_scheduler_mobile_app/models/taskModel.dart';

// class EditTaskPage extends StatefulWidget {
//   final TaskModel task;
  
//   const EditTaskPage({super.key, required this.task});

//   @override
//   State<EditTaskPage> createState() => _EditTaskPageState();
// }

// class _EditTaskPageState extends State<EditTaskPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _titleController;
//   late TextEditingController _descriptionController;
//   final TaskController _taskController = TaskController();

//   late DateTime _selectedDate;
//   late TimeOfDay _startTime;
//   late TimeOfDay _endTime;
//   late String _selectedPriority;
//   late String _selectedCategory;
//   late bool _enableNotification;
//   TimeOfDay? _notificationTime;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.task.title);
//     _descriptionController = TextEditingController(text: widget.task.description);
//     _selectedDate = widget.task.startTime;
//     _startTime = TimeOfDay.fromDateTime(widget.task.startTime);
//     _endTime = TimeOfDay.fromDateTime(widget.task.endTime);
//     _selectedPriority = widget.task.priority;
//     _selectedCategory = widget.task.category;
//     _enableNotification = widget.task.hasNotification;
//     if (widget.task.notificationTime != null) {
//       _notificationTime = TimeOfDay.fromDateTime(widget.task.notificationTime!);
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null) {
//       setState(() => _selectedDate = picked);
//     }
//   }

//   Future<void> _selectStartTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: _startTime,
//     );
//     if (picked != null) {
//       setState(() => _startTime = picked);
//     }
//   }

//   Future<void> _selectEndTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: _endTime,
//     );
//     if (picked != null) {
//       setState(() => _endTime = picked);
//     }
//   }

//   Future<void> _selectNotificationTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: _notificationTime ?? _startTime,
//     );
//     if (picked != null) {
//       setState(() => _notificationTime = picked);
//     }
//   }

//   Future<void> _updateTask() async {
//     if (_formKey.currentState!.validate()) {
//       final startDateTime = DateTime(
//         _selectedDate.year,
//         _selectedDate.month,
//         _selectedDate.day,
//         _startTime.hour,
//         _startTime.minute,
//       );

//       final endDateTime = DateTime(
//         _selectedDate.year,
//         _selectedDate.month,
//         _selectedDate.day,
//         _endTime.hour,
//         _endTime.minute,
//       );

//       DateTime? notificationDateTime;
//       if (_enableNotification && _notificationTime != null) {
//         notificationDateTime = DateTime(
//           _selectedDate.year,
//           _selectedDate.month,
//           _selectedDate.day,
//           _notificationTime!.hour,
//           _notificationTime!.minute,
//         );
//       }

//       widget.task.title = _titleController.text;
//       widget.task.description = _descriptionController.text;
//       widget.task.startTime = startDateTime;
//       widget.task.endTime = endDateTime;
//       widget.task.priority = _selectedPriority;
//       widget.task.category = _selectedCategory;
//       widget.task.hasNotification = _enableNotification;
//       widget.task.notificationTime = notificationDateTime;

//       await _taskController.updateTask(widget.task);
      
//       if (mounted) {
//         Navigator.pop(context, true);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Task updated successfully!')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Task'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Colors.white,
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             // Title
//             TextFormField(
//               controller: _titleController,
//               decoration: InputDecoration(
//                 labelText: 'Task Title',
//                 prefixIcon: const Icon(Icons.title),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter a title';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),

//             // Description
//             TextFormField(
//               controller: _descriptionController,
//               decoration: InputDecoration(
//                 labelText: 'Description',
//                 prefixIcon: const Icon(Icons.description),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               maxLines: 3,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter a description';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),

//             // Date
//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.calendar_today),
//                 title: const Text('Date'),
//                 subtitle: Text(
//                   '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
//                 ),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: _selectDate,
//               ),
//             ),
//             const SizedBox(height: 8),

//             // Time
//             Row(
//               children: [
//                 Expanded(
//                   child: Card(
//                     child: ListTile(
//                       leading: const Icon(Icons.access_time),
//                       title: const Text('Start'),
//                       subtitle: Text(_startTime.format(context)),
//                       onTap: _selectStartTime,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Card(
//                     child: ListTile(
//                       leading: const Icon(Icons.access_time),
//                       title: const Text('End'),
//                       subtitle: Text(_endTime.format(context)),
//                       onTap: _selectEndTime,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Priority
//             const Text(
//               'Priority',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               children: [
//                 ChoiceChip(
//                   label: const Text('Low'),
//                   selected: _selectedPriority == 'low',
//                   onSelected: (selected) {
//                     setState(() => _selectedPriority = 'low');
//                   },
//                   selectedColor: Colors.green.withOpacity(0.3),
//                 ),
//                 ChoiceChip(
//                   label: const Text('Medium'),
//                   selected: _selectedPriority == 'medium',
//                   onSelected: (selected) {
//                     setState(() => _selectedPriority = 'medium');
//                   },
//                   selectedColor: Colors.orange.withOpacity(0.3),
//                 ),
//                 ChoiceChip(
//                   label: const Text('High'),
//                   selected: _selectedPriority == 'high',
//                   onSelected: (selected) {
//                     setState(() => _selectedPriority = 'high');
//                   },
//                   selectedColor: Colors.red.withOpacity(0.3),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Category
//             const Text(
//               'Category',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               children: [
//                 ChoiceChip(
//                   label: const Text('Personal'),
//                   selected: _selectedCategory == 'personal',
//                   onSelected: (selected) {
//                     setState(() => _selectedCategory = 'personal');
//                   },
//                 ),
//                 ChoiceChip(
//                   label: const Text('Work'),
//                   selected: _selectedCategory == 'work',
//                   onSelected: (selected) {
//                     setState(() => _selectedCategory = 'work');
//                   },
//                 ),
//                 ChoiceChip(
//                   label: const Text('Study'),
//                   selected: _selectedCategory == 'study',
//                   onSelected: (selected) {
//                     setState(() => _selectedCategory = 'study');
//                   },
//                 ),
//                 ChoiceChip(
//                   label: const Text('Health'),
//                   selected: _selectedCategory == 'health',
//                   onSelected: (selected) {
//                     setState(() => _selectedCategory = 'health');
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Notification
//             Card(
//               child: SwitchListTile(
//                 title: const Text('Enable Notification'),
//                 subtitle: _enableNotification && _notificationTime != null
//                     ? Text('Reminder at ${_notificationTime!.format(context)}')
//                     : const Text('Get reminded before task starts'),
//                 value: _enableNotification,
//                 onChanged: (value) {
//                   setState(() => _enableNotification = value);
//                   if (value && _notificationTime == null) {
//                     _selectNotificationTime();
//                   }
//                 },
//                 secondary: const Icon(Icons.notifications),
//               ),
//             ),
//             if (_enableNotification) ...[
//               const SizedBox(height: 8),
//               OutlinedButton.icon(
//                 onPressed: _selectNotificationTime,
//                 icon: const Icon(Icons.alarm),
//                 label: Text(
//                   _notificationTime != null
//                       ? 'Change notification time'
//                       : 'Set notification time',
//                 ),
//               ),
//             ],
//             const SizedBox(height: 24),

//             // Update Button
//             ElevatedButton(
//               onPressed: _updateTask,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).colorScheme.primary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Update Task',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }