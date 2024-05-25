import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../models/count_incidents_by_subtype.dart';

class CountByIncidentSubTypesProviderClass extends ChangeNotifier {
  List<CountByIncidentSubTypes>? countByIncidentSubTypes;
  bool loading = false;
//  String? selectedDepartment;

  Future<List<CountByIncidentSubTypes>?>
      getcountByIncidentSubTypesPostData() async {
    loading = true;
    notifyListeners();

    try {
      countByIncidentSubTypes = await fetchTotalIncidentsOnSubTypes();
      loading = false;
      notifyListeners();

      return countByIncidentSubTypes;
    } catch (e) {
      loading = false;
      notifyListeners();
      print('Error loading countByIncidentSubTypes: $e');
      // You might want to handle the error accordingly
      throw Exception('Failed to load countByIncidentSubTypes');
    }
  }

  Future<List<CountByIncidentSubTypes>> fetchTotalIncidentsOnSubTypes() async {
    loading = true;
    notifyListeners();
    print('Fetching countByIncidentSubTypes...');

    Uri url = Uri.parse('$IP_URL/analytics/fetchTotalIncidentsOnSubTypes');
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
        List<CountByIncidentSubTypes> countByIncidentSubTypesList =
            incidentsData
                .map((item) => CountByIncidentSubTypes.fromJson(item))
                .toList();

        loading = false;
        notifyListeners();
        print('countByIncidentSubTypes Loaded');
        return countByIncidentSubTypesList;
      } else {
        loading = false;
        notifyListeners();
        print('Invalid format in JSON response');
        throw Exception('Invalid format in JSON response');
      }
    }

    loading = false;
    notifyListeners();
    print('Failed to load countByIncidentSubTypes');
    throw Exception('Failed to load countByIncidentSubTypes');
  }
}
