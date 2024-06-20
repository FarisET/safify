import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class AbstractButton extends StatelessWidget {
  final String buttonText;
  final IconData iconData;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final void Function() onTap;

  const AbstractButton({
    required this.buttonText,
    required this.iconData,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: backgroundColor,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 390 ? 6.0 : 12.0,
              vertical: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iconData,
                  size: 16,
                  color: iconColor,
                ),
                SizedBox(width: 10),
                Text(
                  buttonText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
