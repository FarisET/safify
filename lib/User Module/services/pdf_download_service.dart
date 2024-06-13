import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class PDFDownloadService {
  final Dio _dio = Dio();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  PDFDownloadService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Channel for showing download progress',
      importance: Importance.max,
      priority: Priority.high,
      showProgress: true,
      onlyAlertOnce: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  Future<void> _updateNotification(int progress) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Channel for showing download progress',
      importance: Importance.max,
      priority: Priority.high,
      showProgress: true,
      onlyAlertOnce: true,
      maxProgress: 100,
      progress: progress,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0, 'Downloading PDF', 'Progress: $progress%', platformChannelSpecifics);
  }

  Future<void> downloadPDF(String url, String fileName) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        String newPath = "${directory.path}/PDF_Downloads";
        directory = Directory(newPath);

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        String filePath = "${directory.path}/$fileName";

        try {
          await _showNotification('Starting download', 'Downloading PDF...');
          await _dio.download(
            url,
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                int progress = (received / total * 100).toInt();
                _updateNotification(progress);
              }
            },
          );
          await _showNotification(
              'Download complete', 'File downloaded to $filePath');
        } catch (e) {
          await _showNotification(
              'Download failed', 'Error downloading file: $e');
        }
      } else {
        await _showNotification(
            'Directory error', 'Unable to access storage directory');
      }
    } else {
      await _showNotification('Permission denied',
          'Storage permission is required to download files');
    }
  }
}
