import 'package:hive/hive.dart';
import '../models/surveyFirstModel.dart';

class SurveyFirstController {
  static const String boxName = "surveyFirstBox";

  /// Open the Hive box
  Future<Box<SurveyFirst>> openBox() async {
    return await Hive.openBox<SurveyFirst>(boxName);
  }

  /// Save new answer
  Future<void> saveAnswer(SurveyFirst answer) async {
    final box = await openBox();
    await box.put(answer.questionId, answer);
  }

  /// Update an answer
  Future<void> updateAnswer(int questionId, String newAnswer) async {
    final box = await openBox();

    if (box.containsKey(questionId)) {
      final existing = box.get(questionId)!;
      existing.answer = newAnswer;
      await existing.save();   // Important
    }
  }

  /// Get all answers
  Future<List<SurveyFirst>> getAllAnswers() async {
    final box = await openBox();
    return box.values.toList();
  }

  /// Get answer by question ID
  Future<SurveyFirst?> getAnswer(int questionId) async {
    final box = await openBox();
    return box.get(questionId);
  }

  /// Delete one answer
  Future<void> deleteAnswer(int questionId) async {
    final box = await openBox();
    await box.delete(questionId);
  }

  /// Delete all answers
  Future<void> clearAll() async {
    final box = await openBox();
    await box.clear();
  }
}
