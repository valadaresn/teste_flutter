import 'package:flutter/foundation.dart';

class DiaryEntry {
  final String id;
  final String? title;
  final String content;
  final DateTime dateTime;
  final String mood;
  final List<String> tags;
  final bool isFavorite;

  const DiaryEntry({
    required this.id,
    this.title,
    required this.content,
    required this.dateTime,
    required this.mood,
    required this.tags,
    this.isFavorite = false,
  });

  /// Cria uma entrada a partir de dados de formulário
  factory DiaryEntry.fromFormData(Map<String, dynamic> formData, String id) {
    return DiaryEntry(
      id: id,
      title: formData['title']?.isEmpty ?? true ? null : formData['title'],
      content: formData['content'] ?? '',
      dateTime:
          formData['dateTime'] != null
              ? DateTime.parse(formData['dateTime'])
              : DateTime.now(),
      mood: formData['mood'] ?? '😊',
      tags: List<String>.from(formData['tags'] ?? []),
      isFavorite: formData['isFavorite'] ?? false,
    );
  }

  /// Cria uma entrada a partir de dados do Firestore
  factory DiaryEntry.fromMap(Map<String, dynamic> map, String id) {
    return DiaryEntry(
      id: id,
      title: map['title'],
      content: map['content'] ?? '',
      dateTime:
          map['dateTime'] is String
              ? DateTime.parse(map['dateTime'])
              : DateTime.now(),
      mood: map['mood'] ?? '😊',
      tags: List<String>.from(map['tags'] ?? []),
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  /// Atualiza uma entrada com dados do formulário
  /// Este substitui o método copyWith e updateWithFormData antigos
  factory DiaryEntry.updateFromForm(
    DiaryEntry original,
    Map<String, dynamic> formData,
  ) {
    return DiaryEntry(
      id: original.id,
      title: formData['title']?.isEmpty ?? true ? null : formData['title'],
      content: formData['content'] ?? original.content,
      dateTime: original.dateTime, // Mantém a data original
      mood: formData['mood'] ?? original.mood,
      tags: List<String>.from(formData['tags'] ?? original.tags),
      isFavorite: original.isFavorite, // Mantém status de favorito
    );
  }

  /// Converte para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'dateTime': dateTime.toIso8601String(),
      'mood': mood,
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }

  @override
  String toString() {
    return 'DiaryEntry(id: $id, title: $title, date: $dateTime, mood: $mood)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiaryEntry &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.dateTime == dateTime &&
        other.mood == mood &&
        listEquals(other.tags, tags) &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        content.hashCode ^
        dateTime.hashCode ^
        mood.hashCode ^
        tags.hashCode ^
        isFavorite.hashCode;
  }
}
