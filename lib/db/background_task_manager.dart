import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:safify/db/database_helper.dart';
import 'package:safify/models/action_report_form_details.dart';
import 'package:safify/models/user_report_form_details.dart';
import 'package:safify/services/ReportServices.dart';
import 'package:safify/utils/network_util.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundTaskManager {
  // Private constructor
  BackgroundTaskManager._privateConstructor();

  // Static instance
  static final BackgroundTaskManager _instance =
      BackgroundTaskManager._privateConstructor();

  // Factory constructor to return the same instance
  factory BackgroundTaskManager() {
    return _instance;
  }

  Future<void> initializeWorkManager() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }

  void registerSyncUserFormTask() {
    Workmanager().registerPeriodicTask(
      "1",
      "syncUserFormReports",
      frequency: const Duration(minutes: 15),
    );
  }

  void registerSyncActionFormTask() {
    Workmanager().registerPeriodicTask(
      "3",
      "syncActionFormReports",
      frequency: const Duration(minutes: 15),
    );
  }

  void registerAnotherTask() {
    Workmanager().registerOneOffTask(
      "2",
      "anotherTask",
    );
  }

  void cancelTask(String uniqueTaskName) async {
    Workmanager().cancelByUniqueName(uniqueTaskName).then((value) {
      print("Task $uniqueTaskName cancelled");
    });
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputDataMap) async {
    switch (taskName) {
      case "syncUserFormReports":
        print("Executing syncUserFormReports task...");
        await uploadUserFormReports();
        break;
      case "anotherTask":
        print("Executing anotherTask...");
        await anotherTask();
        break;
      case "syncActionFormReports":
        print("Executing syncActionFormReports task...");
        await uploadActionReportForms();
        break;
      default:
        print("Unknown task: $taskName");
    }
    return Future.value(true);
  });
}

Future<void> anotherTask() async {
  print("doing something random...");
}

Future<void> uploadUserFormReports() async {
  print("uploading reports...");
  final pingSuccess = await ping_google();
  if (!pingSuccess) {
    print("Backend is unreachable. Retrying later...");
    return;
  }
  final dbHelper = await DatabaseHelper();

  final Map<int, UserReportFormDetails> reports =
      await dbHelper.getUserFormReports();

  if (reports.isEmpty) {
    print("No reports to upload");
    return;
  }

  final reportService = ReportServices();

  for (var entry in reports.entries) {
    int id = entry.key;
    UserReportFormDetails report = entry.value;
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

Future<void> uploadActionReportForms() async {
  print("uploading action reports...");
  final pingSuccess = await ping_google();
  if (!pingSuccess) {
    print("Backend is unreachable. Retrying later...");
    return;
  }
  final dbHelper = await DatabaseHelper();

  final Map<int, ActionReportFormDetails> reports =
      await dbHelper.getActionFormReports();

  if (reports.isEmpty) {
    print("No reports to upload");
    return;
  }

  final reportService = ReportServices();
  for (var entry in reports.entries) {
    int id = entry.key;
    ActionReportFormDetails report = entry.value;
    int uploadSuccess = -1;
    try {
      if (report.incidentSiteImgPath != null) {
        uploadSuccess = await reportService.uploadActionReportWithImagesFuture(
          report.incidentDesc,
          report.rootCause1,
          report.rootCause2,
          report.rootCause3,
          report.rootCause4,
          report.rootCause5,
          report.resolutionDesc,
          report.reportedBy,
          XFile(report.incidentSiteImgPath!),
          XFile(report.workProofImgPath),
          report.userReportId,
        );
      } else {
        uploadSuccess = await reportService.postActionReport(
          report.incidentDesc,
          report.rootCause1,
          report.rootCause2,
          report.rootCause3,
          report.rootCause4,
          report.rootCause5,
          report.resolutionDesc,
          report.reportedBy,
          XFile(report.workProofImgPath),
          report.userReportId,
        );
      }
    } catch (e) {
      rethrow;
    }

    if (uploadSuccess == 1) {
      await dbHelper.deleteActionFormReport(id);
      print("Report successfully sent and deleted from local database");
    } else {
      print("Report failed to send. Retrying later...: error:$uploadSuccess");
    }
  }
}
