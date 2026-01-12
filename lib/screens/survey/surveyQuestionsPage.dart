import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:research_driven_time_scheduler_mobile_app/models/surveyPersonalityModel.dart';
import '../../screens/survey/surveyCompletePage.dart';
import '../../controllers/surveyController.dart';

class SurveyQuestionsPage extends StatefulWidget {
  const SurveyQuestionsPage({super.key});

  @override
  State<SurveyQuestionsPage> createState() => _SurveyQuestionsPageState();
}

class _SurveyQuestionsPageState extends State<SurveyQuestionsPage> {
  final SurveyFirstController controller = SurveyFirstController();
  Map<String, dynamic> quizData = {};
  Map<String, int> scores = { 
    "mood": 0, 
    "overwhelm": 0, 
    "reward": 0, 
    "perfection": 0, 
    "classic": 0, 
    "drifter": 0 
  };
  
  String? selectedPath;
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final jsonString = await rootBundle.loadString('assets/question.json');
      final data = jsonDecode(jsonString);
      if (mounted) {
        setState(() {
          quizData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading questions: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void addScore(Map<String, dynamic> scoreMaps) {
    Map<String, dynamic>? scoreMap = scoreMaps["score"];
    if (scoreMap == null) return;

    scoreMap.forEach((key, value) {
      int num = int.parse(value.toString());
      scores[key] = (scores[key] ?? 0) + num;
    });
    
    print('Current scores updated: $scores');
  }

  void selectRoot(Map<String, dynamic> opt) {
    setState(() {
      addScore(opt);
      selectedPath = opt["nextPath"];
      currentIndex = 0; 
    });
  }

  Future<void> checkPersonality() async {
    try {
      int maxValue = scores.values.reduce((a, b) => a > b ? a : b);

      List<String> highestTypes = scores.entries
          .where((e) => e.value == maxValue)
          .map((e) => e.key)
          .toList();

      bool tie = highestTypes.length > 1;
      String personalityResult = tie ? "classic" : highestTypes[0];
      
      print('Final Personality: $personalityResult');

      final userPersonality = SurveyPersonality(personality: personalityResult);
      await controller.savePersonality(userPersonality);
    } catch (e) {
      print('Error saving personality: $e');
    }
  }

  void selectOption(Map<String, dynamic> opt) {
    addScore(opt);

    if (selectedPath == null || quizData.isEmpty) return;

    final pathQuestions = quizData["paths"][selectedPath]["questions"];

    if (currentIndex < pathQuestions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      checkPersonality().then((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SurveyComplete(),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (quizData.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error loading questions'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loadQuestions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ROOT QUESTION
    if (selectedPath == null) {
      final root = quizData["root"];
      final options = root["options"];
      
    return Scaffold(
      body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/background.png",
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(
                      value: (currentIndex + 6) / 11,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Question ${currentIndex + 6} of 11',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      root["question"],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Options
                    ...options.map<Widget>((opt) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: 350, // 👈 same width for all buttons
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              backgroundColor: const Color(0xFFD9D9D9),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () => selectRoot(opt),
                            child: Text(opt["text"], textAlign: TextAlign.center),
                          ),
                        ),
                      );
                    }).toList(),

                  ],
                ),
              ),),
            ),
          ],
        ),

    );
        }

    // PATH QUESTIONS
    final path = quizData["paths"][selectedPath];
    if (path == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Path not found')),
      );
    }

    final questions = path["questions"];
    if (currentIndex >= questions.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = questions[currentIndex];
    final options = currentQuestion["options"];

  return Scaffold(
     body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (currentIndex + 7) / (questions.length + 7),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Question ${currentIndex + 7} of ${questions.length + 7}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentQuestion["question"],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ...options.map<Widget>((opt) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: const Color(0xFFD9D9D9),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => selectOption(opt),
                        child: Text(opt["text"], textAlign: TextAlign.center),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }

  @override
  void dispose() {
    super.dispose();
  }
}