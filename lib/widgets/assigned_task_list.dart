// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safify/User%20Module/pages/login_page.dart';
import 'package:safify/components/custom_button.dart';
import 'package:safify/services/UserServices.dart';
import 'package:safify/utils/alerts_util.dart';
import 'package:safify/utils/button_utils.dart';
import 'package:safify/utils/string_utils.dart';
import 'package:safify/widgets/assigned_task_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Action Team Module/pages/action_report_form.dart';
import '../Action Team Module/providers/fetch_assigned_tasks_provider.dart';

class AssignedTaskList extends StatefulWidget {
  const AssignedTaskList({super.key});

  @override
  State<AssignedTaskList> createState() => _AssignedTaskListState();
}

class _AssignedTaskListState extends State<AssignedTaskList> {
  @override
  void initState() {
    super.initState();
    Provider.of<AssignedTaskProvider>(context, listen: false)
        .fetchAssignedTasks(context);
  }

  void _handleSessionExpired(BuildContext context) async {
    UserServices userServices = UserServices();
    bool res = await userServices.logout();
    if (res) {
      // Logout successful, show alert and wait for user interaction
      Alerts.customAlertTokenWidget(
        context,
        "Your session expired or timed-out, please log in to continue.",
        () {
          // Navigator to login page only when user clicks "Close"
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
      );
    } else {
      // Handle logout failure if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(child:
        Consumer<AssignedTaskProvider>(builder: (context, assignProvider, _) {
      if (assignProvider.error != null) {
        if (assignProvider.error!.contains('TokenExpiredException')) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _handleSessionExpired(context));
          return Text("Failed to load tasks, session expired.");
        }
        if (assignProvider.error!.contains('SocketException')) {
          return SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  color: Colors.grey.shade700,
                ),
                SizedBox(width: 8.0),
                Flexible(
                  child: Text("Please check your internet connection."),
                ),
              ],
            ),
          );
        }
      }
      if (assignProvider.tasks.isNotEmpty) {
        return ListView.builder(
          itemCount: assignProvider.tasks.length,
          itemBuilder: (context, i) {
            var item = assignProvider.tasks[i];

            return AssignedTaskTile(task: item);
          },
        );
      } else if (assignProvider.tasks.isEmpty && assignProvider.isLoading) {
        return CircularProgressIndicator();
      }
      return Text('No active tasks!');
    }));
  }
  // padding: const EdgeInsets.only(bottom:8.0),
  //child: Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  // //       border: Border(
  // //       left: BorderSide(
  // //     color: status!=null && status ? Colors.green : Colors.red,
  // //     width: 1.0, // Adjust the width as needed
  // //   ),
  // // ),
  //     ),
}
