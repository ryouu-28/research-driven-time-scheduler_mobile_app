import 'package:hive/hive.dart';

part 'taskModel.g.dart';

@HiveType(typeId: 4)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime startTime;

  @HiveField(4)
  DateTime endTime;

  @HiveField(5)
  int priority; // 1 = Low, 2 = Medium, 3 = High

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  String category;

  @HiveField(8)
  DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.priority = 2,
    this.isCompleted = false,
    this.category = 'Study',
    required this.createdAt,
  });

  // Helper method to get priority label
  String get priorityLabel {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Medium';
    }
  }

  // Helper to check if task is overdue
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(endTime);
  }

  // Helper to get task duration in minutes
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }
}