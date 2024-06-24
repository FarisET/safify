import 'package:http/http.dart' as http;
import 'package:safify/constants.dart';

Future<bool> ping_backend() async {
  try {
    print('Pinging server...');
    final response = await http.get(Uri.parse(IP_URL));
    // print("response: ${response.statusCode}");

    if (response.statusCode == 200) {
      print('Server is reachable');
      return true;
    } else {
      print('Server is not reachable');
      return false;
    }
  } catch (e) {
    print('Error pinging server: $e');
    return false;
  }
}
