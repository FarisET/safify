import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:safify/models/count_incidents_by_location.dart';
import 'package:safify/repositories/analytics_repository.dart';
import 'package:safify/utils/network_util.dart';

import '../../constants.dart';

class CountByLocationProviderClass extends ChangeNotifier {
  List<CountByLocation>? countByLocation;
  bool loading = false;
  String? jwtToken;
  final storage = const FlutterSecureStorage();
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();

  Future<void> getcountByIncidentLocation() async {
    try {
      loading = true;
      notifyListeners();

      final pingSuccess = await ping_google();

      if (!pingSuccess) {
        await getcountByIncidentLocationPostData();
      } else {
        await fetchTotalIncidentsLocation();
      }
    } catch (e) {
      print("Error fetching locations: $e");
      countByLocation = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<List<CountByLocation>?> getcountByIncidentLocationPostData() async {
    try {
      countByLocation =
          await _analyticsRepository.fetchIncidentLocationAnalyticsFromDb();
      return countByLocation;
    } catch (e) {
      throw Exception('Failed to load count by location subtypes');
    }
  }

  Future<List<CountByLocation>?> fetchTotalIncidentsLocation() async {
    try {
      jwtToken = await storage.read(key: 'jwt');
      if (jwtToken == null) {
        throw Exception('JWT token is null');
      }

      Uri url = Uri.parse('$IP_URL/analytics/fetchTotalIncidentsOnLocations');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        countByLocation = jsonResponse
            .map((item) =>
                CountByLocation.fromJson(item as Map<String, dynamic>))
            .toList();

        return countByLocation;
      } else {
        throw Exception('Failed to load countByIncidentLocations');
      }
    } catch (e) {
      countByLocation = [];
      return countByLocation;
    }
  }
}
