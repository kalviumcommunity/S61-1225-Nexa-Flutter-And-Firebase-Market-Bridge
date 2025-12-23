import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'fcm_channel',
      'FCM Notifications',
      description: 'Channel for FCM notifications',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void show(String title, String body) {
    const androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    _plugin.show(0, title, body, details);
  }
}
