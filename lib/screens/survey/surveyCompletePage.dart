import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/surveyController.dart';
import '../../models/surveyFirstModel.dart';


class SurveyComplete extends StatefulWidget {
  const SurveyComplete({super.key});

  @override
  State<SurveyComplete> createState() => _SurveyCompleteState();
}

class _SurveyCompleteState extends State<SurveyComplete> {
  final SurveyFirstController controller = SurveyFirstController();
   List<Widget> results = [
    Text("I would like to welcome you"),
    Text("Each answer you provided is end up being helpful to identify your habits, characteristic, and personality."),
    Text("You are"),
    Text("You are description...............")
  ];
  int visibleCount = 0;
  bool isOutlined = false;

    void checkAnswers() async {
      print("THIS IS YOUR DATA");
    final allAnswers = await controller.getAllAnswers();
      for (var a in allAnswers) {
        print("Question ID: ${a.questionId}, Answer: ${a.answer}");
      }
    }
    void showNextText() {
      setState(() {
        if (visibleCount < results.length) {
          visibleCount++;
        }

        if(visibleCount == results.length){isOutlined = true;}
        
      });
    }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OutlinedButton(onPressed: () => checkAnswers(), child: Text("data")),
            ...results.take(visibleCount),
            const SizedBox(height: 20),
            isOutlined
                ? OutlinedButton(
                    onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const SurveyComplete()));},
                    child: Text("Continue"),
                  )
                : TextButton(
                    onPressed: showNextText,
                    child: Text("Click here to continue..."),
                  ),
          ],
        ),
      ),
    );
  }
}
