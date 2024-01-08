import 'package:flutter/material.dart';
import '../../User Module/services/ReportServices.dart';
import '../../models/report.dart';

class AllUserReportsProvider with ChangeNotifier {
  List<Reports> _reports = [];
  List<Reports> get reports => _reports;
  bool isLoading = false;

  Future<void> fetchAllReports(BuildContext context) async {
    try {
      isLoading=true;
      _reports = await ReportServices(context).fetchAllReports();
      isLoading=false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
