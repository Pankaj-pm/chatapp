import 'package:chatapp/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> showNotification(int id, String title, String msg) async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  flutterLocalNotificationsPlugin.show(
    id,
    title,
    msg,
    NotificationDetails(
      android: AndroidNotificationDetails(
        "channelId",
        "channelName",
        priority: Priority.max,
        importance: Importance.max,
      ),
    ),
  );
}

Future<void> showScheduleNotification(int id, String title, String msg) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    msg,
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
    const NotificationDetails(
        android: AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description')),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}
