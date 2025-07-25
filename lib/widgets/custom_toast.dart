import 'package:flutter/material.dart';

/// ToastCard widget to display decent and rich looking snackbar
class CustomToast extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color? color;
  final Color? shadowColor;
  final Function()? onTap;
  const CustomToast(
      {super.key,
      required this.title,
      this.subtitle,
      this.leading,
      this.color,
      this.shadowColor,
      this.trailing,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
      ),
      child: Material(
        elevation: 5,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(width > 750 ? 10 : 15),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
              color: color ?? Theme.of(context).dialogBackgroundColor,
              // borderRadius: BorderRadius.circular(15),

              boxShadow: [
                BoxShadow(
                    blurRadius: 10,
                    spreadRadius: 3,
                    offset: Offset.zero,
                    color: shadowColor ?? Colors.black.withOpacity(0.05))
              ]),
          child: ListTile(
            contentPadding: const EdgeInsets.all(7),
            leading: Padding(
              padding: const EdgeInsets.all(10.0),
              child: leading,
            ),
            trailing: trailing,
            subtitle: subtitle,
            title: title,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
