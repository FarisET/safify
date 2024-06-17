import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Alerts {
  static void showAlertDialog(BuildContext context, String responseText) {
    customAlertWidget(context, responseText, () {});
  }

  static void customAlertTokenWidget(
    BuildContext context,
    String responseText,
    VoidCallback onClose,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(
          responseText,
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              "Close",
            ),
            onPressed: () {
              Navigator.pop(context);
              onClose(); // Call the callback to handle the action
            },
          ),
        ],
      ),
    );
  }

  // Original customAlertWidget
  static void customAlertWidget(
      BuildContext context, String responseText, Null Function() param2) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(
          responseText,
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              "OK",
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissal by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Loading...'),
              ],
            ),
          ),
        );
      },
    );
  }
}
