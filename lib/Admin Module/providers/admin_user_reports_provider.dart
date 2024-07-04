import 'package:flutter/material.dart';
import 'package:safify/models/token_expired.dart';
import 'package:safify/repositories/admin_user_reports_repository.dart';
import 'package:safify/services/snack_bar_service.dart';
import 'package:safify/utils/network_util.dart';
import '../../services/ReportServices.dart';
import '../../models/user_report.dart';

class AdminUserReportsProvider with ChangeNotifier {
  List<UserReport>? _reports;
  List<UserReport>? get reports => _reports;
  bool isLoading = false;
  String? _error;
  String? get error => _error;
  final AdminUserReportsRepository _adminUserReportsRepository =
      AdminUserReportsRepository();

  Future<void> fetchAdminUserReports(BuildContext context) async {
    try {
      _error = null;
      isLoading = true;
      _reports = await _adminUserReportsRepository.fetchAllUserReportsFromDb();
      print("_reports: $_reports");
      isLoading = false;

      notifyListeners();
      debugPrint("Fetched admin user reports from local database.");

      final ping = await ping_google();

      if (ping) {
        SnackBarService.showCustomSnackBar(
            context: context,
            leading: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight * 0.5,
                  width: constraints.maxHeight * 0.5,
                  child: const CircularProgressIndicator(
                    strokeWidth: 1,
                    color: Colors.black,
                  ),
                );
              },
            ),
            content: const Text("Syncing local data with server..."));
        await _adminUserReportsRepository.syncDb();
        _reports =
            await _adminUserReportsRepository.fetchAllUserReportsFromDb();
        isLoading = false;
        notifyListeners();
        debugPrint("Fetched admin user reports from API.");
      } else {
        SnackBarService.showCustomSnackBar(
            context: context,
            leading: const Icon(Icons.perm_scan_wifi_outlined),
            content: const Text("Could not connect to server"));
        debugPrint(
            "No internet connection, could not fetch admin user reports from API.");
      }
    } catch (e) {
      _error = e.toString();
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Future<void> fetchAllReports(BuildContext context) async {
  //   try {
  //     _error = null; // Reset error here
  //     isLoading = true;
  //     _reports = await ReportServices().fetchAdminUserReports();
  //     isLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     _error = e.toString();
  //     isLoading = false;
  //     notifyListeners();
  //     rethrow;
  //   }
  // }
}
