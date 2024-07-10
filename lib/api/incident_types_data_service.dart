import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;

import 'package:safify/constants.dart';
import 'package:safify/models/incident_sub_type.dart';
import 'package:safify/models/incident_types.dart';
import 'package:safify/utils/json_utils.dart';

class IncidentTypesDataService {
  final storage = FlutterSecureStorage();
  List<IncidentType>? _incidentTypes;
  List<IncidentSubType>? _incidentSubtypes;

  Future<List<IncidentType>> fetchIncidentTypes() async {
    if (_incidentTypes == null) {
      final lists = await getIncidentTypesAndSubtypes();
      _incidentTypes = lists[0] as List<IncidentType>;
      _incidentSubtypes = lists[1] as List<IncidentSubType>;
    }

    return _incidentTypes!;
  }

  Future<List<IncidentSubType>> fetchIncidentSubtypes() async {
    if (_incidentSubtypes == null) {
      final lists = await getIncidentTypesAndSubtypes();
      _incidentTypes = lists[0] as List<IncidentType>;
      _incidentSubtypes = lists[1] as List<IncidentSubType>;
    }

    return _incidentSubtypes!;
  }

  Future<void> refetchLists() async {
    final lists = await getIncidentTypesAndSubtypes();
    _incidentTypes = lists[0] as List<IncidentType>;
    _incidentSubtypes = lists[1] as List<IncidentSubType>;
  }

  Future<List<List<dynamic>>> getIncidentTypesAndSubtypes() async {
    String? jwtToken = await storage.read(key: 'jwt');
    Uri url = Uri.parse(
        '$IP_URL/userReport/dashboard/getIncidentTypesAndIncidentSubTypes');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken', // Include JWT token in headers
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<List<dynamic>> lists =
          parseIncidentAndSubIncidentTypes(jsonResponse);
      return lists;
    } else {
      throw Exception('Failed to load locations from API');
    }
  }

  Future<Map<String, dynamic>> fetchIncidentTypesAndSubtypesJson() async {
    String? jwtToken = await storage.read(key: 'jwt');
    Uri url = Uri.parse(
        '$IP_URL/userReport/dashboard/getIncidentTypesAndIncidentSubTypes');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken', // Include JWT token in headers
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to load locations from API');
    }
  }
}
