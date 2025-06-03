import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialised => _isInitialized;

  Future<void> initNotifications() async {
    if (_isInitialized) return;

  

    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await notificationsPlugin.initialize(initSettings);
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        "daily_chanel_id",
        "Daily Notifications",
        channelDescription: "Daily Chanel Description",
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    String? payload,
  }) async {
    return notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showTestNotification() async {
    await notificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification',
      notificationDetails(),
    );
  }

  Future<List<PendingNotificationRequest>> pendingNotificationRequests() =>
      FlutterLocalNotificationsPlatform.instance.pendingNotificationRequests();

  Future<void> checkPendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await this.pendingNotificationRequests();
    return log(
      'waiting notifications ${pendingNotificationRequests.length.toString()}',
    );
  }
}
