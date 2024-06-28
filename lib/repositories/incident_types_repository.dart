import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safify/api/incident_types_data_service.dart';
import 'package:safify/db/database_helper.dart';
import 'package:safify/models/incident_types.dart';
import 'package:safify/utils/network_util.dart';

class IncidentTypesRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final storage = const FlutterSecureStorage();

  Future<List<IncidentType>> fetchIncidentTypes() async {
    var pingSuccess = await ping_google();

    if (!pingSuccess) {
      return _fetchIncidentTypesFromDb();
    } else {
      try {
        return await _fetchIncidentTypesFromApi();
      } catch (e) {
        return _fetchIncidentTypesFromDb();
      }
    }
  }

  Future<List<IncidentType>> _fetchIncidentTypesFromApi() async {
    print("getting from api service");

    final incidentTypesDataService = IncidentTypesDataService();
    final incidentTypes = await incidentTypesDataService.fetchIncidentTypes();
    return incidentTypes;
  }

  Future<List<IncidentType>> _fetchIncidentTypesFromDb() async {
    return await _databaseHelper.getIncidentTypes();
  }
}
