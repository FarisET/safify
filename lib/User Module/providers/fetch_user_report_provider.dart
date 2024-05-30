import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../services/ReportServices.dart';

class UserReportsProvider with ChangeNotifier {
  List<Reports> _reports = [];
  List<Reports> get reports => _reports;
  bool isLoading = false;

  void addReport(Reports report) {
    _reports.add(report);
    notifyListeners();
  }

  Future<void> fetchReports(BuildContext context) async {
    try {
      isLoading = true;
      _reports = await ReportServices(context).fetchReports();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
