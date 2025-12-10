import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:research_driven_time_scheduler_mobile_app/screens/survey/surveyCompletePage.dart';
import '../../controllers/surveyController.dart';
import '../../models/surveyFirstModel.dart';
import '../../screens/survey/surveyCompletePage.dart';

class FirstQuestion extends StatefulWidget {
  const FirstQuestion({super.key});

  @override
  State<FirstQuestion> createState() => _FirstQuestion();
}

class _FirstQuestion extends State<FirstQuestion> {
    final SurveyFirstController controller = SurveyFirstController();
    Map<String, dynamic> quizQuestions = {};
    int currentIndex = 0;

    @override
    void initState() {
    super.initState();
    loadFirstQuestions();
    }

  Future<void> loadFirstQuestions() async {
    final jsonString = await rootBundle.loadString('assets/firstQuestion.json');
    final data = jsonDecode(jsonString);
    setState(() {
      quizQuestions = data;
    });
  }

  void nextQuestion(String opt, int idQuestion) async {
    final answer = SurveyFirst(
      questionId: idQuestion,
      answer: opt,
    );
    await controller.saveAnswer(answer);

    
    if (currentIndex < quizQuestions["survey"].length - 1) {
        setState(() {
          currentIndex++;
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurveyComplete(),
          ),
        );
      }


  }


  @override
Widget build(BuildContext context) {
  if (quizQuestions.isEmpty) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }


  final surveyQuestions = quizQuestions["survey"][currentIndex];
  final answers = surveyQuestions["options"];
  final idQuestion = surveyQuestions["id"];

  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(surveyQuestions["question"]),

          const SizedBox(width: 20),

         ...answers.map<Widget>((opt) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ElevatedButton(
              onPressed: () => nextQuestion(opt, idQuestion),
              child: Text(opt),
            ),
          );
        }).toList(),
        ],
      ),
    ),
  );
}
}