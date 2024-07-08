import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safify/dummy.dart';

class AnalyticsService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> fetchAnalytics() async {
    final json = analyticsJsonDummy;
    return json;
  }
}
