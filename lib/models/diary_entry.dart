import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DiaryEntry {
  final String id;
  final String? title;
  final String content;
  final DateTime dateTime;
  final String mood;
  final List<String> tags;
  final bool isFavorite;

  // Novos campos para relacionar com tarefas e projetos
  final String? taskId; // ID da tarefa relacionada
  final String? taskName; // Nome da tarefa relacionada
  final String? projectId; // ID do projeto relacionado
  final String? projectName; // Nome do projeto relacionado

  const DiaryEntry({
    required this.id,
    this.title,
    required this.content,
    required this.dateTime,
    required this.mood,
    required this.tags,
    this.isFavorite = false,
    this.taskId,
    this.taskName,
    this.projectId,
    this.projectName,
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
      taskId: formData['taskId'],
      taskName: formData['taskName'],
      projectId: formData['projectId'],
      projectName: formData['projectName'],
    );
  }

  /// Cria uma entrada a partir de dados do Firestore
  factory DiaryEntry.fromMap(Map<String, dynamic> map, String id) {
    // 🐛 DEBUG: Log para verificar conversão de DateTime
    debugPrint('🔍 DEBUG DiaryEntry.fromMap - ID: $id');
    debugPrint(
      '🔍 DEBUG DiaryEntry.fromMap - DateTime no map: ${map['dateTime']} (tipo: ${map['dateTime'].runtimeType})',
    );

    DateTime parsedDateTime;
    final dateTimeData = map['dateTime'];

    if (dateTimeData is String) {
      parsedDateTime = DateTime.parse(dateTimeData);
      debugPrint(
        '🔍 DEBUG DiaryEntry.fromMap - Parsed from String: $parsedDateTime',
      );
    } else if (dateTimeData != null) {
      // Pode ser Timestamp do Firebase
      try {
        if (dateTimeData.runtimeType.toString().contains('Timestamp')) {
          // É um Timestamp do Firebase
          parsedDateTime = dateTimeData.toDate();
          debugPrint(
            '🔍 DEBUG DiaryEntry.fromMap - Converted from Timestamp: $parsedDateTime',
          );
        } else {
          // Tentar converter para DateTime
          parsedDateTime = DateTime.fromMillisecondsSinceEpoch(dateTimeData);
          debugPrint(
            '🔍 DEBUG DiaryEntry.fromMap - Converted from milliseconds: $parsedDateTime',
          );
        }
      } catch (e) {
        debugPrint(
          '🔍 DEBUG DiaryEntry.fromMap - Erro na conversão, usando DateTime.now(): $e',
        );
        parsedDateTime = DateTime.now();
      }
    } else {
      parsedDateTime = DateTime.now();
      debugPrint(
        '🔍 DEBUG DiaryEntry.fromMap - dateTime era null, usando DateTime.now(): $parsedDateTime',
      );
    }

    return DiaryEntry(
      id: id,
      title: map['title'],
      content: map['content'] ?? '',
      dateTime: parsedDateTime,
      mood: map['mood'] ?? '😊',
      tags: List<String>.from(map['tags'] ?? []),
      isFavorite: map['isFavorite'] ?? false,
      taskId: map['taskId'],
      taskName: map['taskName'],
      projectId: map['projectId'],
      projectName: map['projectName'],
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
      dateTime:
          formData['dateTime'] != null
              ? DateTime.parse(formData['dateTime'])
              : original.dateTime, // Permite atualizar a data
      mood: formData['mood'] ?? original.mood,
      tags: List<String>.from(formData['tags'] ?? original.tags),
      isFavorite:
          formData['isFavorite'] ??
          original.isFavorite, // Agora atualiza corretamente
      taskId: formData['taskId'] ?? original.taskId,
      taskName: formData['taskName'] ?? original.taskName,
      projectId: formData['projectId'] ?? original.projectId,
      projectName: formData['projectName'] ?? original.projectName,
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
      'taskId': taskId,
      'taskName': taskName,
      'projectId': projectId,
      'projectName': projectName,
    };
  }

  @override
  String toString() {
    return 'DiaryEntry(id: $id, title: $title, date: $dateTime, mood: $mood, task: $taskName, project: $projectName)';
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
        other.isFavorite == isFavorite &&
        other.taskId == taskId &&
        other.taskName == taskName &&
        other.projectId == projectId &&
        other.projectName == projectName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        content.hashCode ^
        dateTime.hashCode ^
        mood.hashCode ^
        tags.hashCode ^
        isFavorite.hashCode ^
        taskId.hashCode ^
        taskName.hashCode ^
        projectId.hashCode ^
        projectName.hashCode;
  }

  /// Cria uma entrada de diário para uma tarefa específica
  factory DiaryEntry.forTask({
    required String id,
    required String content,
    required String mood,
    required String taskId,
    required String taskName,
    String? projectId,
    String? projectName,
    List<String> tags = const [],
  }) {
    return DiaryEntry(
      id: id,
      title: null, // Entradas de tarefa não têm título
      content: content,
      dateTime: DateTime.now(),
      mood: mood,
      tags: tags,
      isFavorite: false,
      taskId: taskId,
      taskName: taskName,
      projectId: projectId,
      projectName: projectName,
    );
  }

  /// Verifica se esta entrada está relacionada a uma tarefa
  bool get isRelatedToTask => taskId != null && taskId!.isNotEmpty;

  /// Verifica se esta entrada está relacionada a um projeto
  bool get isRelatedToProject => projectId != null && projectId!.isNotEmpty;
}
