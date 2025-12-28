import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/surveyFirstModel.dart';
import 'models/surveyPersonalityModel.dart';
import 'services/notification.dart';
import 'screens/survey/surveyStartPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 App starting...');

  // Initialize Hive
  try {
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);
    Hive.registerAdapter(SurveyFirstAdapter());
    Hive.registerAdapter(SurveyPersonalityAdapter());
    print('✅ Hive initialized');
  } catch (e) {
    print('❌ Hive error: $e');
  }

  // Initialize Notifications
  try {
    final notif = NotificationService();
    await notif.initialize();
    print('✅ Notification service initialized');
    
    final granted = await notif.requestPermissions();
    print('✅ Notification permissions: $granted');
    
    // Test notification after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      notif.showTestNotification();
    });
  } catch (e) {
    print('❌ Notification error: $e');
    print('Error details: ${e.toString()}');
  }

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
      home: const NotificationTestScreen(),
    );
  }
}

class NotificationTestScreen extends StatelessWidget {
  const NotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_active,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 30),
            const Text(
              'Notification Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Check console for initialization status',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final notif = NotificationService();
                  await notif.showTestNotification();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Notification sent! Check your notification panel.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  print('❌ Button error: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Test Notification'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SurveyStartpage(),
                  ),
                );
              },
              child: const Text('Continue to Survey'),
            ),
          ],
        ),
      ),
    );
  }
}