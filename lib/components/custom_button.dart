import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class AbstractButton extends StatelessWidget {
  final String buttonText;
  final IconData iconData;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final void Function() onTap;
  final double? width;
  final double? height;
  final double gap;
  final double iconSize;
  final double borderRadius;

  const AbstractButton({
    required this.buttonText,
    required this.iconData,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
    this.width,
    this.height,
    this.gap = 10,
    this.iconSize = 16,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: backgroundColor),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal:
                    MediaQuery.of(context).size.width < 390 ? 6.0 : 12.0,
                vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, size: 16, color: iconColor),
                SizedBox(width: gap),
                Text(
                  buttonText,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: textColor),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AssignButton extends AbstractButton {
  static const Color fixedIconColor = Colors.black; // Fixed color for the icon
  static const Color fixedTextColor = Colors.black; // Fixed color for the text

  AssignButton({
    required bool isAssigned,
    // String buttonText = 'Assign',
    IconData iconData = Icons.person_add,
    required void Function() onTap,
    double? width,
    double? height,
    double gap = 10,
    double iconSize = 16,
    double borderRadius = 10,
  }) : super(
          buttonText: isAssigned ? 'Assigned' : 'Assign',
          iconData: iconData,
          iconColor: fixedIconColor,
          textColor: fixedTextColor,
          backgroundColor: Colors.grey.shade50,
          onTap: onTap,
          width: width,
          height: height,
          gap: gap,
          iconSize: iconSize,
          borderRadius: borderRadius,
        );
}

class DeleteButton extends AbstractButton {
  static const Color fixedIconColor = Colors.black; // Fixed color for the icon
  static const Color fixedTextColor = Colors.black; // Fixed color for the text

  DeleteButton({
    required void Function() onTap,
    double? width,
    double? height,
    double gap = 10,
    double iconSize = 16,
    double borderRadius = 10,
  }) : super(
          buttonText: 'Delete',
          iconData: Icons.delete,
          iconColor: fixedIconColor,
          textColor: fixedTextColor,
          backgroundColor: Colors.grey.shade50,
          onTap: onTap,
          width: width,
          height: height,
          gap: gap,
          iconSize: iconSize,
          borderRadius: borderRadius,
        );
}

class ImageButton extends AbstractButton {
  static const Color fixedIconColor = Colors.black; // Fixed color for the icon
  static const Color fixedTextColor = Colors.black; // Fixed color for the text

  ImageButton({
    required void Function() onTap,
    double? width,
    double? height,
    double gap = 10,
    double iconSize = 16,
    double borderRadius = 10,
  }) : super(
          buttonText: 'Image',
          iconData: Icons.image,
          iconColor: fixedIconColor,
          textColor: fixedTextColor,
          backgroundColor: Colors.grey.shade50,
          onTap: onTap,
          width: width,
          height: height,
          gap: gap,
          iconSize: iconSize,
          borderRadius: borderRadius,
        );
}

class ApproveButton extends AbstractButton {
  static const Color fixedIconColor = Colors.black; // Fixed color for the icon
  static const Color fixedTextColor = Colors.black; // Fixed color for the text

  ApproveButton({
    required bool isApproved,
    // String buttonText = 'Assign',
    required void Function() onTap,
    double? width,
    double? height,
    double gap = 10,
    double iconSize = 16,
    double borderRadius = 10,
  }) : super(
          buttonText: isApproved ? 'Approved' : 'Approve',
          iconData: isApproved ? Icons.done_all : Icons.done,
          iconColor: fixedIconColor,
          textColor: fixedTextColor,
          backgroundColor: Colors.grey.shade50,
          onTap: onTap,
          width: width,
          height: height,
          gap: gap,
          iconSize: iconSize,
          borderRadius: borderRadius,
        );
}

class RejectButton extends AbstractButton {
  static const Color fixedIconColor = Colors.black; // Fixed color for the icon
  static const Color fixedTextColor = Colors.black; // Fixed color for the text

  RejectButton({
    required void Function() onTap,
    double? width,
    double? height,
    double gap = 10,
    double iconSize = 16,
    double borderRadius = 10,
  }) : super(
          buttonText: 'Reject',
          iconData: Icons.close_rounded,
          iconColor: fixedIconColor,
          textColor: fixedTextColor,
          backgroundColor: Colors.grey.shade50,
          onTap: onTap,
          width: width,
          height: height,
          gap: gap,
          iconSize: iconSize,
          borderRadius: borderRadius,
        );
}
