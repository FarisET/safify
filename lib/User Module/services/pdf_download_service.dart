import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:safify/constants.dart';

class PDFDownloadService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
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

    if (progress < 100) {
      await _flutterLocalNotificationsPlugin.show(
        0,
        'Starting download...',
        'Progress: $progress%',
        platformChannelSpecifics,
        payload: filepath,
      );
    } else {
      await _flutterLocalNotificationsPlugin.show(
        0,
        'Download complete',
        'File downloaded to $filepath',
        platformChannelSpecifics,
        payload: filepath,
      );
    }
  }

  Future<void> downloadPDF(
      String url, String fileName, Map<String, dynamic> queryParams) async {
    var status = await Permission.storage.request();
    final jwt = await _storage.read(key: 'jwt');
    if (jwt == null) {
      print('Error: JWT token not found');
      return;
    }

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
            // data: reqBody,
            queryParameters: queryParams,
            filePath,
            options: Options(
              headers: {
                'Authorization': 'Bearer $jwt',
              },
            ),
            onReceiveProgress: (received, total) {
              if (total != -1) {
                int progress = (received / total * 100).toInt();
                _updateNotification(progress, filePath);
              }
            },
          );
          ;
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

  Future<void> getPdf(String? day, String? month, String? year) async {
    const url = '$IP_URL/admin/dashboard/generateUserReportPDF';
    final fileName = 'user_report.pdf';
    // print("date: $day, month: $month, year: $year");

    // Construct the request body
    Map<String, dynamic> queryParams = {};

    if (day != null && month != null && year != null) {
      queryParams['date'] = '$year-$month-$day';
    } else if (year != null && month != null) {
      queryParams['year'] = year;
      queryParams['month'] = month;
    } else if (year != null) {
      queryParams['year'] = year;
    }

    print("Request body: $queryParams");
    await downloadPDF(url, fileName, queryParams);
  }
}
