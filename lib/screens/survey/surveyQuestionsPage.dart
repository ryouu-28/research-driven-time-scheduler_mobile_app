import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:scheduler_prototype/pages/taskSchedule/taskScheduleHome.dart';
import 'package:research_driven_time_scheduler_mobile_app/screens/taskSchedule/taskScheduleHome.dart';

class SurveyQuestionsPage extends StatefulWidget {
  const SurveyQuestionsPage({super.key});

  @override
  State<SurveyQuestionsPage> createState() => _SurveyQuestionsPageState();
}

class _SurveyQuestionsPageState extends State<SurveyQuestionsPage> {
  Map<String, dynamic> quizData = {};
  Map<String, int> scores = 
  { 
  "mood": 0, 
  "overwhelm": 0, 
  "reward": 0, 
  "perfection": 0, 
  "classic": 0, 
  "drifter": 0 };
  // int nextPath = 0;
  String? selectedPath;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  // Load JSON from assets
  Future<void> loadQuestions() async {
    final jsonString = await rootBundle.loadString('assets/question.json');
    final data = jsonDecode(jsonString);
    setState(() {
      quizData = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    void AddScore(Map<String, dynamic> scoreMaps){
      Map<String, dynamic>? scoreMap = scoreMaps["score"];
      if (scoreMap == null)return;
      // print(scoreMap);

      scoreMap.forEach((key, value) {
        int num = int.parse(value.toString());
        scores[key] = (scores[key] ?? 0) + num;

      },);
      scores.forEach((key, value) {
        print(key);
        print(value);
      },);
      
    }
  
    void selectRoot(Map<String, dynamic> opt){
      print(opt);
      print("glenn pogi");
      AddScore(opt);
    
      setState(() {
        selectedPath = opt["nextPath"];
      });
      
      print(selectedPath);
      print("Selected root option: $opt");
      print("nextPath: ${opt["nextPath"]}");

    }

    void selectOption(Map<String, dynamic> opt) {
      AddScore(opt);

      final pathQuestions = quizData["paths"][selectedPath]["questions"];

      if (currentIndex < pathQuestions.length - 1) {
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

    if (quizData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if(selectedPath == null){
    final root = quizData["root"];
    final option = root["options"];
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(root["question"]),
            ...option.map<Widget>((opt) {
              return ElevatedButton(
                onPressed: () => selectRoot(opt),
                
                child: Text(opt["text"]),
              );
            }).toList(),
          ],
        ),
      ),
    );
    }

    final path = quizData["paths"][selectedPath];
    final questions = path["questions"];              
    final currentQuestion = questions[currentIndex];  
    final options = currentQuestion["options"];       

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(currentQuestion["question"]),
            ...options.map<Widget>((opt ){
              return OutlinedButton(onPressed: () => selectOption(opt), child: Text(opt["text"]));
            })
          ],
        ),
      ),
    );
  }
}

class SurveyComplete extends StatefulWidget {
  const SurveyComplete({super.key});

  @override
  State<SurveyComplete> createState() => _SurveyCompleteState();
}

class _SurveyCompleteState extends State<SurveyComplete> {
   List<Widget> results = [
    Text("I would like to welcome you"),
    Text("Each answer you provided is end up being helpful to identify your habits, characteristic, and personality."),
    Text("You are"),
    Text("You are description...............")
  ];
  int visibleCount = 0;
  bool isOutlined = false;

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
            ...results.take(visibleCount),
            const SizedBox(height: 20),
            isOutlined
                ? OutlinedButton(
                    onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskscheduleHome()));},
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
