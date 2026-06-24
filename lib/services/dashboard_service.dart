import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/dashboard_models.dart';

class DashboardService {
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

  String _buildUrl(String path, {Map<String, String>? queryParams}) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams).toString();
    }
    return uri.toString();
  }

  Future<KpiMetrics> getKpis({Map<String, String>? filters}) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(_buildUrl('/dashboard/kpis', queryParams: filters)),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      return KpiMetrics.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load KPIs');
    }
  }

  Future<List<SentimentDistribution>> getSentimentDistribution({Map<String, String>? filters}) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(_buildUrl('/dashboard/sentiment-distribution', queryParams: filters)),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => SentimentDistribution.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Sentiment Distribution');
    }
  }

  Future<List<ToxicPublication>> getToxicPublications({Map<String, String>? filters}) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(_buildUrl('/dashboard/toxic-publications', queryParams: filters)),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => ToxicPublication.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Toxic Publications');
    }
  }

  Future<List<SentimentEvolution>> getSentimentEvolution({Map<String, String>? filters}) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(_buildUrl('/dashboard/sentiment-evolution', queryParams: filters)),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => SentimentEvolution.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Sentiment Evolution');
    }
  }

  Future<List<SpamVolume>> getSpamVolume({Map<String, String>? filters}) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(_buildUrl('/dashboard/spam-volume', queryParams: filters)),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => SpamVolume.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Spam Volume');
    }
  }

  Future<double> getModelConfidence() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(_buildUrl('/dashboard/model-confidence')),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      return double.tryParse(response.body) ?? 0.0;
    } else {
      throw Exception('Failed to load Model Confidence');
    }
  }

  Future<WorkerStatus> getWorkerStatus() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(_buildUrl('/dashboard/worker-status')),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      return WorkerStatus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Worker Status');
    }
  }

  Future<Map<String, dynamic>> getReviewInbox(int page, int size) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(_buildUrl('/dashboard/review-inbox', queryParams: {
        'page': page.toString(),
        'size': size.toString(),
      })),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List content = data['content'] ?? [];
      return {
        'items': content.map((e) => ReviewInboxItem.fromJson(e)).toList(),
        'totalPages': data['totalPages'] ?? 0,
        'totalElements': data['totalElements'] ?? 0,
        'last': data['last'] ?? true,
      };
    } else {
      throw Exception('Failed to load Review Inbox');
    }
  }
}
