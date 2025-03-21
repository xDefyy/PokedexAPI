import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//tutorial seguido de https://www.youtube.com/watch?v=uKz8tWbMuUw

class NotiService {
  final notifactionsPlugin = FlutterLocalNotificationsPlugin();

  bool isInitialized = false;

  bool get initialized => isInitialized;

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidInit);

    await notifactionsPlugin.initialize(initSettings);
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
      'daily_channel_id',
      'Daily Notifications',
      channelDescription: 'Daily Notifications Channel',
      importance: Importance.max,
      priority: Priority.high,
    ));
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    await notifactionsPlugin.show(id, title, body, notificationDetails());
  }
}
