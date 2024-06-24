import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;

import 'package:safify/constants.dart';
import 'package:safify/models/location.dart';
import 'package:safify/models/sub_location.dart';
import 'package:safify/utils/json_utils.dart';

class LocationsDataService {
  final storage = FlutterSecureStorage();
  List<Location>? _locations;
  List<SubLocation>? _subLocations;

  Future<List<Location>> fetchLocations() async {
    if (_locations == null) {
      final lists = await getLocationsAndSublocations();
      _locations = lists[0] as List<Location>;
      _subLocations = lists[1] as List<SubLocation>;
    }

    return _locations!;
  }

  Future<List<SubLocation>> fetchSubLocations() async {
    if (_subLocations == null) {
      final lists = await getLocationsAndSublocations();
      _locations = lists[0] as List<Location>;
      _subLocations = lists[1] as List<SubLocation>;
    }

    return _subLocations!;
  }

  Future<void> refetchLists() async {
    final lists = await getLocationsAndSublocations();
    _locations = lists[0] as List<Location>;
    _subLocations = lists[1] as List<SubLocation>;
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
