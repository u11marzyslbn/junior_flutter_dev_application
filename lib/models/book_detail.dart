class BookDetail {
  final String title;
  final List<String> authors;
  final String? description;
  final int? pages;
  final List<String>? subjects;
  final int? coverId;
  final int? firstPublishYear;

  BookDetail({
    required this.title,
    required this.authors,
    this.description,
    this.pages,
    this.subjects,
    this.coverId,
    this.firstPublishYear,
  });

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    String? desc;
    if (json['description'] is String) {
      desc = json['description'] as String;
    } else if (json['description'] is Map) {
      desc = (json['description']['value'] ?? '') as String;
    }
    final authors =
        (json['authors'] as List<dynamic>?)
            ?.map(
              (a) => (a is Map ? (a['author']?['key'] ?? '') : '') as String,
            )
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    return BookDetail(
      title: (json['title'] ?? '') as String,
      authors: authors,
      description: desc,
      pages:
          json['number_of_pages'] is int
              ? json['number_of_pages'] as int
              : null,
      subjects:
          (json['subjects'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList(),
      coverId:
          json['covers'] is List && (json['covers'] as List).isNotEmpty
              ? (json['covers'][0] as int)
              : null,
      firstPublishYear:
          json['first_publish_year'] is int
              ? json['first_publish_year'] as int
              : null,
    );
  }

  String get coverUrl {
    if (coverId != null) {
      return 'https://covers.openlibrary.org/b/id/$coverId-L.jpg';
    }
    return '';
  }
}
