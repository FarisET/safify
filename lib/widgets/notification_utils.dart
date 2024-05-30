import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var initializationSettingsAndroid = const AndroidInitializationSettings(
        '@drawable/safify_icon'); // Replace with your icon name
    var initializationSettingsIOS =
        DarwinInitializationSettings(); // Use appropriate class based on platform
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> sendNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      BuildContext context,
      String deletedReportId) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel id', // Customize channel ID
      'channel name', // Customize channel name
      channelDescription: 'Channel description', // Customize description
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Ticker',
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(); // Customize iOS details

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    final message = 'Your report (ID: $deletedReportId) was rejected.';
    await flutterLocalNotificationsPlugin.show(0, 'Report Rejected', message,
        notificationDetails); // Corrected variable name
  }
}
