import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  }

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

  Future<void> showNotification(String title, String body) async {
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
      print('✅ Notification shown: $title');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    try {
      if (scheduledTime.isBefore(DateTime.now())) {
        print('⏭️ Scheduled time is in the past, showing instant notification');
        await showNotification(title, body);
        return;
      }

      await flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.everyMinute,
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
      );
      
      print('✅ Scheduled notification for: $scheduledTime');
    } catch (e) {
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
    );
  }
}