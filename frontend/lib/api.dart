import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiClient {
  final String baseUrl;
  ApiClient({this.baseUrl = 'https://osint-scout-00ac27c2.fastapicloud.dev'});

  Future<bool> health() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 4));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<SearchResponse> search(String query, {int maxResults = 10, bool analyze = true}) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/search'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query, 'max_results': maxResults, 'analyze': analyze}),
    ).timeout(const Duration(seconds: 60));
    
    if (r.statusCode != 200) throw Exception('Search failed (${r.statusCode})');
    return SearchResponse.fromJson(jsonDecode(r.body));
  }

  Future<SearchResponse> searchImage(File imageFile) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/search-image'));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) throw Exception('Image search failed (${response.statusCode})');
    return SearchResponse.fromJson(jsonDecode(response.body));
  }
}
