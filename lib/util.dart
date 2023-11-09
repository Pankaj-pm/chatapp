// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:chatapp/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:http/http.dart' as http;

Future<void> showNotification(int id, String title, String msg, {String? imgUrl}) async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  String _bitmapPath = await downloadAndSaveFile(
      "https://rukminim1.flixcart.com/fk-p-flap/450/280/image/269eb35d0da4d88b.jpeg", "test.jpg");

  flutterLocalNotificationsPlugin.show(
    id,
    title,
    msg,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        priority: Priority.max,
        importance: Importance.max,
        // styleInformation: BigPictureStyleInformation(
        //   FilePathAndroidBitmap(_bitmapPath),
        //   largeIcon: FilePathAndroidBitmap(_bitmapPath),
        // ),
        largeIcon: FilePathAndroidBitmap(_bitmapPath),
        styleInformation: MediaStyleInformation(
          htmlFormatContent: true,
          htmlFormatTitle: true,
        ),
      ),
    ),
  );
}

Future<String> downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<void> showScheduleNotification(int id, String title, String msg) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    msg,
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
    const NotificationDetails(
        android: AndroidNotificationDetails(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      channelDescription: 'your channel description',
    )),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}
