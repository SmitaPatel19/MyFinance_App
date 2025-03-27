import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    log("Notifications Initialized");
  }

  Future<void> scheduleNotification() async {
    log("Trying to Schedule Notification...");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      "Payment Reminder",
      "You have a payment due soon!",
      tz.TZDateTime.now(tz.local)
          .add(const Duration(seconds: 5)), // Trigger after 5 sec
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    log("✅ Notification Scheduled");
  }

  Future<void> showTestNotification() async {
    log("Showing Test Notification...");
    await flutterLocalNotificationsPlugin.show(
      0,
      "Notification",
      "This is a remainder that notifications are scheduled!",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
    log("Test Notification Sent");
  }
}