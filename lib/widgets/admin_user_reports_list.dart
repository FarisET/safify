// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safify/User%20Module/pages/login_page.dart';
import 'package:safify/services/UserServices.dart';
import 'package:safify/utils/alerts_util.dart';
import 'package:safify/widgets/admin_report_tile.dart';

import '../Admin Module/providers/admin_user_reports_provider.dart';

class AdminUserReportsList extends StatefulWidget {
  const AdminUserReportsList({super.key});

  @override
  State<AdminUserReportsList> createState() => _AdminUserReportsListState();
}

class _AdminUserReportsListState extends State<AdminUserReportsList> {
  @override
  void initState() {
    super.initState();
    if (Provider.of<AdminUserReportsProvider>(context, listen: false).reports ==
        null) {
      Provider.of<AdminUserReportsProvider>(context, listen: false)
          .fetchAdminUserReports(context);
    }
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
        Consumer<AdminUserReportsProvider>(builder: (context, allReports, _) {
      if (allReports.error != null &&
          allReports.error!.contains('TokenExpiredException')) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _handleSessionExpired(context));
      }
      if (allReports.reports != null) {
        if (allReports.reports!.isNotEmpty) {
          return ListView.builder(
            itemCount: allReports.reports!.length,
            itemBuilder: (context, i) {
              var item = allReports.reports![i];

              return AdminReportTile(userReport: item);
            },
          );
        } else if (allReports.reports!.isEmpty && allReports.isLoading) {
          return CircularProgressIndicator();
        }
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No reports found.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              Provider.of<AdminUserReportsProvider>(context, listen: false)
                  .fetchAdminUserReports(context);
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      );
    }));
  }

  bool isBase64(String data) {
    final RegExp base64Regex = RegExp(
      r'^([A-Za-z0-9+/]{4})*(([A-Za-z0-9+/]{2}==)|([A-Za-z0-9+/]{3}=))?$',
      multiLine: true,
    );
    return base64Regex.hasMatch(data);
  }
}
