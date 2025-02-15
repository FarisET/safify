import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:safify/repositories/analytics_repository.dart';
import 'package:safify/utils/network_util.dart';
import '../../constants.dart';

class CountIncidentsReportedProvider extends ChangeNotifier {
  String? _totalIncidentsReported;
  bool loading = false;
  String? jwtToken;
  final storage = const FlutterSecureStorage();
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();

  String? get totalIncidentsReported => _totalIncidentsReported;

  Future<void> getCountReported() async {
    try {
      loading = true;
      notifyListeners();

      final pingSuccess = await ping_google();

      if (!pingSuccess) {
        await getCountReportedPostData();
      } else {
        await fetchIncidentsReported();
      }
    } catch (e) {
      print("Error fetching resolved incidents: $e");
      _totalIncidentsReported = "n/a";
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  getCountReportedPostData() async {
    try {
      final val =
          await _analyticsRepository.fetchTotalIncidentsReportedFromDb();
      _totalIncidentsReported = val != null ? val.toString() : "n/a";
      loading = false;
      notifyListeners();
    } catch (e) {
      _totalIncidentsReported = "n/a";
    }
  }

  Future<void> fetchIncidentsReported() async {
    try {
      jwtToken = await storage.read(key: 'jwt');
      Uri url = Uri.parse('$IP_URL/analytics/fetchIncidentsReported');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken', // Include JWT token in headers
        },
      );

      if (response.statusCode == 200) {
        loading = false;
        notifyListeners();

        _totalIncidentsReported =
            response.body; // Assuming response.body is a String
      } else {
        loading = false;
        notifyListeners();
        throw Exception('Failed to load data');
      }
    } catch (e) {
      _totalIncidentsReported = "n/a";
    }
  }
}
