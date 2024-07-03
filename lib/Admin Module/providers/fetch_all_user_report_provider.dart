import 'package:flutter/material.dart';
import 'package:safify/models/token_expired.dart';
import '../../services/ReportServices.dart';
import '../../models/user_report.dart';

class AllUserReportsProvider with ChangeNotifier {
  List<UserReport> _reports = [];
  List<UserReport> get reports => _reports;
  bool isLoading = false;
  String? _error;
  String? get error => _error;

  Future<void> fetchAllReports(BuildContext context) async {
    try {
      _error = null; // Reset error here
      isLoading = true;
      _reports = await ReportServices().fetchAllReports();
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
