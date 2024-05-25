import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:safify/models/count_incidents_by_location.dart';

import '../../constants.dart';

class CountByLocationProviderClass extends ChangeNotifier {
  List<CountByLocation>? countByLocation;
  bool loading = false;
//  String? selectedDepartment;

  Future<List<CountByLocation>?> getcountByIncidentLocationPostData() async {
    loading = true;
    notifyListeners();

    try {
      countByLocation = await fetchTotalIncidentsLocation();
      loading = false;
      notifyListeners();

      return countByLocation;
    } catch (e) {
      loading = false;
      notifyListeners();
      print('Error loading countByIncidentSubTypes: $e');
      // You might want to handle the error accordingly
      throw Exception('Failed to load countByIncidentSubTypes');
    }
  }

  Future<List<CountByLocation>> fetchTotalIncidentsLocation() async {
    loading = true;
    notifyListeners();
    print('Fetching countByIncidentSubTypes...');

    Uri url = Uri.parse('$IP_URL/analytics/fetchTotalIncidentsOnLocations');
    final response = await http.get(url);

    // Fluttertoast.showToast(
    //   msg: '${response.statusCode}',
    //   toastLength: Toast.LENGTH_SHORT,
    // );

    if (response.statusCode == 200) {
      // Parse the JSON response
      List<dynamic> jsonResponse = jsonDecode(response.body);

      // Ensure that jsonResponse[0] is a List<Map<String, dynamic>>
      if (jsonResponse.isNotEmpty && jsonResponse[0] is List<dynamic>) {
        List<Map<String, dynamic>> incidentsData =
            (jsonResponse[0] as List<dynamic>).cast<
                Map<String,
                    dynamic>>(); // Explicitly cast each item in the list

        // Map the incident data to your CountByIncidentSubTypes model
        List<CountByLocation> countByIncidentLocationList = incidentsData
            .map((item) => CountByLocation.fromJson(item))
            .toList();

        loading = false;
        notifyListeners();
        print('countByLocation Loaded');
        return countByIncidentLocationList;
      } else {
        loading = false;
        notifyListeners();
        print('Invalid format in JSON response');
        throw Exception('Invalid format in JSON response');
      }
    }

    loading = false;
    notifyListeners();
    print('Failed to load countByIncidentLocations');
    throw Exception('Failed to load countByIncidentLocations');
  }
}
