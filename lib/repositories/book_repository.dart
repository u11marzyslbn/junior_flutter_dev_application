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
    return BookDetail.fromJson(raw);
  }
}
