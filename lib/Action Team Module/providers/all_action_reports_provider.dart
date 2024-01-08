import 'package:flutter/material.dart';

import '../../User Module/services/ReportServices.dart';
import '../../models/action_report.dart';

class ActionReportsProvider with ChangeNotifier {
  List<ActionReport> _reports = [];
  List<ActionReport> get reports => _reports;
  bool isLoading = false;

  Future<void> fetchAllActionReports(BuildContext context) async {
    try {
      isLoading=true;
      _reports = await ReportServices(context).fetchAllActionReports();
      isLoading=false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
