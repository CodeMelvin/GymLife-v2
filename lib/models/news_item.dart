class NewsItem {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime date;

  const NewsItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.date,
  });

  factory NewsItem.fromRTDB(String key, Map<dynamic, dynamic> data) {
    return NewsItem(
      id: key,
      title: data['title']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      category: data['category']?.toString() ?? 'Info Umum',
      date: DateTime.tryParse(data['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
