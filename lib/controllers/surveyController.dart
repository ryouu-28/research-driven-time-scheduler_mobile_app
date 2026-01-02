import 'package:hive/hive.dart';
import '../models/surveyFirstModel.dart';
import '../models/surveyPersonalityModel.dart';
import '../models/userPreferencesModel.dart';

class SurveyFirstController {
  static const String boxName = "surveyFirstBox";
  static const String personalityBox = "personalityBox";

  // ========== Survey Answers Methods ==========
  
  Future<Box<SurveyFirst>> openBox() async {
    return await Hive.openBox<SurveyFirst>(boxName);
  }

  Future<void> saveAnswer(SurveyFirst answer) async {
    final box = await openBox();
    await box.put(answer.questionId, answer);
  }

  Future<void> updateAnswer(int questionId, String newAnswer) async {
    final box = await openBox();
    if (box.containsKey(questionId)) {
      final existing = box.get(questionId)!;
      existing.answer = newAnswer;
      await existing.save();
    }
  }

  Future<List<SurveyFirst>> getAllAnswers() async {
    final box = await openBox();
    return box.values.toList();
  }

  Future<SurveyFirst?> getAnswer(int questionId) async {
    final box = await openBox();
    return box.get(questionId);
  }

  Future<void> deleteAnswer(int questionId) async {
    final box = await openBox();
    await box.delete(questionId);
  }

  Future<void> clearAll() async {
    final box = await openBox();
    await box.clear();
  }

  // ========== Personality Methods ==========
  
  Future<Box<SurveyPersonality>> openPersonalityBox() async {
    return await Hive.openBox<SurveyPersonality>(personalityBox);
  }

  Future<void> savePersonality(SurveyPersonality result) async {
    final box = await openPersonalityBox();
    await box.put("user_personality", result);
  }

  Future<SurveyPersonality?> getPersonality() async {
    final box = await openPersonalityBox();
    return box.get("user_personality");
  }

  Future<void> clearPersonality() async {
    final box = await openPersonalityBox();
    await box.clear();
  }

  // ========== Reset Everything ==========
  
  Future<void> resetAllData() async {
    await clearAll();
    await clearPersonality();

    final prefsBox = await Hive.openBox<UserPreferencesModel>('userPreferencesBox'); 
    await prefsBox.clear(); // clear preferences too
  }
}