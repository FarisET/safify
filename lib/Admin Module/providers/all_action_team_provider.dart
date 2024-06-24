import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../models/action_team.dart';

class AllActionTeamProviderClass extends ChangeNotifier {
  List<ActionTeam>? allActionTeams;
  bool loading = false;
  String? selectedActionTeam;
  String? jwtToken;
  final storage = const FlutterSecureStorage();

  Future<void> getAllActionTeams(String selectedDepartment) async {
    loading = true;
    allActionTeams = await fetchAllActionTeams();
    loading = false;
    notifyListeners();
  }

  void setActionTeam(selectedVal) {
    selectedActionTeam = selectedVal;
    notifyListeners();
  }

  Future<List<ActionTeam>> fetchAllActionTeams() async {
    loading = true;
    notifyListeners();
    jwtToken = await storage.read(key: 'jwt');

    Uri url =
        Uri.parse('$IP_URL/admin/dashboard/fetchAllActionTeamsWithDepartments');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken', // Include JWT token in headers
      },
    );
    //   Fluttertoast.showToast(
    //   msg: '${response.statusCode}',
    //   toastLength: Toast.LENGTH_SHORT,
    // );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body) as List<dynamic>;
      List<ActionTeam> actionTeamList = jsonResponse
          .map((dynamic item) =>
              ActionTeam.fromJson(item as Map<String, dynamic>))
          .toList();
      loading = false;
      notifyListeners();
      return actionTeamList;
    }
    loading = false;
    notifyListeners();
    throw Exception('Failed to load action teams');
  }
}
