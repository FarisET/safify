import 'package:flutter/material.dart';

import '../../services/ReportServices.dart';
import '../../models/action_report.dart';

class ActionReportsProvider with ChangeNotifier {
  List<ActionReport> _reports = [];
  List<ActionReport> get reports => _reports;
  bool isLoading = false;
  String? _error;
  String? get error => _error;

  Future<void> fetchAllActionReports(BuildContext context) async {
    try {
      _error = null;
      isLoading = true;
      _reports = await ReportServices().fetchAllActionReports();
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
