import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/api_config.dart';

class AuthService {
  final storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '545892578879-n5snnijr8gmigdff0akvl2c21a28mf21.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final hasEmpresa = data['hasEmpresa'] ?? false;
        if (token != null) {
          await storage.write(key: 'jwt_token', value: token);
          return {'success': true, 'hasEmpresa': hasEmpresa};
        }
      } else {
        print('Registration failed: ${response.body}');
      }
    } catch (e) {
      print('Error during registration: $e');
    }
    return {'success': false, 'hasEmpresa': false};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final hasEmpresa = data['hasEmpresa'] ?? false;
        if (token != null) {
          await storage.write(key: 'jwt_token', value: token);
          return {'success': true, 'hasEmpresa': hasEmpresa};
        }
      } else {
        print('Login failed: ${response.body}');
      }
    } catch (e) {
      print('Error during login: $e');
    }
    return {'success': false, 'hasEmpresa': false};
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return {'success': false, 'error': 'Login cancelado por el usuario'};
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        return {'success': false, 'error': 'No se pudo obtener ningún Token de Google'};
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken ?? '',
          'accessToken': accessToken ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final hasEmpresa = data['hasEmpresa'] ?? false;
        
        if (token != null) {
          await storage.write(key: 'jwt_token', value: token);
          return {'success': true, 'hasEmpresa': hasEmpresa};
        }
      } else {
        print('Google Login failed: ${response.body}');
        return {'success': false, 'error': 'Fallo la autenticación en el servidor'};
      }
    } catch (e) {
      print('Error during Google login: $e');
      return {'success': false, 'error': e.toString()};
    }
    return {'success': false, 'hasEmpresa': false};
  }

  Future<void> logout() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (e) {
      print('Error during backend logout: $e');
    }

    await storage.delete(key: 'jwt_token');
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out of Google: $e');
    }
  }
}
