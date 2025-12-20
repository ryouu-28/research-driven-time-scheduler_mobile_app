import 'dart:convert';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';

class TaskScheduleHome extends StatefulWidget {
  const TaskScheduleHome({super.key});

  @override
  State<TaskScheduleHome> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<TaskScheduleHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center, // center vertically
          crossAxisAlignment: CrossAxisAlignment.center, // center horizontally
          children: [
            SizedBox(height: 100,),
            SfCalendar(
              view: CalendarView.day
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