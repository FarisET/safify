import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safify/Action%20Team%20Module/providers/all_action_reports_provider.dart';
import 'package:safify/Admin%20Module/providers/delete_action_report_provider.dart';
import 'package:safify/models/action_report.dart';
import 'package:safify/models/report.dart';

void handleImageButton(String? imageUrl, BuildContext context) {
  if (imageUrl != null) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.7, // 70% of screen width
            height: MediaQuery.of(context).size.height *
                0.7, // 70% of screen width (square box)

            // Limiting the child to the box's size and maintaining aspect ratio
            child: FittedBox(
              fit: BoxFit.contain, // Maintain aspect ratio, fit within the box
              child: CachedNetworkImage(
                imageUrl: '${imageUrl}',
              ),
            ),
          ),
        );
      },
    );
  } else {
    //    Fluttertoast.showToast(msg: 'msg');
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_not_supported_outlined,
                      size: 30, color: Colors.black),
                  SizedBox(width: 10),
                  Text('No Image Added',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              )),
        );
      },
    );
  }
}

void showRejectActionReportDialogue(BuildContext context, ActionReport item) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Reject?"),
        content: Text("Are you sure you want to reject this report?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              DeleteActionReportProvider deleteActionReportProvider =
                  Provider.of<DeleteActionReportProvider>(context,
                      listen: false);

              deleteActionReportProvider
                  .deleteActionReport('${item.action_report_id}')
                  .then((success) async {
                if (success) {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.greenAccent,
                    content: Text('Report deleted'),
                    duration: Duration(seconds: 2),
                  ));
                  await Provider.of<ActionReportsProvider>(context,
                          listen: false)
                      .fetchAllActionReports(context);

                  //PUSH NOTIFICATION
                }
              });
            },
            child: Text("Confirm"),
          ),
        ],
      );
    },
  );
}
