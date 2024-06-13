import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PDFDownloadService {
  final Dio _dio = Dio();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  PDFDownloadService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        final String? payload = notificationResponse.payload;
        if (payload != null) {
          print('Payload: $payload');
          await OpenFile.open(payload);
        }
      },
    );
  }

  Future<void> _showNotification(String title, String body,
      {String? filePath}) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Channel for showing download progress',
      importance: Importance.max,
      priority: Priority.high,
      showProgress: true,
      onlyAlertOnce: true,
      additionalFlags:
          Int32List.fromList(<int>[0x01000000]), // FLAG_UPDATE_CURRENT
      enableVibration: false,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: filePath);
  }

  Future<void> _updateNotification(int progress, String filepath) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
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

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
        0, 'Downloading PDF', 'Progress: $progress%', platformChannelSpecifics,
        payload: filepath);
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
        int counter = 1;
        String baseName = fileName;
        String extension = '';

        if (fileName.contains('.')) {
          baseName = fileName.substring(0, fileName.lastIndexOf('.'));
          extension = fileName.substring(fileName.lastIndexOf('.'));
        }

        while (await File(filePath).exists()) {
          filePath = "${directory.path}/${baseName}_$counter$extension";
          counter++;
        }

        print(filePath);

        try {
          await _showNotification('Starting download', 'Downloading PDF...');
          await _dio.download(
            url,
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                int progress = (received / total * 100).toInt();
                _updateNotification(progress, filePath);
              }
            },
          );
          await _showNotification(
              'Download complete', 'File downloaded to $filePath',
              filePath: filePath);
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
