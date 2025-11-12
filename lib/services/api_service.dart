import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  final http.Client _client;
  ApiService([http.Client? client]) : _client = client ?? http.Client();

  Future<List<dynamic>> fetchSubject(String subject, {int limit = 20}) async {
    final url = Uri.parse(
      'https://openlibrary.org/subjects/$subject.json?limit=$limit',
    );
    final resp = await _client.get(url).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw ApiException(resp.statusCode, 'Failed to load subject');
    }
    final j = jsonDecode(resp.body) as Map<String, dynamic>;
    return (j['works'] as List<dynamic>?) ?? [];
  }

  Future<List<dynamic>> search(String query, {int limit = 20}) async {
    final url = Uri.https('openlibrary.org', '/search.json', {
      'q': query,
      'limit': '$limit',
    });
    final resp = await _client.get(url).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw ApiException(resp.statusCode, 'Search failed');
    }
    final j = jsonDecode(resp.body) as Map<String, dynamic>;
    return (j['docs'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> fetchWorkDetail(String workId) async {
    final id = workId.startsWith('/works/') ? workId.split('/').last : workId;
    final url = Uri.parse('https://openlibrary.org/works/$id.json');
    final resp = await _client.get(url).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw ApiException(resp.statusCode, 'Work not found: $workId');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<String> fetchAuthorName(String authorKey) async {
    if (authorKey.isEmpty) return '';
    String path;
    if (authorKey.startsWith('/')) {
      path = authorKey;
    } else if (authorKey.startsWith('authors/')) {
      path = '/$authorKey';
    } else {
      path = '/authors/$authorKey';
    }
    final url = Uri.parse('https://openlibrary.org$path.json');
    final resp = await _client.get(url).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw ApiException(resp.statusCode, 'Author not found for $authorKey');
    }
    final j = jsonDecode(resp.body) as Map<String, dynamic>;
    return (j['name'] ?? '') as String;
  }
}
