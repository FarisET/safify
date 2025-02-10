import 'package:flutter/material.dart';
import 'package:safify/repositories/user_reports_repository.dart';
import 'package:safify/utils/network_util.dart';
import '../../models/user_report.dart';
import '../../services/report_service.dart';

class UserReportsProvider with ChangeNotifier {
  List<UserReport> _reports = [];
  int? _score;

  List<UserReport> get reports => _reports;
  int? get score => _score;

  bool isLoading = false;
  String? _error;
  String? get error => _error;

  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  final UserReportsRepository _userReportsRepository = UserReportsRepository();

  void addReport(UserReport report) {
    _reports.add(report);
    notifyListeners();
  }

  Future<String> fetchReports(BuildContext context) async {
    try {
      _error = null;
      isLoading = true;
      _reports = await _userReportsRepository.fetchUserReportsFromDb();
      isLoading = false;
      notifyListeners();

      debugPrint("Fetched admin action reports from local database.");
      final ping = await ping_google();

      if (ping) {
        await _userReportsRepository.syncDb();
        _reports = await _userReportsRepository.fetchUserReportsFromDb();
        isLoading = false;
        notifyListeners();
        debugPrint("Fetched user's reports from API.");
        return "successfully fetched user reports from API";
      } else {
        debugPrint(
            "No internet connection, could not fetch user's reports from API.");
        return "failed to fetch user reports from API.";
      }
    } catch (e) {
      _error = e.toString();
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Future<void> fetchScore() async {
  //   try {
  //     final result = await _userReportsRepository.fetchUserScore();
  //     _score = result.score;
  //     notifyListeners();
  //   } catch (e) {
  //     _error = e.toString();
  //     notifyListeners();
  //   }
  // }
}
