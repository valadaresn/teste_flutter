class DiaryEntry {
  final String id;
  final String? title;
  final String content;
  final DateTime dateTime;
  final String? mood;
  final List<String> tags;

  DiaryEntry({
    required this.id,
    this.title,
    required this.content,
    required this.dateTime,
    this.mood,
    List<String>? tags,
  }) : tags = tags ?? [];

  DiaryEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? dateTime,
    String? mood,
    List<String>? tags,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      dateTime: dateTime ?? this.dateTime,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
    );
  }
}
