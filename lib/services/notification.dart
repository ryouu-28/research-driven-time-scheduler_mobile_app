import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/taskModel.dart';
import '../models/userPreferencesModel.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Get local timezone
      final String timeZoneName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation('Asia/Manila')); // Change to your timezone

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
        onDidReceiveNotificationResponse: onNotificationTap,
      );

      _initialized = true;
      print('✅ Notifications initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  void onNotificationTap(NotificationResponse notificationResponse) {
    print('Notification tapped: ${notificationResponse.payload}');
    // Handle notification tap - navigate to task detail
  }

  Future<bool> requestPermissions() async {
    try {
      // Android 13+ permissions
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedAndroid =
          await androidImplementation?.requestNotificationsPermission();

      // iOS permissions
      final DarwinFlutterLocalNotificationsPlugin? iosImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  DarwinFlutterLocalNotificationsPlugin>();

      final bool? grantedIOS = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      print('📱 Notification permissions: Android: $grantedAndroid, iOS: $grantedIOS');
      return grantedAndroid ?? grantedIOS ?? false;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> scheduleTaskReminder(
    TaskModel task,
    UserPreferencesModel preferences,
  ) async {
    if (!preferences.needsReminders) {
      print('⏭️ Reminders disabled by user');
      return;
    }

    try {
      final reminderTime = task.startTime.subtract(
        Duration(minutes: preferences.reminderMinutesBefore),
      );

      // Only schedule if reminder time is in the future
      if (reminderTime.isBefore(DateTime.now())) {
        print('⏭️ Reminder time is in the past, skipping');
        return;
      }

      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        reminderTime,
        tz.local,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id.hashCode, // Unique ID
        '⏰ Task Reminder',
        '${task.title} starts in ${preferences.reminderMinutesBefore} minutes!',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for upcoming tasks',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id,
      );

      print('✅ Scheduled reminder for: ${task.title} at $reminderTime');
    } catch (e) {
      print('❌ Error scheduling task reminder: $e');
    }
  }

  Future<void> scheduleDailyMorningDigest(
    UserPreferencesModel preferences,
  ) async {
    if (!preferences.needsReminders) return;

    try {
      // Schedule for 8 AM daily
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, 8, 0);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // Fixed ID for daily digest
        '🌅 Good Morning!',
        preferences.motivationalMessage,
        scheduledTZ,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_digest',
            'Daily Digest',
            channelDescription: 'Daily morning motivational message',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Scheduled daily morning digest');
    } catch (e) {
      print('❌ Error scheduling morning digest: $e');
    }
  }

  Future<void> showInstantNotification(String title, String body) async {
    try {
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
      );
      print('✅ Instant notification shown: $title');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  Future<void> cancelTaskReminder(String taskId) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
      print('✅ Cancelled reminder for task: $taskId');
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

  // Test notification
  Future<void> showTestNotification() async {
    await showInstantNotification(
      '🎉 Test Notification',
      'Your notifications are working perfectly!',
    );
  }
}