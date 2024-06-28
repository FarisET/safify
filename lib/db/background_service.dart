import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:safify/db/database_helper.dart';
import 'package:safify/models/user_form_report.dart';
import 'package:safify/services/ReportServices.dart';
import 'package:safify/utils/network_util.dart';

Future<void> initiazizeService() async {
  print("Initializing service...");
  final service = FlutterBackgroundService();

  await service.configure(
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        autoStart: true,
        onBackground: onIosBackgroundService,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: false,
        autoStart: true,
      ));
  print("Service initialized...");
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen(
      (event) {
        service.setAsForegroundService();
      },
    );
    service.on('setAsBackground').listen(
      (event) {
        service.setAsBackgroundService();
      },
    );
  }
  service.on('stopService').listen((event) async {
    print("Stopping service...");
    await service.stopSelf();
    print("Service stopped...");
  });
  // startAddingRows();
  syncUserFormReports();
  // Timer.periodic(
  //   const Duration(seconds: 5),
  //   (timer) async {
  //     if (service is AndroidServiceInstance) {
  //       if (await service.isForegroundService()) {
  //         service.setForegroundNotificationInfo(
  //             title: "tesigin", content: "helppp");
  //       }
  //     }

  //     print("backgroung task running... ");
  //     service.invoke('update');
  //   },
  // );
}

@pragma('vm:entry-point')
Future<bool> onIosBackgroundService(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

void startAddingRows() {
  Timer.periodic(const Duration(seconds: 5), (timer) {
    // Get current time
    String currentTime = DateTime.now().toIso8601String();

    // Insert into database
    final dbHelper = DatabaseHelper();
    dbHelper.insertTime(currentTime);

    print('Added row at $currentTime');
  });
}

/// Sync user form reports evert 15 seconds
Future<void> syncUserFormReports() async {
  Timer.periodic(const Duration(seconds: 15), (timer) async {
    await uploadUserFormReports();
  });
}

Future<void> uploadUserFormReports() async {
  print("uploading reports...");
  final pingSuccess = await ping_google();
  if (!pingSuccess) {
    print("Backend is unreachable. Retrying later...");
    return;
  }
  final dbHelper = await DatabaseHelper();

  final Map<int, UserFormReport> reports = await dbHelper.getUserFormReports();

  if (reports.isEmpty) {
    print("No reports to upload");
    return;
  }

  final reportService = ReportServices();

  for (var entry in reports.entries) {
    int id = entry.key;
    UserFormReport report = entry.value;
    int uploadSuccess = -1;
    try {
      if (report.imagePath != null) {
        uploadSuccess = await reportService.uploadReportWithImage(
            report.imagePath,
            report.sublocationId,
            report.incidentSubtypeId,
            report.description,
            report.date,
            report.criticalityId);
      } else {
        uploadSuccess = await reportService.postReport(
            report.sublocationId,
            report.incidentSubtypeId,
            report.description,
            report.date,
            report.criticalityId);
      }
    } catch (e) {
      rethrow;
    }

    if (uploadSuccess == 1) {
      await dbHelper.deleteUserFormReport(id);
      print("Report successfully sent and deleted from local database");
    } else {
      print("Report failed to send. Retrying later...: error:$uploadSuccess");
    }
  }
}
