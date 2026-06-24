import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class EmpresaService {
  final storage = const FlutterSecureStorage();

  Future<bool> createEmpresa(Map<String, dynamic> empresaData) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      
      if (token == null) {
        print('No JWT token found');
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/empresas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(empresaData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Empresa creada exitosamente: ${response.body}');
        return true;
      } else {
        print('Failed to create empresa: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating empresa: $e');
      return false;
    }
  }
}
