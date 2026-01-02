import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/surveyFirstModel.dart';
import 'models/surveyPersonalityModel.dart';
import 'models/taskModel.dart';
import 'models/userPreferencesModel.dart';
import 'screens/survey/surveyStartPage.dart';
import 'screens/taskSchedule/taskScheduleHome.dart';
import 'controllers/preferencesController.dart';
import 'services/notification.dart';
import 'controllers/surveyController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  // Register all adapters
  Hive.registerAdapter(SurveyFirstAdapter());
  Hive.registerAdapter(SurveyPersonalityAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(UserPreferencesModelAdapter());

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PreferencesController prefsController = PreferencesController();

  @override
  void initState() {
    super.initState();
    checkFirstTime();
  }

Future<void> checkFirstTime() async {
  await Future.delayed(const Duration(seconds: 2));

  final surveyController = SurveyFirstController();
  final answers = await surveyController.getAllAnswers();

  if (!mounted) return;

  if (answers.isEmpty) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SurveyStartpage()),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TaskScheduleHome()),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.schedule,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Time Scheduler',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Personalized time management',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}