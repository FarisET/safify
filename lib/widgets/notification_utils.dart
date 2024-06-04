import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class Notifications {
  late FirebaseMessaging firebaseMessaging;

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

  Future<String?> updateTokenToServer() async {
    try {
      await Firebase.initializeApp();

      String? token = await FirebaseMessaging.instance.getToken();
      print("Firebase Messaging Token: $token");

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        // Handle the new token here, if necessary
        print("New Firebase Messaging Token: $newToken");
        // Optionally send the new token to your backend server
      });

      return token;
    } catch (e) {
      print("Error getting Firebase Messaging Token: $e");
      return null;
    }
  }
}
