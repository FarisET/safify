// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_types_as_parameter_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safify/Admin%20Module/admin_pages/admin_dashboard.dart';
import 'package:safify/Admin%20Module/providers/action_team_efficiency_provider.dart';
import 'package:safify/Admin%20Module/providers/fetch_countOfLocations_provider%20copy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;

import '../../User Module/pages/login_page.dart';
import '../../User Module/services/UserServices.dart';
import '../../widgets/action_report_tile.dart';
import '../../widgets/admin_report_tile.dart';
import '../../widgets/app_drawer.dart';
import '../providers/analytics_incident_reported_provider.dart';
import '../providers/analytics_incident_resolved_provider.dart';
import '../providers/fetch_countOfSubtypes_provider.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key, Key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  String? user_name;
  String? user_id;
  final double mainHeaderSize = 18;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<CountIncidentsResolvedProvider>(context, listen: false)
          .getCountResolvedPostData();
      Provider.of<CountIncidentsReportedProvider>(context, listen: false)
          .getCountReportedPostData();
      Provider.of<CountByIncidentSubTypesProviderClass>(context, listen: false)
          .getcountByIncidentSubTypesPostData();
      Provider.of<CountByLocationProviderClass>(context, listen: false)
          .getcountByIncidentLocationPostData();
      Provider.of<ActionTeamEfficiencyProviderClass>(context, listen: false)
          .getactionTeamEfficiencyData();
    });
    getUsername();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  UserServices userServices = UserServices();

  void getUsername() {
    SharedPreferences.getInstance().then((prefs) async {
      user_name = await userServices.getName();
      setState(() {
        print('user_name: $user_name');
        user_id = prefs.getString("user_id");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final countResolvedProvider =
        Provider.of<CountIncidentsResolvedProvider>(context)
            .totalIncidentsResolved;
    final countReportedProvider =
        Provider.of<CountIncidentsReportedProvider>(context)
            .totalIncidentsReported;
    final countByIncidentSubTypeProvider =
        Provider.of<CountByIncidentSubTypesProviderClass>(context)
            .countByIncidentSubTypes;
    final countByLocationProvider =
        Provider.of<CountByLocationProviderClass>(context, listen: false)
            .countByLocation;
    final actionTeamEfficiencyProvider =
        Provider.of<ActionTeamEfficiencyProviderClass>(context, listen: false)
            .actionTeamEfficiency;

    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = screenHeight * 0.7;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
        drawer: AppDrawer(
            totalIncidentsReported: countReportedProvider ?? 'null value',
            totalIncidentsResolved: countResolvedProvider ?? 'null value',
            incidentSubtypeBreakdown: countByIncidentSubTypeProvider,
            incidentLocationBreakdown: countByLocationProvider,
            actionTeamEfficiencyBreakdown: actionTeamEfficiencyProvider),
        //     backgroundColor: Colors.blue[600],
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.05,
                vertical: MediaQuery.sizeOf(context).height * 0.02),
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
                              //TODO: get user name dynamically in welcome
                              user_name != null
                                  ? Text(
                                      '$user_name',
                                      style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold  
                                      ),
                                    )
                                  : Text(
                                      'Citizen',
                                      style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold  
                                      ),
                                      
                                    ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.007,
                              ),
                              Text(
                                  intl.DateFormat('d MMMM y')
                                      .format(DateTime.now()),
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            ],
                          ),

                          //Profile
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AdminDashboard()),
                                );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.analytics,color: Colors.white,),
                                    Text(' Dashboard',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                    ],
                  ),
                ),

                //Reports tab
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TabBar(
                    labelColor:
                        Colors.white, // Color of the selected tab's label
                    unselectedLabelColor:
                        Colors.white, // Color of unselected tabs' labels
                    labelStyle: TextStyle(
                      fontWeight:
                          FontWeight.bold, // Style for the selected tab's label
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontWeight:
                          FontWeight.bold, // Style for unselected tabs' labels
                    ),
                    indicator: BoxDecoration(
                      // Decoration for the indicator below the selected tab
                      color: Colors.blue[500],
                      borderRadius:
                          BorderRadius.circular(10), // You can adjust the shape
                    ),
                    controller: _tabController,
                    tabs: const <Widget>[
                      Tab(
                        text: 'User Reports',
                      ),
                      Tab(
                        text: 'Action Team Reports',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: containerHeight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: <Widget>[
                                    AdminReportTile(),
                                    ActionReportTile() // Replace with Action Team Reports widget
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleLogout(BuildContext context) async {
    UserServices userServices = UserServices();
    await userServices.logout();
  }
}
