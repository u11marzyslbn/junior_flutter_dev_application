class Book {
  final String workKey;
  final String title;
  final List<String> authors;
  final int? coverId;
  final int? firstPublishYear;

  Book({
    required this.workKey,
    required this.title,
    required this.authors,
    this.coverId,
    this.firstPublishYear,
  });

  String get workId =>
      workKey.startsWith('/works/') ? workKey.split('/').last : workKey;

  factory Book.fromSubjectJson(Map<String, dynamic> json) {
    return Book(
      workKey: (json['key'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      authors:
          (json['authors'] as List<dynamic>?)
              ?.map((a) => (a['name'] ?? '').toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      coverId: json['cover_id'] is int ? json['cover_id'] as int : null,
      firstPublishYear:
          json['first_publish_year'] is int
              ? json['first_publish_year'] as int
              : null,
    );
  }

  factory Book.fromSearchJson(Map<String, dynamic> json) {
    return Book(
      workKey:
          (json['key'] ??
                  (json['cover_edition_key'] != null
                      ? '/works/${json['cover_edition_key']}'
                      : ''))
              as String,
      title: (json['title'] ?? '') as String,
      authors:
          (json['author_name'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      coverId: json['cover_i'] is int ? json['cover_i'] as int : null,
      firstPublishYear:
          json['first_publish_year'] is int
              ? json['first_publish_year'] as int
              : null,
    );
  }

  String get coverUrl {
    if (coverId != null) {
      return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    }
    return '';
  }
}
