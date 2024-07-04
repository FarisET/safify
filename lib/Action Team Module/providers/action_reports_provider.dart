import 'package:flutter/material.dart';
import 'package:safify/models/action_report.dart';
import 'package:safify/repositories/admin_action_report_repository.dart';
import 'package:safify/services/snack_bar_service.dart';
import 'package:safify/utils/network_util.dart';

class ActionReportsProvider with ChangeNotifier {
  List<ActionReport>? _reports;
  List<ActionReport>? get reports => _reports;
  bool isLoading = false;
  String? _error;
  String? get error => _error;
  final AdminActionReportRepository _actionReportRepository =
      AdminActionReportRepository();

  Future<void> refresh(BuildContext context) {
    return fetchAllActionReports(context);
  }

  Future<void> fetchAllActionReports(BuildContext context) async {
    try {
      _error = null;
      isLoading = true;
      _reports = await _actionReportRepository.fetchAdminActionReportsFromDb();
      isLoading = false;

      notifyListeners();
      debugPrint("Fetched admin action reports from local database.");

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
        await _actionReportRepository.syncDb();
        _reports =
            await _actionReportRepository.fetchAdminActionReportsFromDb();
        isLoading = false;
        notifyListeners();
        debugPrint("Fetched admin action user reports from API.");
      } else {
        SnackBarService.showCustomSnackBar(
            context: context,
            leading: const Icon(Icons.perm_scan_wifi_outlined),
            content: const Text("Could not connect to server"));
        debugPrint(
            "No internet connection, could not fetch admin action reports from API.");
      }
    } catch (e) {
      _error = e.toString();
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Future<void> fetchAllActionReports(BuildContext context) async {
  //   try {
  //     _error = null;
  //     isLoading = true;
  //     _reports = await ReportServices().fetchAdminActionReports();
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
