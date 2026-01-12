import 'package:flutter/material.dart';
import 'package:research_driven_time_scheduler_mobile_app/main.dart';
import 'package:research_driven_time_scheduler_mobile_app/screens/about/aboutUs.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../controllers/taskController.dart';
import '../../controllers/preferencesController.dart';
import '../../models/taskModel.dart';
import '../../models/userPreferencesModel.dart';
import 'addTaskScreen.dart';
import 'taskDetailScreen.dart';
import '../../controllers/surveyController.dart';
import '../../screens/survey/surveyStartPage.dart';
import '../../services/notification.dart';
import '../../screens/about/aboutUs.dart';
import '../../models/surveyPersonalityModel.dart';
import 'package:intl/intl.dart';
import '../../screens/survey/surveyCompletePage.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskScheduleHome extends StatefulWidget {
  const TaskScheduleHome({super.key});

  @override
  State<TaskScheduleHome> createState() => _TaskScheduleHomeState();
}

class _TaskScheduleHomeState extends State<TaskScheduleHome> {
  final TaskController taskController = TaskController();
  final PreferencesController prefsController = PreferencesController();
  final SurveyFirstController surveyController = SurveyFirstController();
  final NotificationService notificationService = NotificationService();
  
  SurveyPersonality? userPersonality;
      
  
  List<TaskModel> tasks = [];
  UserPreferencesModel? preferences;
  CalendarView currentView = CalendarView.week;
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
    surveyController.getPersonality().then((value) { 
      setState(() { 
        userPersonality = value; 
        }); 
      });
  }
  

  Future<void> loadData() async {
    preferences = await prefsController.getPreferences();
    tasks = await taskController.getAllTasks();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> refreshTasks() async {
    tasks = await taskController.getAllTasks();
    setState(() {});
  }

  String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar', 
          style: GoogleFonts.lato( fontSize: 29, fontWeight: FontWeight.w700, color: Colors.black,),
        ),
        foregroundColor: Colors.black,
        flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),   
        actions: [
          IconButton(
            icon: const Icon(Icons.view_day),
            onPressed: () {
              setState(() {
                print("Switching to day view");
                currentView = CalendarView.day;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.view_week),
            onPressed: () {
              setState(() {
                 print("Switching to week view");
                currentView = CalendarView.week;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              setState(() {
                currentView = CalendarView.month;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Menu',
                    style: GoogleFonts.lato( fontSize: 29, fontWeight: FontWeight.w700, color: Colors.white,),
                   
                  ),
                  const SizedBox(height: 12),
                  Text(
                    capitalizeFirstLetter( userPersonality?.personality ?? "No personality yet",),           
                    style: GoogleFonts.lato( fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white,),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    preferences!.motivationalMessage,
                    style: GoogleFonts.lato( fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white,),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home_outlined),
              title:  Text('Home', style: GoogleFonts.lato( fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black,),),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TaskScheduleHome()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt_outlined, color: Color.fromARGB(255, 0, 0, 0)),
              title:  Text("Restart Survey", style: GoogleFonts.lato( fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black,),),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Restart'),
                    content: const Text(
                      'Are you sure you want to restart the survey?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false), // cancel
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true), // confirm
                        child: const Text('Restart'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  // await taskController.clearAllTasks();
                  await surveyController.resetAllData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ All survey data deleted"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );  

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SurveyStartpage()),
                  );
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.delete, color: Color.fromARGB(255, 0, 0, 0)),
              title:  Text("Delete All Task", style: GoogleFonts.lato( fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black,),),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text(
                      'Are you sure you want to delete all existing task?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false), // cancel
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true), // confirm
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await taskController.clearAllTasks();
                  // await surveyController.resetAllData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ All survey data deleted"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );  

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TaskScheduleHome()),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title:  Text('View Profile', style: GoogleFonts.lato( fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black,),),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SurveyComplete()),
                );
              },
            ),
          ],
        ),
      ),
      
      body: Column(
        children: [
          // Motivational Banner
          if (preferences != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              color: const Color.fromARGB(197, 99, 180, 226),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      preferences!.motivationalMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Today's Progress
          _buildTodayProgress(),

          // Calendar
         Expanded(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover, 
              ),
            ),
            child: SfCalendar(
              key: ValueKey(currentView), 
              view: currentView,
              // allowedViews: const[
              //   CalendarView.day,
              //   CalendarView.week,
              //   CalendarView.month,
              // ],

              allowViewNavigation: true,
            
              //Month Style
              headerStyle: const CalendarHeaderStyle(
                backgroundColor: Colors.black,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Montserrat',
                  fontWeight:  FontWeight.bold,
                  // backgroundColor: Colors.blue,
                  // decorationColor: Colors.green,
                ),),

              viewHeaderStyle: const ViewHeaderStyle(
                dayTextStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
                // backgroundColor: Colors.lightBlueAccent,
              ),
              backgroundColor: Colors.transparent,
              dataSource: TaskDataSource(tasks),
              onTap: (details) {
                if (details.appointments != null && details.appointments!.isNotEmpty) {
                  final TaskModel task = details.appointments!.first;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(task: task),
                    ),
                  ).then((_) => refreshTasks());
                }
              },
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
              timeSlotViewSettings: const TimeSlotViewSettings(
                startHour: 0,
                endHour: 24,
                timeInterval: Duration(minutes: 60),
                timeIntervalHeight: 65,
                timeTextStyle: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Montserrat',
                  color: Colors.black
                  )
              ),
            ),
          ),
        ),
        ],
      ),
      floatingActionButton: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    // ElevatedButton.icon(
    //     onPressed: () async {
    //       // Make sure NotificationService is initialized somewhere (e.g. in main.dart)
    //       // await NotificationService().showNotification(
    //       //   '🔔 Task Reminder',
    //       //   'This is your test notification from Task Home!',
    //       // );
    //       await NotificationService().openExactAlarmSettings();
    //     },
    //     icon: const Icon(Icons.notifications_active),
    //     label: const Text(
    //       'Send Test Notification',
    //       style: TextStyle(
    //         fontFamily: 'Montserrat',
    //         fontWeight: FontWeight.w600,
    //       ),
    //     ),
    //     style: ElevatedButton.styleFrom(
    //       backgroundColor: Colors.blue, // button color
    //       foregroundColor: Colors.white, // text/icon color
    //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(8),
    //       ),
    //     ),
    //   ),

    const SizedBox(height: 10),
    FloatingActionButton.extended(
      onPressed: () async {
        final todayTasks = await taskController.getTasksForDate(DateTime.now());

        if (preferences != null &&
            todayTasks.length >= preferences!.maxDailyTasks) {
          // Find the lowest priority task (assuming smaller number = lower priority)
          TaskModel? lowestPriorityTask;
          if (todayTasks.isNotEmpty) {
            todayTasks.sort((a, b) => a.priority.compareTo(b.priority));
            lowestPriorityTask = todayTasks.first;
          }

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Daily Limit Reached'),
              content: Text(
                'You\'ve reached your daily limit of '
                '${preferences!.maxDailyTasks} tasks.\n\n'
                'Consider completing existing tasks first!'
                '${lowestPriorityTask != null ? "\n\nLowest priority task: ${lowestPriorityTask.title}" : ""}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
                if (lowestPriorityTask != null)
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await taskController.deleteTask(lowestPriorityTask!.id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Removed low priority task: ${lowestPriorityTask.title}",
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );

                      // Refresh tasks after deletion
                      refreshTasks();
                    },
                    child: const Text('Remove Low Priority'),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTaskScreen(
                          preferences: preferences!,
                          selectedDate: selectedDate,
                        ),
                      ),
                    ).then((_) => refreshTasks());
                  },
                  child: const Text('Add Anyway'),
                ),
              ],
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(
                preferences: preferences!,
                selectedDate: selectedDate,
              ),
            ),
          ).then((_) => refreshTasks());
        }
      },

      icon: const Icon(Icons.add),
      label: const Text('Create Task'),
      backgroundColor: const Color.fromARGB(255, 11, 192, 72),
      foregroundColor: Colors.white,
    ),
  ],
),);
}

  Widget _buildTodayProgress() {
    return FutureBuilder<List<TaskModel>>(
      future: taskController.getTodayTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final todayTasks = snapshot.data!;
        final completed = todayTasks.where((t) => t.isCompleted).length;
        final total = todayTasks.length;
        final progress = total > 0 ? completed / total : 0.0;

        return Container(
          padding: const EdgeInsets.all(15),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today\'s Progress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$completed / $total tasks',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? Colors.green : Colors.blue,
                ),
                minHeight: 8,
              ),
            ],
          ),
        );
      },
    );
  }
}


class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<TaskModel> tasks) {
    appointments = tasks;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  Color getColor(int index) {
    final task = appointments![index] as TaskModel;
    if (task.isCompleted) return Colors.green;
    if (task.isOverdue) return Colors.red;
    
    switch (task.priority) {
      case 3:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 1:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}