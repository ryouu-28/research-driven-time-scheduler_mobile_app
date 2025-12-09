import 'dart:convert';

import 'package:flutter/material.dart';

class TaskscheduleHome extends StatefulWidget {
  const TaskscheduleHome({super.key});

  @override
  State<TaskscheduleHome> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<TaskscheduleHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center, // center vertically
          crossAxisAlignment: CrossAxisAlignment.center, // center horizontally
          children: [
            SizedBox(height: 60,),
            Container(
              child: Center(child: Text("HI!"),),
              width: double.infinity,
              height: 200,
              color: Colors.blue,
            ),
            Container(
              child: Center(child: Text("data")),
              color: Colors.pink,
              width: double.infinity,
              height: 550,
            ),
            Container(
              color: Colors.amber,
              width: double.infinity,
              height: 100,
              )
            
          ],
        )
      ),
    );
  }
}