// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safify/User%20Module/pages/login_page.dart';
import 'package:safify/User%20Module/pages/user_form.dart';
import 'package:safify/User%20Module/providers/fetch_user_report_provider.dart';
import 'package:safify/db/database_helper.dart';
import 'package:safify/dummy.dart';
import 'package:safify/models/location.dart';
import 'package:safify/models/sub_location.dart';
import 'package:safify/services/UserServices.dart';
import 'package:safify/widgets/user_report_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sqflite/sqflite.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  // padding constants
  final double mainHeaderSize = 18;

  String? user_name;
  String? user_id;
  UserServices userServices = UserServices();

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  void updateUI() {
    setState(() {});
  }

  void getUsername() {
    SharedPreferences.getInstance().then((prefs) async {
      user_name = await userServices.getName();
      setState(() {
        user_id = prefs.getString("user_id");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        updateUI();
        await Provider.of<UserReportsProvider>(context, listen: false)
            .fetchReports(context);
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Text("Home",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: mainHeaderSize,
                  color: Theme.of(context).secondaryHeaderColor,
                )),
            actions: [
              IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    // Show a confirmation dialog before logging out
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Confirmation'),
                          content:
                              const Text('Are you sure you want to log out?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(dialogContext)
                                    .pop(); // Close the dialog
                              },
                            ),
                            TextButton(
                              child: Text('Logout'),
                              onPressed: () async {
                                Navigator.of(dialogContext)
                                    .pop(); // Close the dialog
                                // Perform logout actions here
                                bool res = await handleLogout(context);
                                if (res == true) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      content: const Text('Logout Failed'),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  color: Theme.of(context).secondaryHeaderColor),
            ]),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                //  backgroundColor: Colors.white,
                onPressed: () {
                  _showBottomSheet();
                },
                child: const Icon(
                  Icons.add,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () async {
                  print("hi");
                  final dbhelper = DatabaseHelper();

                  // final lists = parseLocationsAndSubLocations(locationsJson);
                  // await dbhelper.insertLocationsAndSublocations(
                  //     lists[0] as List<Location>,
                  //     lists[1] as List<SubLocation>);
                  final locations = await dbhelper.getLocations();
                  final sublocations = await dbhelper.getAllSubLocations();
                  print("count of locations: ${locations.length}");
                  print("count of sublocations: ${sublocations.length}");

                  print('Locations:');
                  for (var location in locations) {
                    print(location);
                  }

                  print('\nSub Locations:');
                  for (var subLocation in sublocations) {
                    print(subLocation);
                  }
                  final databasePath = getDatabasesPath();
                  databasePath.then((value) => print("Database path: $value"));
                },
                child: const Icon(
                  CupertinoIcons.pencil_ellipsis_rectangle,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.05,
                vertical: MediaQuery.sizeOf(context).height * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                //    welcome home
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //TODO: get user name dynamically in welcome
                        user_name != null
                            ? Text(
                                '$user_name',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              )
                            : Text(
                                'User',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.007,
                        ),
                        Text(intl.DateFormat('d MMMM y').format(DateTime.now()),
                            style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                  ],
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                const Divider(
                  thickness: 1,
                  color: Color.fromARGB(255, 204, 204, 204),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                // previous reports
                Text(
                  "My Reports",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.009,
                ),

                // list of reports
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.60,
                  child: UserReportTile(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(shrinkWrap: true, children: [
            //black divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.sizeOf(context).height * .015,
                  horizontal: MediaQuery.sizeOf(context).width * .4),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close)),

            //report incident
            _OptionItem(
                icon: Icon(Icons.copy_all_rounded,
                    color: Colors.blue[600], size: 26),
                name: 'Report Incident',
                description: 'Capture an incident, hazard or a feedback',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserForm()),
                  );
                }),
            _OptionItem(
                icon: Icon(Icons.copy_all_rounded,
                    color: Colors.blue[600], size: 26),
                name: 'Start Inspection (coming soon)',
                description: 'Capture an incident, hazard',
                onTap: () {}),

            //separator or divider
            Divider(
              color: Colors.black54,
              endIndent: MediaQuery.sizeOf(context).width * .04,
              indent: MediaQuery.sizeOf(context).width * .04,
            )
          ]);
        });
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final String description;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon,
      required this.name,
      required this.onTap,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: ListTile(
          leading: Container(
            decoration: BoxDecoration(
              color: Colors.blue[100], // Light blue color
              borderRadius:
                  BorderRadius.circular(8.0), // Adjust the radius for curvature
            ),
            padding: EdgeInsets.all(8.0), // Adjust padding as needed
            child: icon, // Your icon widget
          ),
          title: Text(
            "$name",
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).secondaryHeaderColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "$description",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: CircleAvatar(
              backgroundColor: Colors.blue[100],
              radius: 12,
              child: const Icon(
                Icons.arrow_forward_ios_outlined,
                size: 11,
              )),
        ));
  }
}

Future<bool> handleLogout(BuildContext context) async {
  UserServices userServices = UserServices();
  bool res = await userServices.logout();
  if (res == true) {
    return true;
  } else {
    return false;
  }
}
