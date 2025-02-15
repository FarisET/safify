import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safify/db/database_helper.dart';
import 'package:safify/models/user_report_form_details.dart';
import 'package:safify/services/report_service.dart';
import 'package:safify/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:safify/utils/network_util.dart';

class ReportHandler {
  Future<int> handleReportSubmitted(BuildContext context,
      State<StatefulWidget> userFormState, XFile? selectedImage) async {
    if (userFormState.mounted) {
      userFormState.setState(() {
        (userFormState as dynamic).isSubmitting = true;
      });
    }

    DatabaseHelper databaseHelper = DatabaseHelper();
    var maps = await databaseHelper.getAllUserReports();

    for (var map in maps) {
      print(map);
    }

    final pingSuccess = await ping_google();
    if (!pingSuccess) {
      return await _saveReportLocally(userFormState, selectedImage);
    }

    try {
      ReportServices reportServices = ReportServices();
      int flag;

      if (selectedImage != null) {
        flag = await reportServices.uploadReportWithImage(
          (userFormState as dynamic).returnedImage?.path,
          (userFormState as dynamic).SelectedSubLocationType,
          (userFormState as dynamic).incidentSubType,
          (userFormState as dynamic).description,
          (userFormState as dynamic).date,
          (userFormState as dynamic).risklevel,
        );
      } else {
        flag = await reportServices.postReport(
          (userFormState as dynamic).SelectedSubLocationType,
          (userFormState as dynamic).incidentSubType,
          (userFormState as dynamic).description,
          (userFormState as dynamic).date,
          (userFormState as dynamic).risklevel,
        );
      }

      if (userFormState.mounted) {
        userFormState.setState(() {
          (userFormState as dynamic).isSubmitting = false;
        });
      }

      return flag;
    } catch (e) {
      return await _saveReportLocally(userFormState, selectedImage);
    }
  }

  Future<int> _saveReportLocally(
      State<StatefulWidget> userFormState, XFile? selectedImage) async {
    final tempImgPath = selectedImage != null
        ? await saveImageTempLocally(File(selectedImage.path))
        : null;

    final userFormReport = UserReportFormDetails(
      sublocationId: (userFormState as dynamic).SelectedSubLocationType,
      incidentSubtypeId: (userFormState as dynamic).incidentSubType,
      description: (userFormState as dynamic).description,
      date: (userFormState as dynamic).date,
      criticalityId: (userFormState as dynamic).risklevel,
      imagePath: tempImgPath,
    );

    final dbHelper = DatabaseHelper();
    await dbHelper.insertUserFormReport(userFormReport);

    if (userFormState.mounted) {
      userFormState.setState(() {
        (userFormState as dynamic).isSubmitting = false;
      });
    }

    print("Failed to send, report saved locally");
    return 4;
  }
}
