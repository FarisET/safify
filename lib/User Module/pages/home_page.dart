// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:badges/badges.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safify/User%20Module/pages/login_page.dart';
import 'package:safify/User%20Module/pages/user_form.dart';
import 'package:safify/User%20Module/providers/user_reports_provider.dart';
import 'package:safify/User%20Module/providers/user_score_provider.dart';
import 'package:safify/db/database_helper.dart';
import 'package:safify/models/user_report_form_details.dart';
import 'package:safify/repositories/incident_types_repository.dart';
import 'package:safify/repositories/location_repository.dart';
import 'package:safify/services/report_service.dart';
import 'package:safify/services/UserServices.dart';
import 'package:safify/services/toast_service.dart';
import 'package:safify/utils/network_util.dart';
import 'package:safify/utils/screen.dart';
import 'package:safify/utils/string_utils.dart';
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

  @override
  void initState() {
    super.initState();
    Provider.of<UserScoreProvider>(context, listen: false).fetchScore(context);
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16 * scaleFactor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User Info Section
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 40 * scaleFactor, color: Colors.grey[700]),
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
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16 * scaleFactor,
                                    color: Colors.grey[600]),
                                SizedBox(width: 6 * scaleFactor),
                                Text(
                                  intl.DateFormat('d MMM y')
                                      .format(DateTime.now()),
                                  style: TextStyle(
                                      fontSize: 14 * scaleFactor,
                                      color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Score Section
                    Consumer<UserScoreProvider>(
                      builder: (context, userScoreProvider, child) {
                        if (userScoreProvider.isLoading) {
                          return const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent),
                            ),
                          );
                        } else if (userScoreProvider.error != null) {
                          return const Text(
                            'Score: N/A',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          );
                        } else if (userScoreProvider.score == "Offline") {
                          return const Text(
                            'Score: N/A',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          );
                        } else if (userScoreProvider.score != null) {
                          return ScoreCard(score: userScoreProvider.score!);
                        } else {
                          return Text(
                            'Fetching...',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20 * scaleFactor),
              Divider(
                  thickness: 1 * scaleFactor,
                  color: Color.fromARGB(255, 204, 204, 204)),

              // My Reports section title with responsive font size
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

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;

                    // Define spacing dynamically based on screen width
                    double spacing = screenWidth < 350
                        ? 3.0
                        : screenWidth < 600
                            ? 8.0
                            : 16.0;

                    return Wrap(
                      spacing: spacing, // Dynamic spacing
                      runSpacing:
                          spacing, // Apply same spacing for wrapped rows
                      alignment: WrapAlignment.center,
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
                      // ToastService.showUpdatedLocalDbSuccess(context);
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
                color: count > 0 ? Colors.orange : Colors.greenAccent,
                onPressed: () => _showBottomSheetUnsynced(),
              ),
            ),
          ],
        );
      },
    );
  }

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
                        BuildReportCardHome(report: reports[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper widget for consistent info rows
}

class BuildReportCardHome extends StatelessWidget {
  const BuildReportCardHome({
    super.key,
    required this.report,
  });

  final UserReportFormDetails report;

  @override
  Widget build(BuildContext context) {
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
            Text(
              DateFormat('MMM dd, yyyy - HH:mm a').format(report.date),
              style: TextStyle(),
            ),
            if (report.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  report.description,
                  style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BuildRowInfoUserHome extends StatelessWidget {
  const BuildRowInfoUserHome({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.score,
  });

  final String score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 24,
            color: Colors.blueAccent,
          ),
          SizedBox(width: 8),
          Text(
            'Score: $score',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
        ],
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
