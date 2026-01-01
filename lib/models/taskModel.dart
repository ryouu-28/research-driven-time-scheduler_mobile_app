import 'package:hive/hive.dart';

part 'taskModel.g.dart';

@HiveType(typeId: 4)
class Task extends HiveObject {
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
  bool isCompleted;

  @HiveField(6)
  String priority; // 'high', 'medium', 'low'

  @HiveField(7)
  String category; // 'work', 'personal', 'study', etc.

  @HiveField(8)
  bool hasNotification;

  @HiveField(9)
  int? notificationId;

  @HiveField(10)
  DateTime? notificationTime;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
    this.priority = 'medium',
    this.category = 'personal',
    this.hasNotification = false,
    this.notificationId,
    this.notificationTime,
  });

  int generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }
}