import 'package:flutter/material.dart';
import 'package:safify/repositories/user_reports_repository.dart';
import 'package:safify/services/toast_service.dart';
import 'package:safify/utils/network_util.dart';
import '../../models/user_report.dart';
import '../../services/report_service.dart';

class UserReportsProvider with ChangeNotifier {
  List<UserReport> _reports = [];
  List<UserReport> get reports => _reports;
  bool isLoading = false;
  String? _error;
  String? get error => _error;
  final UserReportsRepository _userReportsRepository = UserReportsRepository();

  void addReport(UserReport report) {
    _reports.add(report);
    notifyListeners();
  }

  Future<void> fetchReports(BuildContext context) async {
    try {
      _error = null;
      isLoading = true;
      _reports = await _userReportsRepository.fetchUserReportsFromDb();
      isLoading = false;

      notifyListeners();
      debugPrint("Fetched admin action reports from local database.");

      final ping = await ping_google();

      if (ping) {
        ToastService.showSyncingLocalDataSnackBar(context);
        await _userReportsRepository.syncDb();
        _reports = await _userReportsRepository.fetchUserReportsFromDb();
        isLoading = false;
        notifyListeners();
        debugPrint("Fetched user's reports from API.");
      } else {
        ToastService.showNoConnectionSnackBar(context);
        debugPrint(
            "No internet connection, could not fetch user's reports from API.");
      }
    } catch (e) {
      _error = e.toString();
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
