import 'package:hive/hive.dart';
import '../models/taskModel.dart';

class TaskController {
  static const String boxName = "tasksBox";

  Future<Box<TaskModel>> openBox() async {
    return await Hive.openBox<TaskModel>(boxName);
  }

  // Create new task
  Future<void> addTask(TaskModel task) async {
    final box = await openBox();
    await box.put(task.id, task);
  }

  // Get all tasks
  Future<List<TaskModel>> getAllTasks() async {
    final box = await openBox();
    return box.values.toList();
  }

  // Get tasks for specific date
  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    final box = await openBox();
    return box.values.where((task) {
      return task.startTime.year == date.year &&
          task.startTime.month == date.month &&
          task.startTime.day == date.day;
    }).toList();
  }

  // Get today's tasks
  Future<List<TaskModel>> getTodayTasks() async {
    return await getTasksForDate(DateTime.now());
  }

  // Get upcoming tasks
  Future<List<TaskModel>> getUpcomingTasks() async {
    final box = await openBox();
    final now = DateTime.now();
    return box.values.where((task) {
      return task.startTime.isAfter(now) && !task.isCompleted;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get overdue tasks
  Future<List<TaskModel>> getOverdueTasks() async {
    final box = await openBox();
    final now = DateTime.now();
    return box.values.where((task) {
      return task.endTime.isBefore(now) && !task.isCompleted;
    }).toList();
  }

  // Update task
  Future<void> updateTask(TaskModel task) async {
    await task.save();
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId) async {
    final box = await openBox();
    final task = box.get(taskId);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await task.save();
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    final box = await openBox();
    await box.delete(taskId);
  }

  // Get task count for date
  Future<int> getTaskCountForDate(DateTime date) async {
    final tasks = await getTasksForDate(date);
    return tasks.length;
  }

  // Get completed task count for date
  Future<int> getCompletedTaskCountForDate(DateTime date) async {
    final tasks = await getTasksForDate(date);
    return tasks.where((task) => task.isCompleted).length;
  }

  // Clear all tasks (for testing)
  Future<void> clearAllTasks() async {
    final box = await openBox();
    await box.clear();
  }

  // Get task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    final box = await openBox();
    return box.get(taskId);
  }

  // Get completion rate for today
  Future<double> getTodayCompletionRate() async {
    final tasks = await getTodayTasks();
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((t) => t.isCompleted).length;
    return (completed / tasks.length) * 100;
  }
}