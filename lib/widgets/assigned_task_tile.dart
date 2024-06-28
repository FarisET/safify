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
import 'package:shared_preferences/shared_preferences.dart';

import '../Action Team Module/pages/action_report_form.dart';
import '../Action Team Module/providers/fetch_assigned_tasks_provider.dart';

class AssignedTaskTile extends StatefulWidget {
  const AssignedTaskTile({super.key});

  @override
  State<AssignedTaskTile> createState() => _AssignedTaskTileState();
}

class _AssignedTaskTileState extends State<AssignedTaskTile> {
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
      if (assignProvider.error != null &&
          assignProvider.error!.contains('TokenExpiredException')) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _handleSessionExpired(context));
      }
      if (assignProvider.tasks.isNotEmpty) {
        return ListView.builder(
          itemCount: assignProvider.tasks.length,
          itemBuilder: (context, i) {
            var item = assignProvider.tasks[i];

            return Card(
                color: Colors.white,
                // color: item.status!.contains('open')
                //     ? Colors.red[50]
                //     : (item.status!.contains('in progress')
                //         ? Colors.orange[50]
                //         : Colors.green[50]),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                // side: BorderSide(
                //   // color: item.status!.contains('open')?Colors.redAccent:Colors.greenAccent,
                //    width:1)),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.incident_subtype_description!,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  //   Text('ID: ${item.id}'
                                  //   ,                                      style: TextStyle(
                                  //     color: Colors.black[800],
                                  //  //   fontSize: 18,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  //   ),
                                  Text(
                                      '${capitalizeFirstLetter(item.incident_criticality_level)}',
                                      style: TextStyle(
                                          color: item
                                                  .incident_criticality_level!
                                                  .contains('minor')
                                              ? Colors.black
                                              : (item.incident_criticality_level!
                                                      .contains('serious')
                                                  ? Colors.black
                                                  : Colors.black),
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    color: Colors.black, size: 20),
                                Text(' ${item.sub_location_name}')
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.timer_outlined,
                                    color: Colors.black, size: 20),
                                Text(
                                    ' ${item.date_of_assignment?.split('T')[0]} | ${item.date_of_assignment?.split('T')[1].replaceAll(RegExp(r'\.\d+Z$'), '')}')
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.textsms_outlined,
                                    color: Colors.black, size: 20),
                                Expanded(
                                  child: Text(
                                    ' ${item.report_description}',
                                    style: TextStyle(
                                        //  fontSize: 16
                                        ),
                                  ),
                                )
                              ],
                            ),
                            //TODO: try image
                            // Padding(
                            //   padding: const EdgeInsets.only(bottom:4.0),
                            //   child: Text('By: Faris Ejaz'),
                            // ),
                            //TODO: get user name dynamically
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Visibility(
                                      visible:
                                          !item.status!.contains('approved') ||
                                              !item.status!
                                                  .contains('Approval pending'),
                                      child: StartButton(
                                          onTap: () =>
                                              startResolution(item, context)),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.02,
                                    ),
                                    ImageButton(
                                        onTap: () => handleImageButton(
                                            item.image, context)),
                                  ],
                                ),

                                item.status!.contains('assigned')
                                    ? Text('Assigned',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))
                                    : item.status!.contains('approval pending')
                                        ? Text('Approval pending',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold))
                                        : Text(
                                            '${capitalizeFirstLetter(item.status)}',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                //TODO: change status color dynamically
                              ],
                            ),
                          ]),
                    ],
                  ),
                ));
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
