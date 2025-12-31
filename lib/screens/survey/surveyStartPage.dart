import 'package:flutter/material.dart';
// import 'package:scheduler_prototype/pages/survey/surveyQuestionsPage.dart';
import 'package:research_driven_time_scheduler_mobile_app/screens/survey/surveyFirstQuestionPage.dart';


class SurveyStartpage extends StatelessWidget {
  const SurveyStartpage({super.key});
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Text("Hello There! Wanna start managing your time?"),
            ),SizedBox(height: 50,),
            SizedBox(
              height: 50,
              width: 200,
              child: OutlinedButton(
              onPressed: (){
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => const FirstQuestion()));}, 
              child: Text("answer 1")
              ),
            )
          ],
        ),
      ),
    );
  }
}