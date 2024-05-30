// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:safify/Action%20Team%20Module/providers/update_user_report_status.dart';
import 'package:safify/User%20Module/pages/login_page.dart';
import 'package:safify/User%20Module/providers/fetch_user_report_provider.dart';
import 'package:safify/widgets/notification_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../models/action_report.dart';
import '../../models/assign_task.dart';
import '../../models/report.dart';

class ReportServices {
  final BuildContext context; // Include the BuildContext in the constructor

  ReportServices(this.context);
  // Constructor for ReportServices
  String? current_user_id;
  String? jwtToken;
  final storage = const FlutterSecureStorage();
  Notifications notifications = Notifications();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  UserReportsProvider userReportsProvider = UserReportsProvider();

  // void getUsername() async {

  // }

  Future<List<Reports>> fetchReports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    current_user_id = prefs.getString("user_id");
    jwtToken = await storage.read(key: 'jwt');

    Uri url =
        Uri.parse('$IP_URL/userReport/dashboard/$current_user_id/reports');
    // final response = await http.get(url);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken', // Include JWT token in headers
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> result = jsonResponse['result'] as List<dynamic>;
      List<Reports> reportList = result
          .map((dynamic item) => Reports.fromJson(item as Map<String, dynamic>))
          .toList();

      //Notification
      String isReportDeleted = jsonResponse['is_report_deleted'];
      String deletedReportId = jsonResponse['deleted_report_id'] ?? '';

      if (isReportDeleted == '1') {
        notifications.sendNotification(
          flutterLocalNotificationsPlugin,
          context,
          deletedReportId,
        );
        String? current_user_id = prefs.getString('user_id');
        await Provider.of<UserStatusProvider>(context, listen: false)
            .updateDeletedReportStatus(current_user_id!, false);
      }
      return reportList;
    } else {
      final responseBody = jsonDecode(response.body);
      final status = responseBody['status'];
      if (status == 'Invalid token.') {
        // Redirect to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }

    throw Exception('Failed to load Reports');
  }

  Future<List<AssignTask>> fetchAssignedReports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    current_user_id = prefs.getString('user_id');
    jwtToken = await storage.read(key: 'jwt');
    print('USER-ID: $current_user_id');
    Uri url = Uri.parse(
        '$IP_URL/actionTeam/dashboard/$current_user_id/fetchAssignedTasks');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken', // Include JWT token in headers
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> result = jsonResponse['result'] as List<dynamic>;
      List<AssignTask> reportList = result
          .map((dynamic item) =>
              AssignTask.fromJson(item as Map<String, dynamic>))
          .toList();

      //Notification
      String isReportDeleted = jsonResponse['is_report_deleted'];
      String? deletedReportId = jsonResponse['deleted_report_id'] ?? '';

      if (isReportDeleted == '1') {
        notifications.sendNotification(
          flutterLocalNotificationsPlugin,
          context,
          deletedReportId!,
        );
        String? current_user_id = prefs.getString('user_id');
        await Provider.of<UserStatusProvider>(context, listen: false)
            .updateDeletedReportStatus(current_user_id!, false);
      }

      return reportList;
    } else {
      final responseBody = jsonDecode(response.body);
      final status = responseBody['status'];
      if (status == 'Invalid token.') {
        // Redirect to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }

    throw Exception('Failed to load Reports');
  }

  Future<List<Reports>> fetchAllReports() async {
    jwtToken = await storage.read(key: 'jwt');
    Uri url = Uri.parse('$IP_URL/admin/dashboard/fetchAllUserReports');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken', // Include JWT token in headers
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body) as List<dynamic>;
      List<Reports> allReportList = jsonResponse
          .map((dynamic item) => Reports.fromJson(item as Map<String, dynamic>))
          .toList();
      return allReportList;
    } else {
      final responseBody = jsonDecode(response.body);
      final status = responseBody['message'];
      if (status == 'Invalid token.') {
        // Redirect to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }

    throw Exception('Failed to load all Reports');
  }

  Future<void> postapprovedActionReport(
      int? user_report_id, int? action_report_id) async {
    jwtToken = await storage.read(key: 'jwt');

    Uri url = Uri.parse('$IP_URL/admin/dashboard/approvedActionReport');

    await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $jwtToken'
      },
      body: jsonEncode(
        <String, dynamic>{
          "user_report_id": user_report_id,
          "action_report_id": action_report_id,
        },
      ),
    );
  }

  //TODO: post selected incident type id to return incident sub type

  Future<bool> postReport(
      String image,
      String sublocation,
      String incidentSubType,
      String description,
      DateTime date,
      String risklevel) async {
    jwtToken = await storage.read(key: 'jwt');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    current_user_id = prefs.getString("user_id");
    print('current_user_id:$current_user_id');
    Uri url =
        Uri.parse('$IP_URL/userReport/dashboard/$current_user_id/MakeReport');
    try {
      final http.Response response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $jwtToken'
        },
        body: jsonEncode(
          <String, dynamic>{
            "image": image,
            //  "id":id,
            "incident_subtype_id": sublocation,
            "sub_location_id": incidentSubType,
            "report_description": description,
            "date_time": date
                .toLocal()
                .toIso8601String()
                .split(".")[0], // Serialize DateTime to string
            //  "status":status, //how to update, initial false, will be changed by admin.
            "incident_criticality_id": risklevel
            //  "reported_by": reported_by
          },
        ),
      );
      final msg = json.decode(response.body)['message'];

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 500) {
        Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
        );

        return false;
      }
      if (msg == 'Invalid token.') {
        // Redirect to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: '$e',
        toastLength: Toast.LENGTH_SHORT,
      );
      // Handle network or unexpected errors
      return false;
    }
    return false;
  }

  Future<void> uploadReportWithImage(
      XFile? imageFile,
      String sublocation,
      String incidentSubType,
      String description,
      DateTime date,
      String risklevel) async {
    jwtToken = await storage.read(key: 'jwt');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    current_user_id = prefs.getString("user_id");
    print('current_user_id:$current_user_id');

    if (imageFile != null) {
      Uri apiUri =
          Uri.parse('$IP_URL/userReport/dashboard/$current_user_id/MakeReport');

      var request = http.MultipartRequest('POST', apiUri);
// Adding the authorization header
      request.headers['Authorization'] = 'Bearer $jwtToken';
      // Add other form data
      request.fields['report_description'] = description;
      request.fields['date_time'] = date
          .toLocal()
          .toIso8601String()
          .split(".")[0]; // Replace with actual date time
      request.fields['sub_location_id'] =
          sublocation; // Replace with actual sub location ID
      request.fields['incident_subtype_id'] =
          incidentSubType; // Replace with actual incident subtype ID
      request.fields['incident_criticality_id'] =
          risklevel; // Replace with actual incident criticality ID

      // Attach the image file
      request.files.add(await http.MultipartFile.fromPath(
        'image', // Field name specified in the API
        imageFile.path,
      ));
      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          await Provider.of<UserReportsProvider>(context, listen: false)
              .fetchReports(context);
          print('Report submitted successfully');
        } else {
          print('Failed to submit report');
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    } else {
      print('No image selected');
    }
  }

  Future<List<ActionReport>> fetchAllActionReports() async {
    jwtToken = await storage.read(key: 'jwt');

    Uri url = Uri.parse('$IP_URL/admin/dashboard/fetchAllActionReports');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken', // Include JWT token in headers
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body) as List<dynamic>;
      List<ActionReport> allReportList = jsonResponse
          .map((dynamic item) =>
              ActionReport.fromJson(item as Map<String, dynamic>))
          .toList();
      return allReportList;
    }

    throw Exception('Failed to load all Reports');
  }

  Future<bool> postAssignedReport(int user_report_id, String user_id,
      String action_team_id, String incident_criticality_id) async {
    jwtToken = await storage.read(key: 'jwt');

    Uri url = Uri.parse('$IP_URL/admin/dashboard/InsertAssignTask');
    try {
      final http.Response response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $jwtToken'
        },
        body: jsonEncode(
          <String, dynamic>{
            "user_report_id": user_report_id,
            "user_id": user_id,
            "action_team_id": action_team_id,
            "incident_criticality_id": incident_criticality_id
            //  "reported_by": reported_by
          },
        ),
      );
      final msg = json.decode(response.body)['message'];

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 500) {
        // Handle the case where user is not found or password is invalid
        return false;
      } else if (response.statusCode == 403) {
        final responseBody = jsonDecode(response.body);
        final status = responseBody['status'];
        if (status == 'Invalid token.') {
          // Redirect to login page
          Fluttertoast.showToast(msg: 'Session Timeout');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
          return false;
        }
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: '$e',
        toastLength: Toast.LENGTH_SHORT,
      );
      // Handle network or unexpected errors
      return false;
    }
    return false;
  }

  Future<bool> uploadActionReportWithImagesFuture(
      String? report_description,
      String? question_one,
      String? question_two,
      String? question_three,
      String? question_four,
      String? question_five,
      String? resolution_description,
      String? reported_by,
      XFile? surrounding_image,
      XFile? proof_image,
      int? user_report_id) async {
    jwtToken = await storage.read(key: 'jwt');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? current_user_id = prefs.getString("user_id");
    print('current_user_id:$current_user_id');

    if (proof_image != null) {
      Uri apiUri = Uri.parse(
          '$IP_URL/actionTeam/dashboard/$current_user_id/MakeActionReport'); // Replace with your API endpoint

      var request = http.MultipartRequest('POST', apiUri);

      // Adding the authorization header
      request.headers['Authorization'] = 'Bearer $jwtToken';

      // Add other form data
      request.fields['report_description'] = report_description!;
      request.fields['question_one'] =
          question_one!; // Replace with actual date time
      request.fields['question_two'] =
          question_two!; // Replace with actual sub location ID
      request.fields['question_four'] =
          question_four!; // Replace with actual incident subtype ID
      request.fields['question_five'] = question_five!;
      request.fields["resolution_description"] = resolution_description!;
      request.fields["reported_by"] = reported_by!;
      //   request.fields["surrounding_image"] = surrounding_image!;
      //   request.fields["proof_image"] = proof_image;
      request.fields["user_report_id"] = user_report_id.toString();
      //user_report_id!; // Replace with actual incident criticality ID

      // Attach the first image file
      if (surrounding_image != null)
        request.files.add(await http.MultipartFile.fromPath(
          'surrounding_image', // Field name specified in the API for the first image
          surrounding_image!.path,
        ));

      // Attach the second image file
      request.files.add(await http.MultipartFile.fromPath(
        'proof_image', // Field name specified in the API for the second image
        proof_image.path,
      ));

      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          print('Report submitted successfully');
          return true;
        } else if (response.statusCode == 500) {
          Fluttertoast.showToast(
            msg: '${response.statusCode}',
            toastLength: Toast.LENGTH_SHORT,
          );

          return false;
        } else {
          print('Failed to submit report');
          return false;
        }
      } catch (e) {
        print('Error occurred: $e');
        return false;
      }
    } else {
      print('One or both images are not selected');
      return false;
    }
  }

  Future<bool> postActionReport(
      String? report_description,
      String? question_one,
      String? question_two,
      String? question_three,
      String? question_four,
      String? question_five,
      XFile? resolution_description,
      String? reported_by,
      XFile? surrounding_image,
      String? proof_image,
      int? user_report_id) async {
    jwtToken = await storage.read(key: 'jwt');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    current_user_id = prefs.getString("user_id");
    print('current_user_id:$current_user_id');
    Uri url = Uri.parse(
        '$IP_URL/actionTeam/dashboard/$current_user_id/MakeActionReport');
    try {
      final http.Response response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $jwtToken'
        },
        body: jsonEncode(
          <String, dynamic>{
            "report_description": report_description,
            "question_one": question_one,
            "question_two": question_two,
            "question_three": question_three,
            "question_four": question_four,
            "question_five": question_five,
            "resolution_description": resolution_description,
            "reported_by": reported_by,
            "surrounding_image": surrounding_image,
            "proof_image": proof_image,
            "user_report_id": user_report_id
          },
        ),
      );
      final msg = json.decode(response.body)['status'];

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 500) {
        Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
        );

        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: '$e',
        toastLength: Toast.LENGTH_SHORT,
      );
      // Handle network or unexpected errors
      return false;
    }
    return false;
  }

  // Analytics----------------

// Future<CountResolved> fetchIncidentsResolved() async {
//   final response = await http.get(Uri.parse('http://$IP_URL:3000/analytics/fetchIncidentsResolved'));

//   if (response.statusCode == 200) {
//     // Parse the response and return the String value
//     return json.decode(response.body);
//   } else {
//     // If the server did not return a 200 OK response,
//     // throw an exception.
//     throw Exception('Failed to load data');
//   }
// }

//   Future<List<ActionReport>> fetchIncidentReported() async {
//   Uri url = Uri.parse('http://$IP_URL:3000/analytics/fetchIncidentsReported');
//   final response = await http.get(url);

//   if (response.statusCode == 200) {
//     List<dynamic> jsonResponse = jsonDecode(response.body) as List<dynamic>;
//     List<ActionReport> allReportList = jsonResponse
//         .map((dynamic item) => ActionReport.fromJson(item as Map<String, dynamic>))
//         .toList();
//     return allReportList;
//   }

//   throw Exception('Failed to load all Reports');
// }

//Image handling
  Future<String?> uploadImage(File imageFile) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$IP_URL/api/image/upload'));

      // Adding the authorization header
      request.headers['Authorization'] = 'Bearer $jwtToken';

      // Attach the image file to the request
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      // Send the request
      var response = await request.send();

      // Process the response
      if (response.statusCode == 200) {
        print('Image uploaded successfully');

        // Assuming Cloudinary returns the image URL in the response
        final imageUrl = await response.stream.bytesToString();

        print('Image URL: $imageUrl');

        // Return the image URL
        return imageUrl;
      } else {
        print('Failed to upload image');
        return null;
      }
    } catch (error) {
      print('Error uploading image: $error');
      return null;
    }
  }
}
