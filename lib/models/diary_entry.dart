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
}
