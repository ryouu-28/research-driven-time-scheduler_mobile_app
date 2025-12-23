import 'package:hive/hive.dart';
import '../models/userPreferencesModel.dart';

class PreferencesController {
  static const String boxName = "preferencesBox";

  Future<Box<UserPreferencesModel>> openBox() async {
    return await Hive.openBox<UserPreferencesModel>(boxName);
  }

  // Save user preferences
  Future<void> savePreferences(UserPreferencesModel preferences) async {
    final box = await openBox();
    await box.put('user_preferences', preferences);
  }

  // Get user preferences
  Future<UserPreferencesModel?> getPreferences() async {
    final box = await openBox();
    return box.get('user_preferences');
  }

  // Check if preferences exist
  Future<bool> hasPreferences() async {
    final box = await openBox();
    return box.containsKey('user_preferences');
  }

  // Clear preferences
  Future<void> clearPreferences() async {
    final box = await openBox();
    await box.clear();
  }

  // Update specific preference
  Future<void> updateMaxDailyTasks(int maxTasks) async {
    final prefs = await getPreferences();
    if (prefs != null) {
      prefs.maxDailyTasks = maxTasks;
      await prefs.save();
    }
  }

  Future<void> updateNeedsReminders(bool needs) async {
    final prefs = await getPreferences();
    if (prefs != null) {
      prefs.needsReminders = needs;
      await prefs.save();
    }
  }
}