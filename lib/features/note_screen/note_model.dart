import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime dateTime;
  final List<String> tags;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.dateTime,
    this.tags = const [],
  });

  // Factory para criar nova nota a partir de dados do dialog
  factory Note.fromDialogData(Map<String, dynamic> data, String id) {
    return Note(
      id: id,
      title: data['title']?.toString().trim() ?? '',
      content: data['content']?.toString().trim() ?? '',
      dateTime: DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  // Factory para atualizar nota existente com dados do dialog
  factory Note.updateFromDialog(Note existingNote, Map<String, dynamic> data) {
    return Note(
      id: existingNote.id,
      title: data['title']?.toString().trim() ?? existingNote.title,
      content: data['content']?.toString().trim() ?? existingNote.content,
      dateTime: existingNote.dateTime, // Mantém data original
      tags: List<String>.from(data['tags'] ?? existingNote.tags),
    );
  }

  // Converte Map para Note (para Firestore)
  factory Note.fromMap(Map<String, dynamic> map, String id) {
    return Note(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      dateTime:
          map['dateTime'] is String
              ? DateTime.parse(map['dateTime'])
              : (map['dateTime'] is Timestamp
                  ? (map['dateTime'] as Timestamp).toDate()
                  : DateTime.now()),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  // Converte Note para Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'dateTime': dateTime.toIso8601String(),
      'tags': tags,
    };
  }
}
