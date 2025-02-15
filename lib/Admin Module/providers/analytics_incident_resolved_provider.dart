import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:safify/repositories/analytics_repository.dart';
import 'package:safify/utils/network_util.dart';
import '../../constants.dart';

class CountIncidentsResolvedProvider extends ChangeNotifier {
  String? _totalIncidentsResolved;
  bool loading = false;
  String? jwtToken;
  final storage = const FlutterSecureStorage();
  final _analyticsRepository = AnalyticsRepository();

  String? get totalIncidentsResolved => _totalIncidentsResolved;

  Future<void> getCountResolved() async {
    try {
      loading = true;
      notifyListeners();

      final pingSuccess = await ping_google();

      if (!pingSuccess) {
        await getCountResolvedPostData();
      } else {
        await fetchIncidentsResolved();
      }
    } catch (e) {
      print("Error fetching resolved incidents: $e");
      _totalIncidentsResolved = "n/a";
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getCountResolvedPostData() async {
    try {
      final val =
          await _analyticsRepository.fetchTotalIncidentsResolvedFromDb();
      _totalIncidentsResolved = val?.toString() ?? "n/a";
      print("Total Incidents Resolved from DB: $_totalIncidentsResolved");
    } catch (e) {
      print("Error fetching from DB: $e");
      _totalIncidentsResolved = "n/a";
    }
  }

  Future<void> fetchIncidentsResolved() async {
    try {
      jwtToken = await storage.read(key: 'jwt');

      if (jwtToken == null) {
        throw Exception("JWT token not found.");
      }

      Uri url = Uri.parse('$IP_URL/analytics/fetchIncidentsResolved');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $jwtToken'},
      );

      if (response.statusCode == 200) {
        _totalIncidentsResolved = response.body;
        print("Incidents Resolved: $_totalIncidentsResolved");
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching from API: $e");
      _totalIncidentsResolved = "n/a";
    }
  }
}
