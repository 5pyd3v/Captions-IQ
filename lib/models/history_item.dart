class HistoryItem {
  final String id;
  final DateTime createdAt;
  final String title;
  final int imageCount;
  final String rawText;
  final String summaryEn;
  final String summaryRomanUr;

  const HistoryItem({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.imageCount,
    required this.rawText,
    required this.summaryEn,
    required this.summaryRomanUr,
  });

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      title: (map['title'] as String?) ?? 'Untitled scan',
      imageCount: (map['image_count'] as num?)?.toInt() ?? 0,
      rawText: (map['raw_text'] as String?) ?? '',
      summaryEn: (map['summary_en'] as String?) ?? '',
      summaryRomanUr: (map['summary_roman_ur'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toInsertMap({required String userId}) {
    return {
      'user_id': userId,
      'title': title,
      'image_count': imageCount,
      'raw_text': rawText,
      'summary_en': summaryEn,
      'summary_roman_ur': summaryRomanUr,
    };
  }
}
