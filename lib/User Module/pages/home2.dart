// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:safify/User%20Module/pages/login_page.dart';
import 'package:safify/User%20Module/pages/user_form.dart';
import 'package:safify/User%20Module/services/UserServices.dart';
import 'package:safify/widgets/user_report_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  // padding constants
  final double horizontalPadding = 45;
  final double verticalPadding = 25;
  final double mainHeaderSize = 18;

  String? user_name;
  String? user_id;
  UserServices userServices = UserServices();

  @override
  void initState() {
    super.initState();
    getUsername();
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
    return Scaffold(
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
                            onPressed: () {
                              Navigator.of(dialogContext)
                                  .pop(); // Close the dialog
                              // Perform logout actions here
                              handleLogout(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
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
        child: FloatingActionButton(
          //  backgroundColor: Colors.white,
          onPressed: () {
            _showBottomSheet();
          },
          child: const Icon(
            Icons.add,
          ),
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
                  Card(
                    margin: EdgeInsets.all(0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(
                            width: 5,
                          ),
                          user_name != null
                              ? Text(
                                  ' $user_name',
                                  style:
                                      Theme.of(context).textTheme.titleLarge,
                                )
                              : Text(
                                  ' Citizen',
                                  style:
                                      Theme.of(context).textTheme.titleLarge,
                                )
                        ],
                      ),
                    ),
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
                child: const Expanded(
                  child: UserReportTile(),
                ),
            
              )
            ],
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
                name: 'Start Inspection',
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

void handleLogout(BuildContext context) async {
  UserServices userServices = UserServices();
  await userServices.logout();
}
