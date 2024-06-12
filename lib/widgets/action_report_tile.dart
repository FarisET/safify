// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safify/Admin%20Module/providers/delete_action_report_provider.dart';
import 'package:safify/Admin%20Module/providers/delete_user_report_provider.dart';
import '../Action Team Module/providers/all_action_reports_approveal_provider.dart';
import '../Action Team Module/providers/all_action_reports_provider.dart';
import '../User Module/services/ReportServices.dart';

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

  @override
  Widget build(BuildContext context) {
    final approvalStatusProvider = Provider.of<ApprovalStatusProvider>(context);
    final fetchAllRepsProvider =
        Provider.of<ActionReportsProvider>(context, listen: false);
    return Center(child:
        Consumer<ActionReportsProvider>(builder: (context, allReports, _) {
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
                                      color: Colors.blue[800],
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Reported By: ',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    ' ${item.reported_by}',
                                    style: TextStyle(),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.timer, color: Colors.blue, size: 20),
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
                                Icon(Icons.edit, color: Colors.blue, size: 20),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      '${item.report_description}',
                                      style: TextStyle(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check, color: Colors.blue, size: 20),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      '${item.resolution_description}',
                                      style: TextStyle(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.04,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    item.status != 'approved'
                                        ? FilledButton(
                                            onPressed: () {
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
                                                                  listen:
                                                                      false);

                                                          deleteActionReportProvider
                                                              .deleteActionReport(
                                                                  '${item.action_report_id}')
                                                              .then(
                                                                  (success) async {
                                                            if (success) {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Close the dialog
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .greenAccent,
                                                                content: Text(
                                                                    'Report deleted'),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            2),
                                                              ));
                                                              await Provider.of<
                                                                          ActionReportsProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
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
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              // Add elevation for a raised effect
                                              elevation: MaterialStateProperty
                                                  .all<double>(
                                                      4.0), // Adjust as needed
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 0),
                                              child: Text('Reject',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(width: 4),
                                    FilledButton(
                                      onPressed: () {
                                        if (item.proof_image != null) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.7, // 70% of screen width
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.7, // 70% of screen width (square box)

                                                  // Limiting the child to the box's size and maintaining aspect ratio
                                                  child: FittedBox(
                                                    fit: BoxFit
                                                        .contain, // Maintain aspect ratio, fit within the box
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          '${item.proof_image}',
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
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: const [
                                                    Text('No Image Added'),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Color.fromARGB(255, 248, 249, 255)),
                                        // Add elevation for a raised effect
                                        elevation:
                                            MaterialStateProperty.all<double>(
                                                4.0), // Adjust as needed
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    390
                                                ? 6.0
                                                : 12.0,
                                            vertical: 0),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.image,
                                                size: 16, color: Colors.blue),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text('Image',
                                                style: TextStyle(
                                                    color: Colors.blue)),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: FilledButton(
                                    onPressed: () async {
                                      if (item.action_report_id != null &&
                                          item.user_report_id != null) {
                                        ReportServices(context)
                                            .postapprovedActionReport(
                                                item.user_report_id,
                                                item.action_report_id);
                                        approvalStatusProvider
                                            .updateStatus(item.status!);
                                        fetchAllRepsProvider
                                            .fetchAllActionReports(context);
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Color.fromARGB(255, 255, 255, 255)),
                                      // Add elevation for a raised effect
                                      elevation:
                                          MaterialStateProperty.all<double>(
                                              4.0), // Adjust as needed
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 0),
                                      child: Text(
                                        item.status!.contains('approved')
                                            ? 'Approved'
                                            : 'Approve',
                                        style: item.status!.contains('approved')
                                            ? TextStyle(
                                                color: Colors.greenAccent)
                                            : TextStyle(
                                                color: Colors.amber.shade700),
                                      ),
                                    ),
                                  ),
                                )
                              ],
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
