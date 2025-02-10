import 'package:shared_preferences/shared_preferences.dart';
import 'package:safify/services/UserServices.dart';

class UserUtils {
  String? userName;
  String? userId;
  final UserServices _userServices = UserServices();

  Future<void> loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = await _userServices.getName();
    userId = prefs.getString("user_id");
  }
}
