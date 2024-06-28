import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safify/api/locations_data_service.dart';
import 'package:safify/db/database_helper.dart';
import 'package:safify/models/location.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safify/constants.dart';
import 'package:safify/utils/network_util.dart';

class LocationRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final storage = const FlutterSecureStorage();

  Future<List<Location>> fetchLocations() async {
    var pingSuccess = await ping_google();

    if (!pingSuccess) {
      return _fetchLocationsFromDb();
    } else {
      try {
        return await _fetchLocationsFromApi();
      } catch (e) {
        return _fetchLocationsFromDb();
      }
    }
  }

  Future<List<Location>> _fetchLocationsFromApi() async {
    print("getting from api service");

    final locationService = LocationsDataService();
    final locations = await locationService.fetchLocations();
    return locations;
  }

  Future<List<Location>> _fetchLocationsFromDb() async {
    return await _databaseHelper.getLocations();
  }
}
