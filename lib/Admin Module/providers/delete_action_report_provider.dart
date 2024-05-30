import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:safify/constants.dart';

class DeleteActionReportProvider extends ChangeNotifier {
  String? jwtToken;
  final storage = const FlutterSecureStorage();

  Future<bool> deleteActionReport(String actionReportId) async {
    jwtToken = await storage.read(key: 'jwt');
    Uri url =
        Uri.parse('$IP_URL/admin/dashboard/deleteActionReport/$actionReportId');
    try {
      //final response = await http.delete(Uri.parse(apiUrl));
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken', // Include JWT token in headers
        },
      );
      if (response.statusCode == 200) {
        // User report deleted successfully
        print('Action report deleted');
        notifyListeners();
        return true;
      } else {
        // Error deleting user report
        print('Error deleting action report - ${response.statusCode}');
        return false;
      }
    } catch (error) {
      // Handle network errors or other exceptions
      print('Exception: $error');
      return false;
    }
  }
}
