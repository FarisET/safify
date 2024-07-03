import 'package:flutter/material.dart';
import '../../models/user_report.dart';
import '../../services/ReportServices.dart';

class UserReportsProvider with ChangeNotifier {
  List<UserReport> _reports = [];
  List<UserReport> get reports => _reports;
  bool isLoading = false;
  String? _error;
  String? get error => _error;

  void addReport(UserReport report) {
    _reports.add(report);
    notifyListeners();
  }

  Future<void> fetchReports(BuildContext context) async {
    try {
      _error = null;
      isLoading = true;
      _reports = await ReportServices().fetchReports();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
