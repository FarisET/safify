// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:safify/Admin%20Module/providers/delete_user_report_provider.dart';
import 'package:safify/utils/string_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Admin Module/admin_pages/assign_form.dart';
import '../Admin Module/providers/fetch_all_user_report_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminReportTile extends StatefulWidget {
  const AdminReportTile({super.key});

  @override
  State<AdminReportTile> createState() => _AdminReportTileState();
}

class _AdminReportTileState extends State<AdminReportTile> {
  @override
  void initState() {
    super.initState();
    Provider.of<AllUserReportsProvider>(context, listen: false)
        .fetchAllReports(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(child:
        Consumer<AllUserReportsProvider>(builder: (context, allReports, _) {
      if (allReports.reports.isNotEmpty) {
        return ListView.builder(
          itemCount: allReports.reports.length,
          itemBuilder: (context, i) {
            var item = allReports.reports[i];

            return Card(
                color: Colors.white,
                // color: item.status!.contains('open')
                //     ? Colors.red[100]
                //     : (item.status!.contains('in progress')
                //         ? Colors.orange[100]
                //         : Colors.[100]),
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.incidentSubtypeDescription!,
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                      '${capitalizeFirstLetter(item.incidentCriticalityLevel)}',
                                      style: TextStyle(
                                          color: item.incidentCriticalityLevel!
                                                  .contains('minor')
                                              ? Colors.green
                                              : (item.incidentCriticalityLevel!
                                                      .contains('serious')
                                                  ? Colors.orange
                                                  : Colors.red),
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                '${item.status}'.contains('open')
                                    ? Icon(Icons.start,
                                        color: Colors.redAccent, size: 20)
                                    : '${item.status}'.contains('in progress')
                                        ? Icon(Icons.pending,
                                            color: Colors.orangeAccent,
                                            size: 20)
                                        : Icon(Icons.check,
                                            color: Colors.greenAccent,
                                            size: 20),
                                Text(' ${capitalizeFirstLetter(item.status)}')
                              ],
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_city,
                                    color: Colors.blue, size: 20),
                                Text(' ${item.subLocationName}')
                              ],
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005,
                            ),
                            Row(
                              children: [
                                Icon(Icons.timer, color: Colors.blue, size: 20),
                                Text(
                                    ' ${item.dateTime?.split('T')[0]} | ${item.dateTime?.split('T')[1].replaceAll(RegExp(r'\.\d+Z$'), '')}')
                              ],
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.edit, color: Colors.blue, size: 20),
                                Expanded(
                                  child: Text(
                                    ' ${item.description}',
                                    style: TextStyle(
                                        //  fontSize: 16
                                        ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Row(
                              mainAxisAlignment:
                                  MediaQuery.of(context).size.width < 360
                                      ? MainAxisAlignment.spaceEvenly
                                      : MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MediaQuery.of(context).size.width < 360
                                          ? MainAxisAlignment.spaceEvenly
                                          : MainAxisAlignment.start,
                                  children: [
                                    Visibility(
                                      visible: (item.status == 'open'),
                                      child: FilledButton(
                                        onPressed: () {
                                          // Show a confirmation dialog before rejecting
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text("Delete?"),
                                                content: Text(
                                                    "Are you sure you want to delete this report?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog
                                                    },
                                                    child: Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      if (!'${item.status}'
                                                          .contains(
                                                              'in progress')) {
                                                        final deleteUserReportProvider =
                                                            Provider.of<
                                                                    DeleteUserReportProvider>(
                                                                context,
                                                                listen: false);
                                                        final success =
                                                            await deleteUserReportProvider
                                                                .deleteUserReport(
                                                                    '${item.id}');

                                                        if (success) {
                                                          Navigator.of(context)
                                                              .pop();
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
                                                          final allUserReportsProvider =
                                                              Provider.of<
                                                                      AllUserReportsProvider>(
                                                                  context,
                                                                  listen:
                                                                      false);
                                                          await allUserReportsProvider
                                                              .fetchAllReports(
                                                                  context);
                                                        }
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          backgroundColor:
                                                              Colors.redAccent,
                                                          content: Text(
                                                              'Denied: task in progress'),
                                                          duration: Duration(
                                                              seconds: 2),
                                                        ));
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      }
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
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
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
                                          child: Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Visibility(
                                        visible: (item.status == 'open'),
                                        child: FilledButton(
                                          onPressed: () async {
                                            //Add to Assigned form
                                            //  Fluttertoast.showToast(msg: '${item.id}');
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            //                                        if (item != null && item.user_id != null) {
                                            if (item.user_id != null) {
                                              await prefs.setString(
                                                  "this_user_id",
                                                  (item.user_id!));
                                            }
                                            if (item.id != null) {
                                              await prefs.setInt(
                                                  "user_report_id", (item.id!));
                                            }

                                            //                          if(prefs.getString('user_id') !=null && prefs.getInt('user_report_id') !=null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AssignForm()),
                                            );
                                            //                           }
                                            // print('user_id: ${prefs.getString('this_user_id')}');
                                            // print('id: ${item.id}');
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
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              390
                                                          ? 6.0
                                                          : 12.0,
                                                  vertical: 0),
                                              child: '${item.status}'
                                                      .contains('in progress')
                                                  ? Text('Assigned',
                                                      style: TextStyle(
                                                          color: Colors.yellow))
                                                  : Text('Assign',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.yellow))),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                FilledButton(
                                  onPressed: () {
                                    if (item.image != null) {
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
                                                  imageUrl: '${item.image}',
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
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('No Image Added'),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    // Add elevation for a raised effect
                                    elevation:
                                        MaterialStateProperty.all<double>(
                                            4.0), // Adjust as needed
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width <
                                                    390
                                                ? 6.0
                                                : 12.0,
                                        vertical: 0),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.image,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Image',
                                            style:
                                                TextStyle(color: Colors.blue)),
                                      ],
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

  bool isBase64(String data) {
    final RegExp base64Regex = RegExp(
      r'^([A-Za-z0-9+/]{4})*(([A-Za-z0-9+/]{2}==)|([A-Za-z0-9+/]{3}=))?$',
      multiLine: true,
    );
    return base64Regex.hasMatch(data);
  }
}
