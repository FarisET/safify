// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safify/User%20Module/pages/login_page.dart';
import 'package:safify/components/custom_button.dart';
import 'package:safify/services/UserServices.dart';
import 'package:safify/utils/alerts_util.dart';
import 'package:safify/utils/string_utils.dart';

import '../User Module/providers/fetch_user_report_provider.dart';

class UserReportTile extends StatefulWidget {
  const UserReportTile({super.key});

  @override
  State<UserReportTile> createState() => _UserReportTileState();
}

class _UserReportTileState extends State<UserReportTile> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserReportsProvider>(context, listen: false)
        .fetchReports(context);
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
        Consumer<UserReportsProvider>(builder: (context, reportProvider, _) {
      if (reportProvider.error != null &&
          reportProvider.error!.contains('TokenExpiredException')) {
        if (reportProvider.error!.contains('TokenExpiredException')) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _handleSessionExpired(context));
        }
        // return
        // Center(child: Text('Error: ${reportProvider.error}'));
      }
      if (reportProvider.reports.isNotEmpty) {
        return ListView.builder(
          itemCount: reportProvider.reports.length,
          itemBuilder: (context, i) {
            var item = reportProvider.reports[i];

            return Card(
                //color: item.status!.contains('open') ? Colors.red[50] : (item.status!.contains('in progress') ? Colors.orange[50] : Colors.green[50]),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // side: BorderSide(
                //   // color: item.status!.contains('open')?Colors.redAccent:Colors.greenAccent,
                //    width:1)),
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
                                    item.incidentSubtypeDescription!,
                                    style: TextStyle(
                                      color: Colors.black,
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
                            Row(
                              children: [
                                Icon(Icons.location_city,
                                    color: Colors.black, size: 20),
                                Text(' ${item.subLocationName}')
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.timer,
                                    color: Colors.black, size: 20),
                                Text(
                                    ' ${item.dateTime?.split('T')[0]} | ${item.dateTime?.split('T')[1].replaceAll(RegExp(r'\.\d+Z$'), '')}')
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.edit, color: Colors.black, size: 20),
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
                              height: 30,
                            ),
                            SizedBox(
                              height: 40,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ImageButton(
                                      height: double.infinity,
                                      width: MediaQuery.sizeOf(context).width *
                                          0.35,
                                      onTap: () {
                                        if (item.image != null) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width, // 70% of screen width
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height, // 70% of screen width (square box)
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
                                      }),
                                  item.status!.contains('completed')
                                      ? Text('Completed',
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold))
                                      : item.status!.contains('in progress')
                                          ? Text('In progress',
                                              style: TextStyle(
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold))
                                          : Text(
                                              '${capitalizeFirstLetter(item.status)}',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),
                          ]),
                    ],
                  ),
                ));
          },
        );
      } else if (reportProvider.reports.isEmpty && reportProvider.isLoading) {
        return CircularProgressIndicator();
      }
      return Text('No Reports');
    }));
  }
}
