import 'package:hive/hive.dart';

part 'userPreferencesModel.g.dart';

@HiveType(typeId: 5)
class UserPreferencesModel extends HiveObject {
  @HiveField(0)
  int maxDailyTasks; // 2, 4, or 5+

  @HiveField(1)
  String preferredTimeSlot; // 'Morning', 'Afternoon', 'Night'

  @HiveField(2)
  String scheduleStyle; // 'Focus Session' or 'Flexible'

  @HiveField(3)
  bool needsReminders;

  @HiveField(4)
  String personalityType; // 'mood', 'overwhelm', 'reward', etc.

  @HiveField(5)
  bool getOverwhelmed; // From question 1

  UserPreferencesModel({
    required this.maxDailyTasks,
    required this.preferredTimeSlot,
    required this.scheduleStyle,
    required this.needsReminders,
    required this.personalityType,
    required this.getOverwhelmed,
  });

  // Helper methods based on personality
  int get recommendedTaskDuration {
    if (getOverwhelmed) return 30; // Shorter tasks
    if (scheduleStyle == 'Focus Session') return 90;
    return 60; // Default 1 hour
  }

  int get reminderMinutesBefore {
    if (scheduleStyle == 'Focus Session') return 15;
    return 60; // 1 hour for flexible
  }

  String get motivationalMessage {
    switch (personalityType) {
      case 'classic':
        return 'Beat the deadline! Time to focus.';
      case 'perfectionist':
        return 'Progress over perfection. You got this!';
      case 'reward':
        return 'Complete this task and treat yourself!';
      case 'mood':
        return 'Small steps lead to big wins.';
      case 'overwhelm':
        return 'One task at a time. You can do it!';
      case 'drifter':
        return 'Stay on track! Follow your schedule.';
      default:
        return 'Let\'s crush today\'s goals!';
    }
  }
}