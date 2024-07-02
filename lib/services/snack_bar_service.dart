import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SnackBarService {
  static void showSimpleSnackBar({
    required BuildContext context,
    required String message,
    IconData? icon,
  }) {
    DelightToastBar(
      // snackbarDuration: Duration(milliseconds: 500),
      // animationCurve: Curves.bounceIn,
      animationDuration: const Duration(milliseconds: 450),
      autoDismiss: true,

      snackbarDuration: const Duration(seconds: 10),
      builder: (context) => ToastCard(
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "swipe to\ndismiss",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(
              width: 5,
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade700)
          ],
        ),
        leading: icon == null
            ? null
            : const Icon(
                Icons.error,
                size: 28,
              ),
        title: const Text(
          "Oh no! An error occurred",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            // fontSize: 14,
          ),
        ),
      ),
    ).show(context);
  }

  static void showNoConnectionSnackBar(BuildContext context) {
    DelightToastBar(
      // snackbarDuration: Duration(milliseconds: 500),
      // animationCurve: Curves.bounceIn,
      animationDuration: const Duration(milliseconds: 450),
      autoDismiss: true,

      snackbarDuration: const Duration(seconds: 5),
      builder: (context) => const ToastCard(
        leading: Icon(
          CupertinoIcons.wifi_slash,
          size: 28,
          color: Colors.black,
        ),
        title: Text(
          "No internet connection.",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            // fontSize: 14,
          ),
        ),
      ),
    ).show(context);
  }

  static void showLocallySavedSnackBar({
    required BuildContext context,
  }) {
    DelightToastBar(
      // snackbarDuration: Duration(milliseconds: 500),
      // animationCurve: Curves.bounceIn,
      animationDuration: const Duration(milliseconds: 450),
      autoDismiss: true,

      snackbarDuration: const Duration(seconds: 10),
      builder: (context) => const ToastCard(
        leading: Icon(
          CupertinoIcons.wifi_slash,
          size: 28,
          color: Colors.black,
        ),
        subtitle: Text(
          "It'll be sent when you're back online.",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        title: Text(
          "No connection, report saved locally.",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            // fontSize: 14,
          ),
        ),
      ),
    ).show(context);
  }

  static void showCustomSnackBar({
    required BuildContext context,
    Widget? leading,
    Widget? trailing,
    Widget? content,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
    Duration duration = const Duration(seconds: 3),
    Duration animationDuration = const Duration(milliseconds: 500),
    Widget Function(BuildContext context)? builder,
    bool autoDismiss = true,
  }) {
    DelightToastBar(
      snackbarDuration: duration,
      animationDuration: animationDuration,
      autoDismiss: autoDismiss,
      builder: builder ??
          (context) => ToastCard(
                leading: leading,
                trailing: trailing,
                title: content ?? Text("", style: TextStyle(color: textColor)),
                color: backgroundColor,
              ),
    ).show(context);
  }
}
