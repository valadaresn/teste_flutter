import 'package:flutter/material.dart';

@immutable
class DiaryEntry {
  final String id;
  final String? title;
  final String content;
  final DateTime dateTime;
  final String? mood;
  final List<String> tags;
  final bool isFavorite;

  const DiaryEntry({
    required this.id,
    this.title,
    required this.content,
    required this.dateTime,
    this.mood,
    this.tags = const [],
    this.isFavorite = false,
  });

  DiaryEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? dateTime,
    String? mood,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      dateTime: dateTime ?? this.dateTime,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // NOVO: Método para converter para Map para Firebase (não usado pelo repositório, mas útil para debug)
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

  // NOVO: Método para criar DiaryEntry a partir de Map (não usado pelo repositório, mas útil para debug)
  factory DiaryEntry.fromMap(Map<String, dynamic> map, String id) {
    return DiaryEntry(
      id: id,
      title: map['title'],
      content: map['content'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      mood: map['mood'],
      tags: List<String>.from(map['tags'] ?? []),
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
