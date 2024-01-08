// ignore_for_file: prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

import '../../User Module/pages/login_page.dart';
import '../../User Module/services/UserServices.dart';
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
    double containerHeight = screenHeight*0.6;


    return Scaffold(
      appBar: AppBar(
        title: Text('Action Team Dashboard'),
        actions: [
          SizedBox(
            height: 100,
child: FilledButton(
  child: Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
  onPressed: () {
    // Show a confirmation dialog before logging out
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                // Perform logout actions here
                handleLogout(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  },
),
          ),
        ],
      ),
      backgroundColor: Colors.blue[600],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //Text
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            children: [ Text(
                              '$username',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            ]
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            intl.DateFormat.yMd().format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      //Profile
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(Icons.person),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 40,
                  ),


                ],
              ),
            ),

            SizedBox(
              height: 30,
            ),

//Previous reports
Spacer(
),

Stack(
  alignment: AlignmentDirectional.bottomCenter,
  children: [
    Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: containerHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
    ),
  ],
)
          ],
        ),
      ),
    );
  }

  void handleLogout(BuildContext context) async {
    UserServices userServices = UserServices();
    await userServices.logout();
  }
}
