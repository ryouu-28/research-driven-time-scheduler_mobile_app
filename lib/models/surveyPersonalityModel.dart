import 'package:hive/hive.dart';

part 'surveyPersonalityModel.g.dart';

@HiveType(typeId: 2)
class SurveyPersonality extends HiveObject {
  @HiveField(0)
  String personality;

  SurveyPersonality({
    required this.personality,
  });
}
