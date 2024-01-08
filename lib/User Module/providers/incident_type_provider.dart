import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../models/incident_types.dart';

class IncidentProviderClass extends ChangeNotifier {
  List<IncidentType>? incidentPost;
  bool loading = false;
  String? selectedIncident;


  getIncidentPostData() async {
    // loading = true;
    incidentPost = (await fetchIncidentTypes());
    // loading = false;
    notifyListeners();
  }
      setIncidentType(selectedVal){
      selectedIncident = selectedVal;
      notifyListeners();
    }
    //IPs
    //stormfiber: 192.168.18.74
    //mobile data: 192.168.71.223

    Future<List<IncidentType>> fetchIncidentTypes() async {
    loading = true;
    notifyListeners();
    print('Fetching incident types...');   
    Uri url = Uri.parse('$IP_URL/userReport/dashboard/fetchincidentType');
    final response = await http.get(url);
          //   Fluttertoast.showToast(
          //   msg: '${response.statusCode}',
          //   toastLength: Toast.LENGTH_SHORT,
          // );


  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = jsonDecode(response.body) as List<dynamic>;
    List<IncidentType> incidentList = jsonResponse
        .map((dynamic item) => IncidentType.fromJson(item as Map<String, dynamic>))
        .toList();
      loading = false;
      notifyListeners();
      print('incident type Loaded');  
    return incidentList;
  }
   loading = false;
    notifyListeners();
    print('Failed to load incident types');
    throw Exception('Failed to load Incident Types');
    }



  
}