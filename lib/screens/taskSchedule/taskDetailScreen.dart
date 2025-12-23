import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/taskModel.dart';
import '../../controllers/taskController.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskController taskController = TaskController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.task.isCompleted
                        ? Colors.green
                        : widget.task.isOverdue
                            ? Colors.red
                            : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.task.isCompleted
                        ? 'Completed'
                        : widget.task.isOverdue
                            ? 'Overdue'
                            : 'Pending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.task.priorityLabel} Priority',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              widget.task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Category
            _buildInfoRow(
              Icons.category,
              'Category',
              widget.task.category,
            ),
            const SizedBox(height: 10),

            // Date
            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              DateFormat('EEEE, MMMM d, y').format(widget.task.startTime),
            ),
            const SizedBox(height: 10),

            // Time
            _buildInfoRow(
              Icons.access_time,
              'Time',
              '${DateFormat('hh:mm a').format(widget.task.startTime)} - '
              '${DateFormat('hh:mm a').format(widget.task.endTime)}',
            ),
            const SizedBox(height: 10),

            // Duration
            _buildInfoRow(
              Icons.timer,
              'Duration',
              '${widget.task.durationInMinutes} minutes',
            ),
            const SizedBox(height: 20),

            // Description
            if (widget.task.description.isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.task.description,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Complete Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.task.isCompleted
                      ? Colors.grey
                      : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: widget.task.isCompleted ? null : _completeTask,
                icon: Icon(
                  widget.task.isCompleted ? Icons.check_circle : Icons.check,
                  color: Colors.white,
                ),
                label: Text(
                  widget.task.isCompleted
                      ? 'Task Completed'
                      : 'Mark as Complete',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (widget.task.priority) {
      case 3:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 1:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Future<void> _completeTask() async {
    await taskController.toggleTaskCompletion(widget.task.id);
    
    if (mounted) {
      // Show celebration dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🎉 Great Job!'),
          content: const Text(
            'You\'ve completed this task! Keep up the good work!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await taskController.deleteTask(widget.task.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}