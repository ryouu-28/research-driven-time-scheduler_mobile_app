import 'package:flutter/material.dart';
import 'package:research_driven_time_scheduler_mobile_app/main.dart';
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
  
  List<TaskModel> tasks = [];
  UserPreferencesModel? preferences;
  CalendarView currentView = CalendarView.week;
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFAEADAD),
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TaskScheduleHome()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Reset Data"),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Reset'),
                    content: const Text(
                      'Are you sure you want to delete all survey data? This action cannot be undone.',
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
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to settings screen
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
                fit: BoxFit.cover, // fills the space
              ),
            ),
            child: SfCalendar(
              key: ValueKey(currentView), // keeps view switching working
              view: currentView,
            
              //Month Style
              headerStyle: const CalendarHeaderStyle(
                textStyle: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Montserrat',
                  fontWeight:  FontWeight.bold,
                  backgroundColor: Color.fromARGB(43, 98, 120, 138),
                  decorationColor: Color.fromARGB(43, 98, 120, 138),
                ),),

              viewHeaderStyle: const ViewHeaderStyle(
                dayTextStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.green, // day names color
                  fontFamily: 'Montserrat',
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
                timeIntervalHeight: 50,
                timeTextStyle: TextStyle(
                  fontSize: 12,
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
    ElevatedButton.icon(
        onPressed: () async {
          // Make sure NotificationService is initialized somewhere (e.g. in main.dart)
          // await NotificationService().showNotification(
          //   '🔔 Task Reminder',
          //   'This is your test notification from Task Home!',
          // );
          await NotificationService().openExactAlarmSettings();
        },
        icon: const Icon(Icons.notifications_active),
        label: const Text(
          'Send Test Notification',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // button color
          foregroundColor: Colors.white, // text/icon color
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

    const SizedBox(height: 10),
    FloatingActionButton.extended(
      onPressed: () async {
        final todayTasks =
            await taskController.getTasksForDate(DateTime.now());

        if (preferences != null &&
            todayTasks.length >= preferences!.maxDailyTasks) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Daily Limit Reached'),
              content: Text(
                'You\'ve reached your daily limit of '
                '${preferences!.maxDailyTasks} tasks. '
                'Consider completing existing tasks first!',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
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