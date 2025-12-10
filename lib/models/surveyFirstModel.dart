import 'package:hive/hive.dart';

part 'surveyFirstModel.g.dart';

@HiveType(typeId: 1)
class SurveyFirst {
  @HiveField(0)
  int questionId;

  @HiveField(1)
  String answer;

  SurveyFirst({
    required this.questionId,
    required this.answer,
  });

  Future<void> save() async {}
}
