import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirstQuestion extends StatefulWidget {
  const FirstQuestion({super.key});

  @override
  State<FirstQuestion> createState() => _FirstQuestion();
}

class _FirstQuestion extends State<FirstQuestion> {
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

  void nextQuestion(String opt, int idQuestion){
    print(opt);
    print(idQuestion);
    if (currentIndex < quizQuestions["survey"].length - 1) {
        setState(() {
          currentIndex++;
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FirstQuestion(),
          ),
        );
      }
  }


  @override
Widget build(BuildContext context) {
  // Prevent null crash while JSON is still loading
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