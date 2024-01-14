import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:safify/constants.dart';

class DeleteUserReportProvider extends ChangeNotifier {
  Future<bool> deleteUserReport(String userReportId) async {
    final String apiUrl = '$IP_URL/admin/dashboard/deleteUserReport/$userReportId';
    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // User report deleted successfully
        print('User report deleted');
        notifyListeners();
        return true;
      } else {
        // Error deleting user report
        print('Error deleting user report - ${response.statusCode}');
        return false;
      }
    } catch (error) {
      // Handle network errors or other exceptions
      print('Exception: $error');
      return false;
    }

    
  }
}
