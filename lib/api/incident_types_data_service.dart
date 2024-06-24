import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;

import 'package:safify/constants.dart';
import 'package:safify/models/incident_types.dart';

class IncidentTypesDataService {
  final storage = FlutterSecureStorage();
  List<IncidentType>? _incidentTypes;
  List<IncidentType>? _subLocations;

  Future<List<IncidentType>> fetchIncidentTypes() async {
    if (_incidentTypes == null) {
      final lists = await getIncidentTypes();
      _incidentTypes = lists;
    }

    return _incidentTypes!;
  }

  Future<void> refetchLists() async {
    final lists = await getIncidentTypes();
    _incidentTypes = lists;
  }

  Future<List<List<dynamic>>> getLocationsAndSublocations() async {
    String? jwtToken = await storage.read(key: 'jwt');
    Uri url =
        Uri.parse('$IP_URL/userReport/dashboard/getLocationsAndSubLocations');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken', // Include JWT token in headers
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<List<dynamic>> lists = parseLocationsAndSubLocations(jsonResponse);
      return lists;
    } else {
      throw Exception('Failed to load locations from API');
    }
  }
}
