import '../models/book.dart';
import '../models/book_detail.dart';
import '../services/api_service.dart';

class BookRepository {
  final ApiService api;
  BookRepository({required this.api});

  Future<List<Book>> fetchSubjectBooks({
    String subject = 'fiction',
    int limit = 20,
  }) async {
    final raw = await api.fetchSubject(subject, limit: limit);
    return raw
        .map((e) => Book.fromSubjectJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Book>> searchBooks(String query, {int limit = 20}) async {
    final raw = await api.search(query, limit: limit);
    return raw
        .map((e) => Book.fromSearchJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BookDetail> fetchBookDetail(String workId) async {
    final raw = await api.fetchWorkDetail(workId);

    final authorsRaw = raw['authors'] as List<dynamic>?;
    final List<String> authorKeys = [];
    if (authorsRaw != null) {
      for (final a in authorsRaw) {
        if (a is Map) {
          final candidate =
              (a['author'] is Map ? (a['author']['key'] ?? '') : a['key'] ?? '')
                  as String;
          if (candidate.isNotEmpty) authorKeys.add(candidate);
        } else if (a is String) {
          authorKeys.add(a);
        }
      }
    }

    final List<String> authorNames = [];
    for (final k in authorKeys) {
      try {
        final cleaned =
            k.startsWith('/') ? k : (k.startsWith('authors/') ? '/$k' : k);
        final name = await api.fetchAuthorName(cleaned);
        if (name.isNotEmpty) {
          authorNames.add(name);
        } else {
          authorNames.add(k);
        }
      } catch (_) {
        authorNames.add(k);
      }
    }

    final detail = BookDetail.fromJson(raw);
    return detail.copyWith(
      authors: authorNames.isNotEmpty ? authorNames : detail.authors,
    );
  }
}
