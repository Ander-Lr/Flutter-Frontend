import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ScrapingService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> startScraping(String idCuentaSocial) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        print('No JWT token found');
        return null;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/scraping/start/$idCuentaSocial'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error starting scraping: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception starting scraping: $e');
      return null;
    }
  }
}
