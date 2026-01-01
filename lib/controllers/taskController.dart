import 'package:hive/hive.dart';
import '../models/taskModel.dart';
import '../services/notificationService.dart';

class TaskController {
  static const String boxName = "tasksBox";
  final NotificationService _notificationService = NotificationService();

  Future<Box<Task>> openBox() async {
    return await Hive.openBox<Task>(boxName);
  }

  Future<void> createTask(Task task) async {
    final box = await openBox();
    await box.put(task.id, task);

    if (task.hasNotification && task.notificationTime != null) {
      await scheduleTaskNotification(task);
    }
  }

  Future<void> updateTask(Task task) async {
    final box = await openBox();
    await box.put(task.id, task);

    if (task.hasNotification && task.notificationTime != null) {
      if (task.notificationId != null) {
        await _notificationService.cancelNotification(task.notificationId!);
      }
      await scheduleTaskNotification(task);
    } else if (task.notificationId != null) {
      await _notificationService.cancelNotification(task.notificationId!);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final box = await openBox();
    final task = box.get(taskId);
    
    if (task != null && task.notificationId != null) {
      await _notificationService.cancelNotification(task.notificationId!);
    }
    
    await box.delete(taskId);
  }

  Future<List<Task>> getAllTasks() async {
    final box = await openBox();
    return box.values.toList();
  }

  Future<List<Task>> getTasksForDate(DateTime date) async {
    final box = await openBox();
    return box.values.where((task) {
      return task.startTime.year == date.year &&
             task.startTime.month == date.month &&
             task.startTime.day == date.day;
    }).toList();
  }

  Future<List<Task>> getCompletedTasks() async {
    final box = await openBox();
    return box.values.where((task) => task.isCompleted).toList();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final box = await openBox();
    final task = box.get(taskId);
    
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await task.save();
      
      if (task.isCompleted && task.notificationId != null) {
        await _notificationService.cancelNotification(task.notificationId!);
      }
    }
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (task.notificationTime == null) return;

    final notificationId = task.generateNotificationId();
    task.notificationId = notificationId;

    await _notificationService.scheduleNotification(
      id: notificationId,
      title: 'Task Reminder: ${task.title}',
      body: task.description,
      scheduledTime: task.notificationTime!,
      payload: task.id,
    );

    await task.save();
  }

  Future<void> clearAllTasks() async {
    final box = await openBox();
    
    for (var task in box.values) {
      if (task.notificationId != null) {
        await _notificationService.cancelNotification(task.notificationId!);
      }
    }
    
    await box.clear();
  }

  Future<Map<String, int>> getTaskCountByPriority() async {
    final box = await openBox();
    final tasks = box.values.where((task) => !task.isCompleted).toList();
    
    return {
      'high': tasks.where((t) => t.priority == 'high').length,
      'medium': tasks.where((t) => t.priority == 'medium').length,
      'low': tasks.where((t) => t.priority == 'low').length,
    };
  }

  Future<Map<String, int>> getTaskCountByCategory() async {
    final box = await openBox();
    final tasks = box.values.where((task) => !task.isCompleted).toList();
    
    final categories = <String, int>{};
    for (var task in tasks) {
      categories[task.category] = (categories[task.category] ?? 0) + 1;
    }
    
    return categories;
  }
}