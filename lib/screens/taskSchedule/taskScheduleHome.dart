import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' hide CalendarSelectionDetails;
import '../../controllers/taskController.dart';
import '../../controllers/preferencesController.dart';
import '../../models/taskModel.dart';
import '../../models/userPreferencesModel.dart';
import 'addTaskScreen.dart';
import 'taskDetailScreen.dart';

class TaskScheduleHome extends StatefulWidget {
  const TaskScheduleHome({super.key});

  @override
  State<TaskScheduleHome> createState() => _TaskScheduleHomeState();
}

class _TaskScheduleHomeState extends State<TaskScheduleHome> {
  final TaskController taskController = TaskController();
  final PreferencesController prefsController = PreferencesController();
  
  List<TaskModel> tasks = [];
  UserPreferencesModel? preferences;
  CalendarView currentView = CalendarView.day;
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
        title: const Text('My Schedule'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_day),
            onPressed: () {
              setState(() {
                currentView = CalendarView.day;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.view_week),
            onPressed: () {
              setState(() {
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
      body: Column(
        children: [
          // Motivational Banner
          if (preferences != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              color: Colors.blue.shade50,
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
            child: SfCalendar(
              view: currentView,
              dataSource: TaskDataSource(tasks),
              onTap: (CalendarTapDetails details) {
                if (details.appointments != null && 
                    details.appointments!.isNotEmpty) {
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
                startHour: 6,
                endHour: 23,
                timeInterval: Duration(minutes: 30),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final todayTasks = await taskController.getTasksForDate(DateTime.now());
          
          if (preferences != null && 
              todayTasks.length >= preferences!.maxDailyTasks) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Daily Limit Reached'),
                content: Text(
                  'You\'ve reached your daily limit of ${preferences!.maxDailyTasks} tasks. '
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
        label: const Text('Add Task'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
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

// Calendar Data Source
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