// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Center(child:
        Consumer<UserReportsProvider>(builder: (context, reportProvider, _) {
      if (reportProvider.reports.isNotEmpty) {
        return ListView.builder(
          itemCount: reportProvider.reports.length,
          itemBuilder: (context, i) {
            var item = reportProvider.reports[i];

            return Card(
                //color: item.status!.contains('open') ? Colors.red[50] : (item.status!.contains('in progress') ? Colors.orange[50] : Colors.green[50]),
                color: Colors.white,
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
                                    item.incidentSubtypeDescription!,
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  //   Text('ID: ${item.id}'
                                  //   ,                                      style: TextStyle(
                                  //     color: Colors.blue[800],
                                  //  //   fontSize: 18,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  //   ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                        '${item.incidentCriticalityLevel}',
                                        style: TextStyle(
                                            color: item
                                                    .incidentCriticalityLevel!
                                                    .contains('minor')
                                                ? Colors.green
                                                : (item.incidentCriticalityLevel!
                                                        .contains('serious')
                                                    ? Colors.orange
                                                    : Colors.red),
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                Icon(Icons.location_city,
                                    color: Colors.blue, size: 20),
                                Text(' ${item.subLocationName}')
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.timer, color: Colors.blue, size: 20),
                                Text(
                                    ' ${item.dateTime?.split('T')[0]} | ${item.dateTime?.split('T')[1].replaceAll(RegExp(r'\.\d+Z$'), '')}')
                              ],
                            ),
                            Row(
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
                                                Text('Unable to load image'),
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
                                            Colors.blue),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 0),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.attach_file,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text('View incident',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                                item.status!.contains('completed')
                                    ? Text('completed',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold))
                                    : item.status!.contains('in progress')
                                        ? Text('in progress',
                                            style: TextStyle(
                                                color: Colors.orange,
                                                fontWeight: FontWeight.bold))
                                        : Text('${item.status}',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold))
                                //TODO: change status color dynamically
                              ],
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
