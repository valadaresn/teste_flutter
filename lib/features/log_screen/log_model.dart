import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum para filtros de período
enum LogFilterPeriod { today, yesterday, week, month, custom }

/// Enum para filtros de status
enum LogFilterStatus { all, active, completed }

class Log {
  final String id;

  // Identificação da entidade principal
  final String entityId; // ID da tarefa ou hábito
  final String entityType; // "task" ou "habit"
  final String entityTitle; // Nome da tarefa ou hábito

  // Hierarquia completa (para tasks)
  final String? listId; // ID da lista/matéria
  final String? listTitle; // Nome da lista/matéria (ex: "Matemática")
  final String? parentTaskId; // ID da tarefa pai (se for subtarefa)
  final String? parentTaskTitle; // Nome da tarefa pai

  // Campos de tempo e métricas
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final Map<String, dynamic> metrics;
  final List<String> tags;

  const Log({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.entityTitle,
    this.listId,
    this.listTitle,
    this.parentTaskId,
    this.parentTaskTitle,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    this.metrics = const {},
    this.tags = const [],
  });

  // Métodos para conversão Map/Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityId': entityId,
      'entityType': entityType,
      'entityTitle': entityTitle,
      'listId': listId,
      'listTitle': listTitle,
      'parentTaskId': parentTaskId,
      'parentTaskTitle': parentTaskTitle,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationMinutes': durationMinutes,
      'metrics': metrics,
      'tags': tags,
    };
  }

  factory Log.fromMap(Map<String, dynamic> map, String id) {
    return Log(
      id: id,
      entityId: map['entityId'] ?? '',
      entityType: map['entityType'] ?? '',
      entityTitle: map['entityTitle'] ?? '',
      listId: map['listId'],
      listTitle: map['listTitle'],
      parentTaskId: map['parentTaskId'],
      parentTaskTitle: map['parentTaskTitle'],
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime:
          map['endTime'] != null
              ? (map['endTime'] as Timestamp).toDate()
              : null,
      durationMinutes: map['durationMinutes'],
      metrics: Map<String, dynamic>.from(map['metrics'] ?? {}),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  // Factory para criar um novo log
  factory Log.create({
    required String entityId,
    required String entityType,
    required String entityTitle,
    String? listId,
    String? listTitle,
    String? parentTaskId,
    String? parentTaskTitle,
    DateTime? startTime,
    Map<String, dynamic>? metrics,
    List<String>? tags,
  }) {
    return Log(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      entityId: entityId,
      entityType: entityType,
      entityTitle: entityTitle,
      listId: listId,
      listTitle: listTitle,
      parentTaskId: parentTaskId,
      parentTaskTitle: parentTaskTitle,
      startTime: startTime ?? DateTime.now(),
      metrics: metrics ?? {},
      tags: tags ?? [],
    );
  }

  // Método para finalizar um log
  Log copyWith({
    String? id,
    String? entityId,
    String? entityType,
    String? entityTitle,
    String? listId,
    String? listTitle,
    String? parentTaskId,
    String? parentTaskTitle,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    Map<String, dynamic>? metrics,
    List<String>? tags,
  }) {
    return Log(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      entityTitle: entityTitle ?? this.entityTitle,
      listId: listId ?? this.listId,
      listTitle: listTitle ?? this.listTitle,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      parentTaskTitle: parentTaskTitle ?? this.parentTaskTitle,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      metrics: metrics ?? this.metrics,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'Log(id: $id, entityId: $entityId, entityType: $entityType, entityTitle: $entityTitle, startTime: $startTime, endTime: $endTime, durationMinutes: $durationMinutes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Log && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
