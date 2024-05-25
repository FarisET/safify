import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class UserServices {
//  final BuildContext context;  // Include the BuildContext in the constructor

  // UserServices(this.context);  // Constructor for UserServices

  final storage = const FlutterSecureStorage();

  Future<void> storeJwtAndRole(String jwt, String role, String userName) async {
    await storage.write(key: 'jwt', value: jwt);
    await storage.write(key: 'role_name', value: role);
    await storage.write(key: 'user_name', value: userName);
  }

  Future<String?> getJwt() async {
    return await storage.read(key: 'jwt');
  }

  Future<String?> getRole() async {
    return await storage.read(key: 'role_name');
  }

  Future<String?> getName() async {
    return await storage.read(key: 'user_name');
  }

//   Future<bool> login(String id, String password) async {
//     Uri url = Uri.parse('http://${IP_URL}:3000/user/login');
//     try {
//       final http.Response response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(
//           <String, String>{
//             "user_id": id,
//             "user_pass": password,
//           },
//         ),
//       );
//       final status = json.decode(response.body)['status'];
//       final user_name = json.decode(response.body)['user_name'];
//       final role = json.decode(response.body)['role'];

//       if (response.statusCode == 200) {
//         final jsonBody = json.decode(response.body);
//        // return true;
//           // User user = User.fromJson(jsonBody);
//           // print(user);
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setString("user_name", user_name);
//           await prefs.setString("role", role);

//           print('user name: $user_name');
//           return true;

//       } else if (response.statusCode == 401) {
//     //    print(status);
//             Fluttertoast.showToast(
//             msg: status,
//             toastLength: Toast.LENGTH_SHORT,
//           );

//         // Handle the case where user is not found or password is invalid
//           return false;
//       }
//     } catch (e) {
//         Fluttertoast.showToast(
//             msg: '$e',
//             toastLength: Toast.LENGTH_SHORT,
//           );
//       // Handle network or unexpected errors
//       return false;
//     }
//     return false;
//   }

//   Future<void> logout() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.remove("user_id");

// }

  Future<void> logout() async {
    await storage.delete(key: 'jwt');
    await storage.delete(key: 'role_name');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("user_id");
  }

  Future<bool> login(String id, String password) async {
    Uri url = Uri.parse('$IP_URL/user/login');
    try {
      final http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          <String, String>{
            "user_id": id,
            "user_pass": password,
          },
        ),
      );
      final status = json.decode(response.body)['status'];
      final token = json.decode(response.body)['token'];

      if (response.statusCode == 200) {
        if (token != null) {
          final decodedToken = parseJwt(token);

          // Check if 'role' is not null before using it
          String? role = decodedToken['role_name'];
          String? userName = decodedToken['user_name'];

          if (role != null) {
            await storeJwtAndRole(token, role, userName!);
            return true;
          }
        }
      } else if (response.statusCode == 401) {
        Fluttertoast.showToast(
          msg: status,
          toastLength: Toast.LENGTH_SHORT,
        );

        return false;
      }
    } catch (e) {
      print('exception:$e');
      Fluttertoast.showToast(
        msg: '$e',
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }

    return false;
  }

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Invalid payload');
    }

    return payloadMap;
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }

    return utf8.decode(base64Url.decode(output));
  }
}
