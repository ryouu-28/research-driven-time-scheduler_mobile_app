import 'package:flutter/material.dart';
import '../../controllers/surveyController.dart';
import '../../controllers/preferencesController.dart';
import '../../utils/surveyAnalyzer.dart';
import '../taskSchedule/taskScheduleHome.dart';

class SurveyCompleteUpdated extends StatefulWidget {
  const SurveyCompleteUpdated({super.key});

  @override
  State<SurveyCompleteUpdated> createState() => _SurveyCompleteUpdatedState();
}

class _SurveyCompleteUpdatedState extends State<SurveyCompleteUpdated> {
  final SurveyFirstController surveyController = SurveyFirstController();
  final PreferencesController prefsController = PreferencesController();
  
  List<Widget> results = [];
  int visibleCount = 0;
  bool isOutlined = false;
  bool isLoading = true;
  String personalityType = '';
  String personalityAdvice = '';

  @override
  void initState() {
    super.initState();
    processResults();
  }

  Future<void> processResults() async {
    // Get survey answers
    final answers = await surveyController.getAllAnswers();
    final personality = await surveyController.getPersonality();

    if (personality == null) return;

    personalityType = personality.personality;
    personalityAdvice = SurveyAnalyzer.getPersonalityAdvice(personalityType);

    // Create preferences from survey
    final preferences = SurveyAnalyzer.analyzeAnswers(answers, personality);
    await prefsController.savePreferences(preferences);

    // Build result messages
    setState(() {
      results = [
        const Text(
          'Welcome to Your Personalized Scheduler!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          'Based on your answers, we\'ve created a schedule that works for you:',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Text(
                '📊 Your Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 15),
              _buildProfileRow('Personality Type:', _formatPersonality(personalityType)),
              _buildProfileRow('Daily Tasks:', '${preferences.maxDailyTasks} tasks'),
              _buildProfileRow('Best Time:', preferences.preferredTimeSlot),
              _buildProfileRow('Schedule Style:', preferences.scheduleStyle),
              _buildProfileRow('Reminders:', preferences.needsReminders ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  personalityAdvice,
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ];
      isLoading = false;
    });
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  String _formatPersonality(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }

  void showNextText() {
    setState(() {
      if (visibleCount < results.length) {
        visibleCount++;
      }
      if (visibleCount == results.length) {
        isOutlined = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: results.take(visibleCount).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              isOutlined
                  ? SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TaskScheduleHome(),
                            ),
                          );
                        },
                        child: const Text(
                          'Start Scheduling',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: showNextText,
                      child: const Text(
                        'Click to continue...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}