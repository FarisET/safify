import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../models/department.dart';


class DepartmentProviderClass extends ChangeNotifier {
  List<Department>? departmentPost;
  bool loading = false;
  String? selectedDepartment;


  getDepartmentPostData() async {
    // loading = true;
    departmentPost = (await fetchDepartments());
    // loading = false;
    notifyListeners();
  }
      setDepartmentType(selectedVal){
      selectedDepartment = selectedVal;
      notifyListeners();
    }


    Future<List<Department>> fetchDepartments() async {
    loading = true;
    notifyListeners();
    print('Fetching department...');   
    Uri url = Uri.parse('$IP_URL/admin/dashboard/fetchDepartments');
    final response = await http.get(url);
          //   Fluttertoast.showToast(
          //   msg: '${response.statusCode}',
          //   toastLength: Toast.LENGTH_SHORT,
          // );


  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = jsonDecode(response.body) as List<dynamic>;
    List<Department> departmentList = jsonResponse
        .map((dynamic item) => Department.fromJson(item as Map<String, dynamic>))
        .toList();
      loading = false;
      notifyListeners();
      print('department Loaded');  
    return departmentList;
  }
   loading = false;
    notifyListeners();
    print('Failed to load department');
    throw Exception('Failed to load departments');
    }



  
}