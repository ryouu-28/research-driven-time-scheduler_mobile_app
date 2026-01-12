import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:research_driven_time_scheduler_mobile_app/models/taskModel.dart';
import 'package:timezone/timezone.dart' as tz;
import '../controllers/taskController.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  TaskController taskController = TaskController();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        // onDidReceiveNotificationResponse: onNotificationTap,
      );
      await flutterLocalNotificationsPlugin.cancelAll();

      _initialized = true;
      print('✅ Notifications initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  // /// ✅ Refactored: no navigation, just log the tap
  // void onNotificationTap(NotificationResponse notificationResponse) async {
  //   // final payload = notificationResponse.payload;
  //   print('Notification tapped: $payload');
  //   // Do nothing else — no navigation
  // }

  Future<bool> requestPermissions() async {
    try {
      bool granted = false;

      if (flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>() !=
          null) {
        final AndroidFlutterLocalNotificationsPlugin androidImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()!;

        final bool? grantedAndroid =
            await androidImplementation.requestNotificationsPermission();
        granted = grantedAndroid ?? false;
        print('📱 Android notification permission: $granted');
      }

      if (flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>() !=
          null) {
        final IOSFlutterLocalNotificationsPlugin iosImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>()!;

        final bool? grantedIOS = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = grantedIOS ?? false;
        print('📱 iOS notification permission: $granted');
      }

      return granted;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> scheduleTaskWithStartAndEnd(TaskModel task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.hashCode,
      'Task Starting',
      '${task.title} is starting now!',
      tz.TZDateTime.from(task.startTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_start_channel',
          'Task Start Notifications',
          channelDescription: 'Notifies when a task starts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
      // payload: 'task:${task.id}',
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.hashCode + 1,
      'Task Completed',
      '${task.title} has ended!',
      tz.TZDateTime.from(task.endTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_end_channel',
          'Task End Notifications',
          channelDescription: 'Notifies when a task ends',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
      // payload: 'task:${task.id}',
    );

    print('✅ Scheduled start and end notifications for ${task.title}');
  }

  Future<void> showNotification(String title, String body, String taskID) async {
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notifications',
          'Instant Notifications',
          channelDescription: 'Immediate notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      // payload: 'task:$taskID',
    );
  }

  Future<void> openExactAlarmSettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    await intent.launch();
  }

  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
    String taskID,
  ) async {
    try {
      if (scheduledTime.isBefore(DateTime.now())) {
        print('⏭️ Scheduled time is in the past, showing instant notification');
        await showNotification(title, body, id.toString());
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'scheduled_notifications',
            'Scheduled Notifications',
            channelDescription: 'Scheduled task notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
        // payload: 'task:$taskID',
      );

      print('✅ Scheduled notification for: $scheduledTime');
    } catch (e) {
      if (e is PlatformException && e.code == 'exact_alarms_not_permitted') {
        print('⚠️ Opening exact alarm settings for user...');
        await openExactAlarmSettings();
      }
      print('❌ Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
      print('✅ Cancelled notification: $id');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  Future<void> showTestNotification() async {
    await showNotification(
      '🎉 Test Notification',
      'Your notifications are working perfectly!',
      '0',
    );
  }
}
