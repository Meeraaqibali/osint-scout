import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiClient {
  final String baseUrl;
  ApiClient({this.baseUrl = 'http://127.0.0.1:8001'});

  Future<bool> health() async {
    try {
      final r = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 4));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<SearchResponse> search(
    String query, {
    int maxResults = 10,
    bool analyze = true,
  }) async {
    final r = await http
        .post(
          Uri.parse('$baseUrl/api/search'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'query': query,
            'max_results': maxResults,
            'analyze': analyze,
          }),
        )
        .timeout(const Duration(seconds: 60));
    if (r.statusCode != 200) {
      throw Exception('Search failed (${r.statusCode})');
    }
    return SearchResponse.fromJson(jsonDecode(r.body));
  }

  Future<Analysis> analyzeText(String text) async {
    final r = await http
        .post(
          Uri.parse('$baseUrl/api/analyze'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'text': text}),
        )
        .timeout(const Duration(seconds: 60));
    if (r.statusCode != 200) {
      throw Exception('Analysis failed (${r.statusCode})');
    }
    return Analysis.fromJson(jsonDecode(r.body));
  }
}
