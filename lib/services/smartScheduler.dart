import '../models/taskModel.dart';
import '../models/userPreferencesModel.dart';
import '../utils/surveyAnalyzer.dart';

class SmartScheduler {
  // Generate suggested tasks for the day
  static List<Map<String, dynamic>> generateDailySuggestions(
    UserPreferencesModel preferences,
    DateTime targetDate,
  ) {
    final timeSlot = SurveyAnalyzer.getRecommendedTimeSlot(
      preferences.preferredTimeSlot,
    );

    List<Map<String, dynamic>> suggestions = [];
    int currentHour = timeSlot['start']!;
    final endHour = timeSlot['end']!;

    int taskCount = 0;
    while (currentHour < endHour && taskCount < preferences.maxDailyTasks) {
      final startTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        currentHour,
        0,
      );

      final duration = preferences.recommendedTaskDuration;
      final endTime = startTime.add(Duration(minutes: duration));

      suggestions.add({
        'startTime': startTime,
        'endTime': endTime,
        'duration': duration,
        'slot': taskCount + 1,
      });

      // Add break time for focus session
      if (preferences.scheduleStyle == 'Focus Session') {
        currentHour += (duration / 60).ceil();
        currentHour += 0; // 15 min break (can adjust)
      } else {
        currentHour += (duration / 60).ceil();
      }

      taskCount++;
    }

    return suggestions;
  }

  // Break down large task into subtasks
  static List<TaskModel> breakDownLargeTask(
    TaskModel task,
    UserPreferencesModel preferences,
  ) {
    if (!preferences.getOverwhelmed) {
      return [task]; // No need to break down
    }

    final duration = task.durationInMinutes;
    if (duration <= 30) {
      return [task]; // Already small enough
    }

    final subtaskCount = (duration / 30).ceil();
    final subtaskDuration = duration ~/ subtaskCount;
    
    List<TaskModel> subtasks = [];
    DateTime currentStart = task.startTime;

    for (int i = 1; i <= subtaskCount; i++) {
      final subtaskEnd = currentStart.add(Duration(minutes: subtaskDuration));
      
      subtasks.add(TaskModel(
        id: '${task.id}_sub$i',
        title: '${task.title} - Part $i/$subtaskCount',
        description: task.description,
        startTime: currentStart,
        endTime: subtaskEnd,
        priority: task.priority,
        category: task.category,
        createdAt: DateTime.now(),
      ));

      currentStart = subtaskEnd;
    }

    return subtasks;
  }

  // Auto-arrange tasks based on personality
  static List<TaskModel> arrangeTasksByPersonality(
    List<TaskModel> tasks,
    UserPreferencesModel preferences,
  ) {
    List<TaskModel> arranged = List.from(tasks);

    switch (preferences.personalityType) {
      case 'classic':
        // Sort by deadline (urgency)
        arranged.sort((a, b) => a.endTime.compareTo(b.endTime));
        break;

      case 'perfectionist':
        // Sort by priority first, then deadline
        arranged.sort((a, b) {
          if (a.priority != b.priority) {
            return b.priority.compareTo(a.priority);
          }
          return a.endTime.compareTo(b.endTime);
        });
        break;

      case 'reward':
        // Alternate high and low priority for motivation
        arranged.sort((a, b) => b.priority.compareTo(a.priority));
        break;

      case 'overwhelm':
        // Shortest tasks first
        arranged.sort((a, b) => 
          a.durationInMinutes.compareTo(b.durationInMinutes));
        break;

      case 'mood':
        // Start with easiest (lowest priority) to build momentum
        arranged.sort((a, b) => a.priority.compareTo(b.priority));
        break;

      case 'drifter':
        // Keep original order (from user planning)
        break;

      default:
        // Sort by start time
        arranged.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return arranged;
  }

  // Check if adding task exceeds daily limit
  static bool canAddTask(
    int currentTaskCount,
    UserPreferencesModel preferences,
  ) {
    return currentTaskCount < preferences.maxDailyTasks;
  }

  // Get optimal time suggestion for new task
  static DateTime? suggestOptimalTime(
    DateTime date,
    UserPreferencesModel preferences,
    List<TaskModel> existingTasks,
  ) {
    final timeSlot = SurveyAnalyzer.getRecommendedTimeSlot(
      preferences.preferredTimeSlot,
    );

    int suggestedHour = timeSlot['start']!;
    final endHour = timeSlot['end']!;

    // Find first available slot
    for (int hour = suggestedHour; hour < endHour; hour++) {
      final proposedStart = DateTime(date.year, date.month, date.day, hour, 0);
      final proposedEnd = proposedStart.add(
        Duration(minutes: preferences.recommendedTaskDuration),
      );

      // Check if slot is free
      bool isFree = true;
      for (var task in existingTasks) {
        if ((proposedStart.isBefore(task.endTime) &&
            proposedEnd.isAfter(task.startTime))) {
          isFree = false;
          break;
        }
      }

      if (isFree) {
        return proposedStart;
      }
    }

    return null; // No available slots
  }

  // Get productivity tip based on personality
  static String getProductivityTip(String personalityType) {
    switch (personalityType) {
      case 'classic':
        return '💡 Set artificial deadlines 2 days before the real one!';
      case 'perfectionist':
        return '💡 Set a timer and stop when it rings - done is better than perfect!';
      case 'reward':
        return '💡 Plan your reward before starting the task!';
      case 'mood':
        return '💡 Start with a 5-minute task to boost your mood!';
      case 'overwhelm':
        return '💡 Use the 2-minute rule: if it takes less than 2 minutes, do it now!';
      case 'drifter':
        return '💡 Set alarms for each task transition!';
      default:
        return '💡 Break your work into focused 25-minute sessions!';
    }
  }
}