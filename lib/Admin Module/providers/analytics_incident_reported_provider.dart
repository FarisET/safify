import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../constants.dart';

class CountIncidentsReportedProvider extends ChangeNotifier {
  String? _totalIncidentsReported;
  bool loading = false;

  String? get totalIncidentsReported => _totalIncidentsReported;

  getCountReportedPostData() async {
    loading = true;
    _totalIncidentsReported = await fetchIncidentsReported();
    loading = false;
    notifyListeners();
  }

  Future<String> fetchIncidentsReported() async {
    loading = true;
    final response = await http.get(Uri.parse('$IP_URL/analytics/fetchIncidentsReported'));
    if (response.statusCode == 200) {
      loading = false;
      notifyListeners();
      // Parse the response and return the String value
      return response.body; // Assuming response.body is a String
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      loading = false;
      notifyListeners();
      throw Exception('Failed to load data');
    }
  }
}

