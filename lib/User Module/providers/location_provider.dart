// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'package:safify/models/location.dart';

import '../../constants.dart';

class LocationProviderClass extends ChangeNotifier {
  List<Location>? LocationPost;
  bool loading = false;
  String? selectedLocation;


  getLocationPostData() async {
    // loading = true;
    LocationPost = (await fetchLocations());
    // loading = false;
    notifyListeners();
  }
      setLocation(selectedVal){
      selectedLocation = selectedVal;
      notifyListeners();
    }
    //IPs
    //stormfiber: 192.168.18.74
    //mobile data: 192.168.71.223

    Future<List<Location>> fetchLocations() async {
    loading = true;
    notifyListeners();
    Uri url = Uri.parse('$IP_URL/userReport/dashboard/fetchlocations');
    final response = await http.get(url);
          //   Fluttertoast.showToast(
          //   msg: 'locations status:${response.statusCode}',
          //   toastLength: Toast.LENGTH_SHORT,
          // );


  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = jsonDecode(response.body) as List<dynamic>;
    List<Location> incidentList = jsonResponse
        .map((dynamic item) => Location.fromJson(item as Map<String, dynamic>))
        .toList();
      loading = false;
      notifyListeners();
    return incidentList;
  }
   loading = false;
    notifyListeners();
    throw Exception('Failed to load Location');
    }



  
}