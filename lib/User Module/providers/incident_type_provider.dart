import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'package:safify/repositories/incident_types_repository.dart';

import '../../constants.dart';
import '../../models/incident_types.dart';

class IncidentProviderClass extends ChangeNotifier {
  List<IncidentType>? incidentPost;
  bool loading = false;
  String? selectedIncident;
  String? jwtToken;
  final storage = const FlutterSecureStorage();
  final IncidentTypesRepository _incidentTypesRepository =
      IncidentTypesRepository();

  getIncidentPostData() async {
    // loading = true;
    incidentPost = await _incidentTypesRepository.fetchIncidentTypes();
    // loading = false;
    notifyListeners();
  }

  setIncidentType(selectedVal) {
    selectedIncident = selectedVal;
    notifyListeners();
  }

  void refresh() async {
    final incidentTypes = await _incidentTypesRepository.fetchIncidentTypes();
    setIncidentType(incidentTypes);
    notifyListeners();
  }

  //IPs
  //stormfiber: 192.168.18.74
  //mobile data: 192.168.71.223
}
