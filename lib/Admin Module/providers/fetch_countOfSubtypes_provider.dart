import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:safify/constants.dart';
import 'package:safify/models/count_incidents_by_subtype.dart';
import 'package:safify/repositories/analytics_repository.dart';
import 'package:safify/utils/network_util.dart';

class CountByIncidentSubTypesProviderClass extends ChangeNotifier {
  List<CountByIncidentSubTypes>? countByIncidentSubTypes;
  bool loading = false;
  String? jwtToken;
  final storage = const FlutterSecureStorage();
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();

  Future<void> getcountByIncidentSubTypes() async {
    try {
      loading = true;
      notifyListeners();

      final pingSuccess = await ping_google();

      if (!pingSuccess) {
        await getcountByIncidentSubTypesPostData();
      } else {
        await fetchTotalIncidentsOnSubTypes();
      }
    } catch (e) {
      print("Error fetching resolved incidents: $e");
      countByIncidentSubTypes = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<List<CountByIncidentSubTypes>?>
      getcountByIncidentSubTypesPostData() async {
    try {
      countByIncidentSubTypes =
          await _analyticsRepository.fetchIncidentSubtypeAnalyticsFromDb();
      loading = false;
      notifyListeners();
      return countByIncidentSubTypes;
    } catch (e) {
      loading = false;
      notifyListeners();
      throw Exception('Failed to load countByIncidentSubTypes');
    }
  }

  Future<List<CountByIncidentSubTypes>?> fetchTotalIncidentsOnSubTypes() async {
    try {
      jwtToken = await storage.read(key: 'jwt');
      if (jwtToken == null) {
        throw Exception('JWT token is invalid');
      }
      Uri url = Uri.parse('$IP_URL/analytics/fetchTotalIncidentsOnSubTypes');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        countByIncidentSubTypes = jsonResponse
            .map((item) => CountByIncidentSubTypes.fromJson(item))
            .toList();

        return countByIncidentSubTypes;
      } else {
        throw Exception('Failed to load countByIncidentSubTypes');
      }
    } catch (e) {
      countByIncidentSubTypes = [];
      return countByIncidentSubTypes;
    }
  }
}
