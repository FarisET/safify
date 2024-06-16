import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../../services/ReportServices.dart';

class UserReportsProvider with ChangeNotifier {
  List<Reports> _reports = [];
  List<Reports> get reports => _reports;
  bool isLoading = false;
  String? _error;
  String? get error => _error;

  void addReport(Reports report) {
    _reports.add(report);
    notifyListeners();
  }

  Future<void> fetchReports(BuildContext context) async {
    try {
      isLoading = true;
      _error = null; // Reset error state before fetching
      _reports = await ReportServices(context).fetchReports();
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
