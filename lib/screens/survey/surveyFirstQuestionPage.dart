import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:research_driven_time_scheduler_mobile_app/screens/survey/surveyQuestionsPage.dart';
import '../../controllers/surveyController.dart';
import '../../models/surveyFirstModel.dart';

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
            builder: (context) => SurveyQuestionsPage(),
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
  body: Stack(
    children: [
      Positioned.fill(
        child: Image.asset(
          "assets/images/background.png",
          fit: BoxFit.cover, // fills screen proportionally
        ),
      ),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                  Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 350), // limit width
             
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 15.0),
              decoration: BoxDecoration( 
                color: const Color(0x99D9D9D9), 
              borderRadius: BorderRadius.circular(12)),
                child: Text(
                  surveyQuestions["question"],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),


            const SizedBox(height: 20),
            ...answers.map<Widget>((opt) {
              return Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFFD9D9D9),
                    ),
                    onPressed: () => nextQuestion(opt, idQuestion),
                    child: Text(opt),
                  ),
                  const SizedBox(height: 15), // space after each button
                ],
              );
            }).toList(),

             
          ],

        ),
      ),
    ],
  ),
);
}
}