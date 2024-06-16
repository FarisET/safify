// ignore_for_file: prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

import '../../User Module/pages/login_page.dart';
import '../../services/UserServices.dart';
import '../../widgets/assigned_task_tile.dart';

// ignore_for_file: prefer_const_constructors

class ActionTeamHomePage extends StatefulWidget {
  const ActionTeamHomePage({super.key});

  @override
  State<ActionTeamHomePage> createState() => _ActionTeamHomePageState();
}

class _ActionTeamHomePageState extends State<ActionTeamHomePage> {
  String? username;
  String? user_id;
  DateTime dateTime = DateTime.now();
  UserServices userServices = UserServices();
  final double mainHeaderSize = 18;

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  void getUsername() {
    SharedPreferences.getInstance().then((prefs) async {
      username = await userServices.getName();
      setState(() {
        user_id = prefs.getString("user_id");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = screenHeight * 0.6;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/safify_icon.png'),
          ),
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width * 0.05,
              vertical: MediaQuery.sizeOf(context).height * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //Text
                        children: [
                          Wrap(alignment: WrapAlignment.start, children: [
                            username != null
                                ? Text(
                                    '$username',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    'Action Team',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ]),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.007,
                          ),
                          Text(
                              intl.DateFormat('d MMMM y')
                                  .format(DateTime.now()),
                              style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ),
                    ],
                  ),
                ),
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

              //Assigned reports

              Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: containerHeight,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Tasks',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: AssignedTaskTile(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
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
}
