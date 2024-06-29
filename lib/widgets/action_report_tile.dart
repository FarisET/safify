// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safify/Admin%20Module/providers/delete_action_report_provider.dart';
import 'package:safify/Admin%20Module/providers/delete_user_report_provider.dart';
import 'package:safify/User%20Module/pages/login_page.dart';
import 'package:safify/components/custom_button.dart';
import 'package:safify/services/UserServices.dart';
import 'package:safify/styles/app_theme.dart';
import 'package:safify/utils/alerts_util.dart';
import 'package:safify/utils/button_utils.dart';
import '../Action Team Module/providers/all_action_reports_approveal_provider.dart';
import '../Action Team Module/providers/all_action_reports_provider.dart';
import '../services/ReportServices.dart';

class ActionReportTile extends StatefulWidget {
  const ActionReportTile({super.key});

  @override
  State<ActionReportTile> createState() => _ActionReportTileState();
}

class _ActionReportTileState extends State<ActionReportTile> {
  @override
  void initState() {
    super.initState();
    Provider.of<ActionReportsProvider>(context, listen: false)
        .fetchAllActionReports(context);
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
    final approvalStatusProvider = Provider.of<ApprovalStatusProvider>(context);
    final fetchAllRepsProvider =
        Provider.of<ActionReportsProvider>(context, listen: false);
    return Center(child:
        Consumer<ActionReportsProvider>(builder: (context, allReports, _) {
      if (allReports.error != null &&
          allReports.error!.contains('TokenExpiredException')) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _handleSessionExpired(context));
      }
      if (allReports.reports.isNotEmpty) {
        return ListView.builder(
          itemCount: allReports.reports.length,
          itemBuilder: (context, i) {
            var item = allReports.reports[i];

            return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
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
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all()),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_outline,
                                      color: Colors.black, size: 20),
                                  Flexible(
                                    child: Text(
                                      ' ${item.reported_by}',
                                      style: TextStyle(),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.timer_outlined,
                                    color: Colors.black, size: 20),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                      '${item.date_time?.split('T')[0]} | ${item.date_time?.split('T')[1].replaceAll(RegExp(r'\.\d+Z$'), '')}'),
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.textsms_outlined,
                                    color: Colors.black, size: 20),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      //    item.report_description!.isNotEmpty ?
                                      item.report_description!.isNotEmpty
                                          ? item.report_description!
                                          : '-',
                                      style: TextStyle(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.note_alt_outlined,
                                    color: Colors.black, size: 20),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      '${item.resolution_description}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.04,
                            ),
                            SizedBox(
                              height: 40,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ImageButton(
                                      height: double.infinity,
                                      onTap: () {
                                        handleImageButton(
                                            item.proof_image, context);
                                      }),
                                  ApproveButton(
                                      height: double.infinity,
                                      isApproved:
                                          item.status!.contains('approved'),
                                      onTap: () async {
                                        if (item.action_report_id != null &&
                                            item.user_report_id != null) {
                                          ReportServices()
                                              .postapprovedActionReport(
                                                  item.user_report_id,
                                                  item.action_report_id);
                                          approvalStatusProvider
                                              .updateStatus(item.status!);
                                          fetchAllRepsProvider
                                              .fetchAllActionReports(context);
                                        }
                                      }),
                                  Visibility(
                                      visible: item.status != 'approved',
                                      child: RejectButton(onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text("Reject?"),
                                              content: Text(
                                                  "Are you sure you want to reject this report?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    DeleteActionReportProvider
                                                        deleteActionReportProvider =
                                                        Provider.of<
                                                                DeleteActionReportProvider>(
                                                            context,
                                                            listen: false);

                                                    deleteActionReportProvider
                                                        .deleteActionReport(
                                                            '${item.action_report_id}')
                                                        .then((success) async {
                                                      if (success) {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          backgroundColor:
                                                              Colors
                                                                  .greenAccent,
                                                          content: Text(
                                                              'Report deleted'),
                                                          duration: Duration(
                                                              seconds: 2),
                                                        ));
                                                        await Provider.of<
                                                                    ActionReportsProvider>(
                                                                context,
                                                                listen: false)
                                                            .fetchAllActionReports(
                                                                context);

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
                                      }))
                                ],
                              ),
                            ),
                          ]),
                    ],
                  ),
                ));
          },
        );
      } else if (allReports.reports.isEmpty && allReports.isLoading) {
        return CircularProgressIndicator();
      }
      return Text('Failed to load reports');
    }));
  }
}
