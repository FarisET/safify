// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safify/User%20Module/pages/login_page.dart';
import 'package:safify/User%20Module/providers/user_reports_provider.dart';
import 'package:safify/db/database_helper.dart';
import 'package:safify/models/user.dart';
import 'package:safify/models/user_report_form_details.dart';
import 'package:safify/repositories/incident_types_repository.dart';
import 'package:safify/repositories/location_repository.dart';
import 'package:safify/services/report_service.dart';
import 'package:safify/services/UserServices.dart';
import 'package:safify/services/toast_service.dart';
import 'package:safify/utils/network_util.dart';
import 'package:safify/utils/screen.dart';
import 'package:safify/utils/string_utils.dart';
import 'package:safify/utils/user_utils.dart';
import 'package:safify/widgets/user_actions_modal_sheet.dart';
import 'package:safify/widgets/user_report_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:badges/badges.dart' as custom_badge;

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
  String selectedStatus = "All";
  final UserUtils user = UserUtils();

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  void updateUI() {
    setState(() {});
  }

  //SRB VIOLATION 1 -> fetching username interacts with flutter's local storage and should be in a DAL with the Single Responsibility to retrieve user name

  void getUsername() async {
    await user.loadUserDetails();
    setState(() {
      user_name = user.userName;
      user_id = user.userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    //SRB VIOLATION 2 -> These MediaQuery declarations should be in a Sizes helper class

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double scaleFactor = screenWidth / 400;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        toolbarHeight: Screen(context).screenHeight * 0.07,
        leading: IconButton(
          icon: Image.asset('assets/images/safify_icon.png'),
          onPressed: () {
            // Handle settings button press
          },
        ),
        title: Text("Home",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16 * scaleFactor,
              color: Theme.of(context).secondaryHeaderColor,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            iconSize: 24 * scaleFactor,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Confirmation'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Logout'),
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          bool res = await handleLogout(context);
                          if (res) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Theme.of(context).primaryColor,
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
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10.0 * scaleFactor),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            LocationRepository().syncDbLocationsAndSublocations();
            IncidentTypesRepository().syncDbIncidentAndSubincidentTypes();
            _showBottomSheet();
          },
          child: const Icon(Icons.add),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.0 * scaleFactor),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12 * scaleFactor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person,
                        size: 36 * scaleFactor, color: Colors.grey[700]),
                    SizedBox(width: 12 * scaleFactor),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user_name ?? 'User',
                          style: TextStyle(
                            fontSize: 22 * scaleFactor,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4 * scaleFactor),
                        Text(
                          intl.DateFormat('d MMMM y').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 14 * scaleFactor,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4 * scaleFactor),

                        // Display Score
                        Consumer<UserReportsProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) {
                              return Text("Loading score...",
                                  style: TextStyle(
                                      fontSize: 14 * scaleFactor,
                                      color: Colors.grey[600]));
                            } else if (provider.score != null) {
                              return Text(
                                "Score: ${provider.score}",
                                style: TextStyle(
                                    fontSize: 16 * scaleFactor,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              );
                            } else {
                              return Text("Score: N/A",
                                  style: TextStyle(
                                      fontSize: 14 * scaleFactor,
                                      color: Colors.grey[600]));
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20 * scaleFactor),
              Divider(
                  thickness: 1 * scaleFactor,
                  color: const Color.fromARGB(255, 204, 204, 204)),
              SizedBox(height: 20 * scaleFactor),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Reports",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24 * scaleFactor,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showBottomSheetUnsynced();
                    },
                    child: _buildTriggerButton(),
                  ),
                ],
              ),
              SizedBox(height: 8 * scaleFactor),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;

                    // Define spacing dynamically based on screen width
                    double spacing = screenWidth < 350
                        ? 3.0
                        : screenWidth < 600
                            ? 6.0
                            : 16.0;

                    return Wrap(
                      spacing: spacing, // Dynamic spacing
                      runSpacing:
                          spacing, // Apply same spacing for wrapped rows
                      alignment: WrapAlignment.start,
                      children: [
                        _buildFilterButton("All"),
                        _buildFilterButton("open"),
                        _buildFilterButton("in progress"),
                        _buildFilterButton("completed"),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: 8 * scaleFactor),

              // List of reports
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    updateUI();
                    final result = await Provider.of<UserReportsProvider>(
                      context,
                      listen: false,
                    ).fetchReports(context);

                    if (result.contains("success")) {
                    } else {
                      ToastService.showFailedToFetchReportsFromServer(context);
                    }
                  },
                  child: UserReportList(
                    selectedStatus: selectedStatus,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //SRB VIOLATION 3-> UI component should be in a separate widget component with the single responsibility to render FilterButton

  Widget _buildFilterButton(String status) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedStatus = status;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedStatus == status
            ? Colors.blue[100]
            : Colors.grey[300], // Active: Blue, Inactive: Light Grey
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Add border radius
        ),
        elevation: 0, // Remove elevation
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Screen(context).screenWidth * 0.005,
            vertical: Screen(context).screenHeight * 0.005),
        child: Text(
          ' ${capitalizeFirstLetter(status)}',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12 * Screen(context).scaleFactor),
        ),
      ),
    );
  }

  Future<void> uploadUserFormReports(BuildContext context) async {
    print("uploading reports...");
    final pingSuccess = await ping_google();
    if (!pingSuccess) {
      print("Connection error. Retrying later...");
      return;
    }
    final dbHelper = await DatabaseHelper();
    final Map<int, UserReportFormDetails> reports =
        await dbHelper.getUserFormReports();
    final reportService = ReportServices();

    for (var entry in reports.entries) {
      int id = entry.key;
      UserReportFormDetails report = entry.value;
      int uploadSuccess = -1;
      try {
        if (report.imagePath != null) {
          uploadSuccess = await reportService.uploadReportWithImage(
              report.imagePath,
              report.sublocationId,
              report.incidentSubtypeId,
              report.description,
              report.date,
              report.criticalityId);
        } else {
          uploadSuccess = await reportService.postReport(
              report.sublocationId,
              report.incidentSubtypeId,
              report.description,
              report.date,
              report.criticalityId);
        }
      } catch (e) {
        rethrow;
      }

      if (uploadSuccess == 1) {
        await dbHelper.deleteUserFormReport(id);
        print("Report successfully sent and deleted from local database");
      } else {
        print("Report failed to send. Retrying later...: error:$uploadSuccess");
      }
    }
  }

  //SRB VIOLATION 4 -> UI component should be in a separate widget component with the single responsibility to render TriggerButton
  void _showBottomSheet() {
    showModalBottomSheet(
        isDismissible: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return SizedBox(
            height: MediaQuery.sizeOf(context).height * .4,
            child: const UserActionsModalSheet(),
          );
        });
  }

  //SRB VIOLATION 5 -> UI component should be in a separate widget component with the single responsibility to render TriggerButton
  Widget _buildTriggerButton() {
    DatabaseHelper databaseHelper = DatabaseHelper();
    return FutureBuilder<int>(
      future:
          databaseHelper.getAllUserReports().then((reports) => reports.length),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data! : 0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge with icon
            custom_badge.Badge(
              badgeStyle: BadgeStyle(
                badgeColor: Colors.orange, // Set badge color to orange
              ),
              showBadge: count > 0, // Only show badge if count > 0
              badgeContent: Text('$count'),
              position: custom_badge.BadgePosition.topEnd(top: -8, end: -12),
              child: IconButton(
                icon: const Icon(Icons.sync_problem),
                color: count > 0 ? Colors.orange : Colors.green,
                onPressed: () => _showBottomSheetUnsynced(),
              ),
            ),
          ],
        );
      },
    );
  }

  //SRB VIOLATION 6 -> UI component should be in a separate widget component with the single responsibility to render BottomSheet

  void _showBottomSheetUnsynced() {
    final databaseHelper = DatabaseHelper();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Unsynced Reports',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<UserReportFormDetails>>(
                future: databaseHelper.getAllUserReports().then((maps) => maps
                    .map((map) => UserReportFormDetails.fromJson(map))
                    .toList()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final reports = snapshot.data ?? [];

                  if (reports.isEmpty) {
                    return const Center(child: Text('All reports are synced!'));
                  }

                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) =>
                        _buildReportCard(reports[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //SRB VIOLATION 7 -> UI component should be in a separate widget component with the single responsibility to render Card. Releaving burden from Home Widget.

  Widget _buildReportCard(UserReportFormDetails report) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report.imagePath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(report.imagePath!),
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy - HH:mm a').format(report.date),
                  style: TextStyle(),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: report.criticalityId.contains('CRT1')
                        ? Colors.green[100]
                        : report.criticalityId.contains('CRT2')
                            ? Colors.orange[100]
                            : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ' ${capitalizeFirstLetter(
                      report.criticalityId.contains('CRT1')
                          ? 'minor'
                          : report.criticalityId!.contains('CRT2')
                              ? 'serious'
                              : 'critical',
                    )}',
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (report.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Text(
                      report.description,
                      style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
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
