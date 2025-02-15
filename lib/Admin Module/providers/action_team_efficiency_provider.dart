import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:safify/models/action_team_efficiency.dart';
import 'package:safify/repositories/analytics_repository.dart';
import 'package:safify/utils/network_util.dart';

import '../../constants.dart';

class ActionTeamEfficiencyProviderClass extends ChangeNotifier {
  List<ActionTeamEfficiency>? actionTeamEfficiency;
  bool loading = false;
  String? jwtToken;
  final storage = const FlutterSecureStorage();
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();

  Future<void> getactionTeamEfficiency() async {
    try {
      loading = true;
      notifyListeners();
      final ping = await ping_google();
      if (!ping) {
        await getactionTeamEfficiencyPostData();
      } else {
        await fetchActionTeamEfficiency();
      }
    } catch (e) {
      print("Error fetching locations: $e");
      actionTeamEfficiency = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<List<ActionTeamEfficiency>?> getactionTeamEfficiencyPostData() async {
    try {
      actionTeamEfficiency =
          await _analyticsRepository.fetchActionTeamEfficiencyAnalyticsFromDb();

      return actionTeamEfficiency;
    } catch (e) {
      throw Exception('Failed to load efficiencies from local db');
    }
  }

  Future<List<ActionTeamEfficiency>?> fetchActionTeamEfficiency() async {
    try {
      jwtToken = await storage.read(key: 'jwt');

      Uri url = Uri.parse('$IP_URL/analytics/fetchEfficiency');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken', // Include JWT token in headers
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.isNotEmpty) {
          List<Map<String, dynamic>> incidentsData = (jsonResponse).cast<
              Map<String, dynamic>>(); // Explicitly cast each item in the list

          // Map the incident data to your CountByIncidentSubTypes model
          actionTeamEfficiency = incidentsData
              .map((item) => ActionTeamEfficiency.fromJson(item))
              .toList();

          return actionTeamEfficiency;
        } else {
          throw Exception('Invalid format in JSON response');
        }
      }

      throw Exception('Failed to load ActionTeamEfficiency');
    } catch (e) {
      actionTeamEfficiency = [];
      return actionTeamEfficiency;
    }
  }
}
