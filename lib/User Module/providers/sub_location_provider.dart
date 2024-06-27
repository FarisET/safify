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

  void setSubLocationType(selectedVal) {
    selectedSubLocation = selectedVal;
    notifyListeners();
  }

  void setAllSubLocations(List<SubLocation> allSubLocations) {
    this.allSubLocations = allSubLocations;
    locationToSubLocationsMap = makeSublocationMap(allSubLocations);

    notifyListeners();
  }

  List<SubLocation> getSubLocationsForLocation(String locationID) {
    return locationToSubLocationsMap[locationID] ?? [];
  }

  void refresh() async {
    final sublocations = await _sublocationRepository.fetchSublocations();
    setAllSubLocations(sublocations);
    notifyListeners();
  }
}

//IPs
//stormfiber: 192.168.18.74
//mobile data: 192.168.71.223
  