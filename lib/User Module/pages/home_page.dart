// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safify/User%20Module/pages/login_page.dart';
import 'package:safify/User%20Module/pages/user_form.dart';
import 'package:safify/User%20Module/providers/user_reports_provider.dart';
import 'package:safify/db/database_helper.dart';
import 'package:safify/models/user_report_form_details.dart';
import 'package:safify/repositories/incident_types_repository.dart';
import 'package:safify/repositories/location_repository.dart';
import 'package:safify/services/report_service.dart';
import 'package:safify/services/UserServices.dart';
import 'package:safify/services/toast_service.dart';
import 'package:safify/utils/network_util.dart';
import 'package:safify/widgets/user_actions_modal_sheet.dart';
import 'package:safify/widgets/user_report_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;

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
    // Define scaling factors based on screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double scaleFactor = screenWidth /
        400; // Base scaling factor for width around a medium screen width (e.g., 400px)

    return Scaffold(
      appBar: // Import the flutter_svg package

          AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 56 * scaleFactor, // Scale the height of the AppBar
        leading: Padding(
          padding: EdgeInsets.all(8.0 * scaleFactor),
          child: SvgPicture.asset(
            'assets/images/safify_logo_wo_text.svg', // Use the SVG file instead
            height: 56 * scaleFactor, // Scale the size of the app icon
            width: 56 * scaleFactor, // Scale the size of the app icon
          ),
        ),
        title: Text(
          "Home",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20 * scaleFactor, // Scale font based on screen width
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            iconSize: 24 * scaleFactor, // Scale the logout icon size
            onPressed: () {
              // Show a confirmation dialog before logging out
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
                          Navigator.of(dialogContext).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        child: const Text('Logout'),
                        onPressed: () async {
                          Navigator.of(dialogContext).pop(); // Close the dialog
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
              // Username and Date with responsive styling
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
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20 * scaleFactor),
              Divider(
                  thickness: 1 * scaleFactor,
                  color: Color.fromARGB(255, 204, 204, 204)),
              SizedBox(height: 20 * scaleFactor),

              // My Reports section title with responsive font size
              Text(
                "My Reports",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24 * scaleFactor,
                  color: Colors.black,
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
                      // ToastService.showUpdatedLocalDbSuccess(context);
                    } else {
                      ToastService.showFailedToFetchReportsFromServer(context);
                    }
                  },
                  child: const UserReportList(),
                ),
              ),
            ],
          ),
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
