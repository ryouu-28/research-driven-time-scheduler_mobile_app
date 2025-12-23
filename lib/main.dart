import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:research_driven_time_scheduler_mobile_app/models/surveyFirstModel.dart';
// import 'package:research_drive_time_scheduler_mobile_app/pages/survey/surveyStartPage.';
import 'package:research_driven_time_scheduler_mobile_app/screens/survey/surveyStartPage.dart';
import 'package:research_driven_time_scheduler_mobile_app/models/surveyPersonalityModel.dart';
import 'package:research_driven_time_scheduler_mobile_app/models/userPreferencesModel.dart';
import 'package:research_driven_time_scheduler_mobile_app/models/taskModel.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);

  Hive.registerAdapter(SurveyFirstAdapter());
  Hive.registerAdapter(SurveyPersonalityAdapter());
  Hive.registerAdapter(UserPreferencesModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SurveyStartpage()),
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.blue,
          child: const Center(
            child: Text(
              "Hello",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
