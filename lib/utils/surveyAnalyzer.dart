import '../models/surveyFirstModel.dart';
import '../models/surveyPersonalityModel.dart';
import '../models/userPreferencesModel.dart';

class SurveyAnalyzer {
  // Parse survey answers into UserPreferencesModel
  static UserPreferencesModel analyzeAnswers(
    List<SurveyFirst> answers,
    SurveyPersonality personality,
  ) {
    // Initialize defaults
    int maxDailyTasks = 4;
    String preferredTimeSlot = 'Morning';
    String scheduleStyle = 'Flexible';
    bool needsReminders = true;
    bool getOverwhelmed = false;

    // Parse each answer
    for (var answer in answers) {
      switch (answer.questionId) {
        case 1: // Do you get overwhelmed?
          getOverwhelmed = answer.answer == 'Yes';
          break;

        case 2: // How many tasks can you do?
          if (answer.answer.contains('1-2')) {
            maxDailyTasks = 2;
          } else if (answer.answer.contains('3-4')) {
            maxDailyTasks = 4;
          } else if (answer.answer.contains('5+')) {
            maxDailyTasks = 6;
          }
          break;

        case 3: // Do you want reminders?
          needsReminders = answer.answer == 'Yes';
          break;

        case 4: // Schedule style
          if (answer.answer.contains('Focus Session')) {
            scheduleStyle = 'Focus Session';
          } else {
            scheduleStyle = 'Flexible';
          }
          break;

        case 5: // Most active time
          preferredTimeSlot = answer.answer; // Morning, Afternoon, Night
          break;
      }
    }

    return UserPreferencesModel(
      maxDailyTasks: maxDailyTasks,
      preferredTimeSlot: preferredTimeSlot,
      scheduleStyle: scheduleStyle,
      needsReminders: needsReminders,
      personalityType: personality.personality,
      getOverwhelmed: getOverwhelmed,
    );
  }

  // Get time slot recommendation (in 24h format)
  static Map<String, int> getRecommendedTimeSlot(String preferredTimeSlot) {
    switch (preferredTimeSlot) {
      case 'Morning':
        return {'start': 8, 'end': 12};
      case 'Afternoon':
        return {'start': 13, 'end': 17};
      case 'Night':
        return {'start': 19, 'end': 22};
      default:
        return {'start': 9, 'end': 17};
    }
  }

  // Break task into subtasks for overwhelmed users
  static List<String> breakDownTask(String mainTask, int duration) {
    if (duration <= 30) {
      return [mainTask]; // Already small enough
    }

    int subtaskCount = (duration / 30).ceil();
    List<String> subtasks = [];
    
    for (int i = 1; i <= subtaskCount; i++) {
      subtasks.add('$mainTask - Part $i');
    }

    return subtasks;
  }

  // Get personality-specific advice
  static String getPersonalityAdvice(String personalityType) {
    switch (personalityType) {
      case 'mood':
        return 'Start with small wins to boost your mood!';
      case 'overwhelm':
        return 'Break big tasks into 30-minute chunks.';
      case 'reward':
        return 'Set rewards after completing tasks!';
      case 'perfection':
        return 'Done is better than perfect. Aim for progress!';
      case 'classic':
        return 'Use deadlines as motivation. You thrive under pressure!';
      case 'drifter':
        return 'Stick to your routine. Consistency is key!';
      default:
        return 'You\'ve got this! Stay focused.';
    }
  }
}