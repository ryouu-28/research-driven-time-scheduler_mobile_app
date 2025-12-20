import 'package:hive/hive.dart';

part 'scheduleModel.g.dart';

@HiveType(typeId: 3)
class SurveyFirst {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime starTime;

  @HiveField(2)
  DateTime endTime;

  @HiveField(3)
  String description;
  

  SurveyFirst({
    required this.questionId,
    required this.answer,
  });

  Future<void> save() async {}
}
