import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/cuenta_social.dart';

class SocialAccountService {
  final storage = const FlutterSecureStorage();

  Future<List<CuentaSocial>> getCuentasSociales() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      
      if (token == null) {
        print('No JWT token found');
        return [];
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/cuentas-sociales'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Decode dealing with UTF-8 to prevent weird characters
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => CuentaSocial.fromJson(json)).toList();
      } else {
        print('Failed to load cuentas sociales: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching cuentas sociales: $e');
      return [];
    }
  }

  Future<bool> createCuentaSocial(Map<String, dynamic> data) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      
      if (token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cuentas-sociales'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create cuenta social: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating cuenta social: $e');
      return false;
    }
  }
}
