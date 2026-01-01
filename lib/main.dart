import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:research_driven_time_scheduler_mobile_app/models/surveyFirstModel.dart';
import 'package:research_driven_time_scheduler_mobile_app/screens/survey/surveyStartPage.dart';
import 'package:research_driven_time_scheduler_mobile_app/models/surveyPersonalityModel.dart';
import 'package:research_driven_time_scheduler_mobile_app/models/userPreferencesModel.dart';
import 'package:research_driven_time_scheduler_mobile_app/models/taskModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (works for both web and mobile)
  await Hive.initFlutter();

    Hive.registerAdapter(SurveyFirstAdapter());
    Hive.registerAdapter(SurveyPersonalityAdapter());
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(UserPreferencesModelAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Scheduler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Directly open the survey start page
      home: const SurveyStartpage(),
    );
  }
}