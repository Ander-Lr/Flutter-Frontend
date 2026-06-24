import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/user_profile.dart';

class UserService {
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Map<String, String> _buildHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<UserProfile> getProfile() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/profile'),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      // Decode with UTF-8 to support accents and special chars
      return UserProfile.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  Future<UserProfile> updateProfile(String username, String? profilePicture) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final body = {
      'username': username,
      if (profilePicture != null) 'profilePicture': profilePicture,
    };

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/users/profile'),
      headers: _buildHeaders(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }
}
