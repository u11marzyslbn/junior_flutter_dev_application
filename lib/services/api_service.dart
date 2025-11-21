import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException([this.statusCode, this.message = 'Api error']);
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
    try {
      final resp = await _client.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final j = jsonDecode(resp.body) as Map<String, dynamic>;
        return (j['works'] as List<dynamic>?) ?? [];
      } else if (resp.statusCode == 404) {
        throw ApiException(resp.statusCode, 'Subject not found: $subject');
      } else if (resp.statusCode >= 500) {
        throw ApiException(
          resp.statusCode,
          'Server error (${resp.statusCode})',
        );
      } else if (resp.statusCode == 401 || resp.statusCode == 403) {
        throw ApiException(resp.statusCode, 'Unauthorized access');
      }
      throw ApiException(
        resp.statusCode,
        'Unexpected response: ${resp.statusCode}',
      );
    } on TimeoutException catch (e) {
      throw ApiException(null, 'Request timed out: ${e.message ?? ''}');
    } on SocketException catch (e) {
      throw ApiException(null, 'Network error: ${e.message}');
    }
  }

  Future<List<dynamic>> search(String query, {int limit = 20}) async {
    final url = Uri.https('openlibrary.org', '/search.json', {
      'q': query,
      'limit': '$limit',
    });
    try {
      final resp = await _client.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final j = jsonDecode(resp.body) as Map<String, dynamic>;
        return (j['docs'] as List<dynamic>?) ?? [];
      }
      throw ApiException(resp.statusCode, 'Search failed: ${resp.statusCode}');
    } on TimeoutException catch (e) {
      throw ApiException(null, 'Search request timed out: ${e.message ?? ''}');
    } on SocketException catch (e) {
      throw ApiException(null, 'Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> fetchWorkDetail(String workId) async {
    final id = workId.startsWith('/works/') ? workId.split('/').last : workId;
    final url = Uri.parse('https://openlibrary.org/works/$id.json');
    try {
      final resp = await _client.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } else if (resp.statusCode == 404) {
        throw ApiException(resp.statusCode, 'Work not found: $workId');
      }
      throw ApiException(
        resp.statusCode,
        'Unexpected response: ${resp.statusCode}',
      );
    } on TimeoutException catch (e) {
      throw ApiException(
        null,
        'Work detail request timed out: ${e.message ?? ''}',
      );
    } on SocketException catch (e) {
      throw ApiException(null, 'Network error: ${e.message}');
    }
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
    try {
      final resp = await _client.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final j = jsonDecode(resp.body) as Map<String, dynamic>;
        return (j['name'] ?? '') as String;
      }
      return '';
    } on TimeoutException catch (_) {
      return '';
    } on SocketException catch (_) {
      return '';
    }
  }
}
