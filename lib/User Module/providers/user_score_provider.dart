import 'package:flutter/material.dart';
import 'package:safify/repositories/user_reports_repository.dart';
import 'package:safify/services/toast_service.dart';
import 'package:safify/utils/network_util.dart';
import '../../models/user_report.dart';
import '../../services/report_service.dart';

class UserScoreProvider with ChangeNotifier {
  ReportServices reportServices = ReportServices();

  bool isLoading = false;
  String? _error;
  String? get error => _error;
  String? _score;
  String? get score => _score;

  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<String> fetchScore(BuildContext context) async {
    try {
      _error = null;
      isLoading = true;
      notifyListeners();

      debugPrint("Checking network connection...");
      final ping = await ping_google();

      if (ping) {
        _score = await reportServices.getUserScore();
        debugPrint("Fetched user's reports from API.");
      } else {
        debugPrint("No internet connection");
        _score = "n/a"; // Set score to "Offline" when no internet
      }

      isLoading = false;
      notifyListeners();
      return "Score updated";
    } catch (e) {
      _error = e.toString();
      _score = "Offline";
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
