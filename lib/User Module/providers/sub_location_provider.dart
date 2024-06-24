import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'package:safify/repositories/sublocation_repository.dart';
import 'package:safify/utils/map_utils.dart';

import '../../constants.dart';
import '../../models/sub_location.dart';

class SubLocationProviderClass extends ChangeNotifier {
  List<SubLocation>? subLocationtPost;
  bool loading = false;
  String? selectedSubLocation;
  String? jwtToken;

  List<SubLocation>? allSubLocations;
  Map<String, List<SubLocation>> locationToSubLocationsMap = {};
  final SublocationRepository _sublocationRepository = SublocationRepository();

  final storage = const FlutterSecureStorage();

  Future<void> getSubLocationPostData(String locationId) async {
    loading = true;
    // Pass the selected incident type to the fetchIncidentSubTypes method
    // subLocationtPost = await fetchSubLocations(selectedLocation);
    if (allSubLocations == null) {
      try {
        final sublocations = await _sublocationRepository.fetchSublocations();
        setAllSubLocations(sublocations);
      } catch (e) {
        print('Error fetching sublocations: $e');
      }
    }
    subLocationtPost = getSubLocationsForLocation(locationId);
    loading = false;
    notifyListeners();
  }

  //  void updateFilteredIncidentSubtypes(String selectedIncidentType) {
  //   filteredIncidentSubTypes = subIncidentPost
  //       ?.where((subtype) => subtype.Incident_Type_ID == selectedIncidentType)
  //       .toList();
  //   selectedSubIncident = null; // Reset selectedSubIncident when filtering
  //   notifyListeners();
  // }

  void setSubLocationType(selectedVal) {
    selectedSubLocation = selectedVal;
    notifyListeners();
  }
  //IPs
  //stormfiber: 192.168.18.74
  //mobile data: 192.168.71.223

  Future<List<SubLocation>> fetchSubLocations(String selectedLocation) async {
    loading = true;
    jwtToken = await storage.read(key: 'jwt');
    notifyListeners();
    Uri url = Uri.parse(
        '$IP_URL/userReport/dashboard/fetchsublocations?location_id=$selectedLocation');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken', // Include JWT token in headers
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body) as List<dynamic>;
      print(jsonResponse);
      List<SubLocation> subIncidentList = jsonResponse
          .map((dynamic item) =>
              SubLocation.fromJson(item as Map<String, dynamic>, ''))
          .toList();
      loading = false;
      notifyListeners();
      return subIncidentList;
    }
    loading = false;
    notifyListeners();
    throw Exception('Failed to load location Sub Types');
  }

  void setAllSubLocations(List<SubLocation> allSubLocations) {
    this.allSubLocations = allSubLocations;
    locationToSubLocationsMap = makeSublocationMap(allSubLocations);

    notifyListeners();
  }

  List<SubLocation> getSubLocationsForLocation(String locationID) {
    return locationToSubLocationsMap[locationID] ?? [];
  }
}
