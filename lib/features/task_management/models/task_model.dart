import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high, urgent }

class Task {
  final String id;
  final String title;
  final String description;
  final String listId;
  final String? parentTaskId; // Para subtarefas
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final List<String> tags;
  final int sortOrder;
  final bool isImportant; // Favorito/estrela
  final String? notes; // Notas adicionais

  const Task({
    required this.id,
    required this.title,
    required this.listId,
    this.description = '',
    this.parentTaskId,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.completedAt,
    this.tags = const [],
    this.sortOrder = 0,
    this.isImportant = false,
    this.notes,
  });

  // Factory para criar uma nova tarefa
  factory Task.create({
    required String id,
    required String title,
    required String listId,
    String description = '',
    String? parentTaskId,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    List<String> tags = const [],
    int sortOrder = 0,
    bool isImportant = false,
    String? notes,
  }) {
    final now = DateTime.now();
    return Task(
      id: id,
      title: title,
      listId: listId,
      description: description,
      parentTaskId: parentTaskId,
      priority: priority,
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
      tags: tags,
      sortOrder: sortOrder,
      isImportant: isImportant,
      notes: notes,
    );
  }

  // Factory para criar a partir de dados do formulário
  factory Task.fromFormData(Map<String, dynamic> formData, String id) {
    final now = DateTime.now();
    return Task(
      id: id,
      title: formData['title'] ?? '',
      listId: formData['listId'] ?? '',
      description: formData['description'] ?? '',
      parentTaskId: formData['parentTaskId'],
      priority: _parsePriority(formData['priority']),
      createdAt: now,
      updatedAt: now,
      dueDate: formData['dueDate'],
      tags: List<String>.from(formData['tags'] ?? []),
      sortOrder: formData['sortOrder'] ?? 0,
      isImportant: formData['isImportant'] ?? false,
      notes: formData['notes'],
    );
  }

  // Factory para criar a partir do Firestore
  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      listId: map['listId'] ?? '',
      description: map['description'] ?? '',
      parentTaskId: map['parentTaskId'],
      isCompleted: map['isCompleted'] ?? false,
      priority: _parsePriority(map['priority']),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
      dueDate: _parseDateTime(map['dueDate']),
      completedAt: _parseDateTime(map['completedAt']),
      tags: List<String>.from(map['tags'] ?? []),
      sortOrder: map['sortOrder'] ?? 0,
      isImportant: map['isImportant'] ?? false,
      notes: map['notes'],
    );
  }

  // Converter para Map para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'listId': listId,
      'description': description,
      'parentTaskId': parentTaskId,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'tags': tags,
      'sortOrder': sortOrder,
      'isImportant': isImportant,
      'notes': notes,
    };
  }

  // Método para criar uma cópia com alterações
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? listId,
    String? parentTaskId,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? completedAt,
    List<String>? tags,
    int? sortOrder,
    bool? isImportant,
    String? notes,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      listId: listId ?? this.listId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      sortOrder: sortOrder ?? this.sortOrder,
      isImportant: isImportant ?? this.isImportant,
      notes: notes ?? this.notes,
    );
  }

  // Métodos de conveniência
  bool get isSubtask => parentTaskId != null;
  bool get isMainTask => parentTaskId == null;
  bool get isOverdue =>
      dueDate != null && !isCompleted && DateTime.now().isAfter(dueDate!);
  bool get isDueToday {
    if (dueDate == null) return false;
    final today = DateTime.now();
    final due = dueDate!;
    return today.year == due.year &&
        today.month == due.month &&
        today.day == due.day;
  }

  // Marcar como completa/incompleta
  Task toggleCompleted() {
    return copyWith(
      isCompleted: !isCompleted,
      completedAt: !isCompleted ? DateTime.now() : null,
    );
  }

  // Helper para converter DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Helper para converter TaskPriority
  static TaskPriority _parsePriority(dynamic value) {
    if (value == null) return TaskPriority.medium;
    if (value is String) {
      switch (value) {
        case 'low':
          return TaskPriority.low;
        case 'medium':
          return TaskPriority.medium;
        case 'high':
          return TaskPriority.high;
        case 'urgent':
          return TaskPriority.urgent;
        default:
          return TaskPriority.medium;
      }
    }
    return TaskPriority.medium;
  }

  // Métodos para UI
  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.low:
        return 'Baixa';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.urgent:
        return 'Urgente';
    }
  }

  // Implementação de equals e hashCode completos
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.listId == listId &&
        other.parentTaskId == parentTaskId &&
        other.isCompleted == isCompleted &&
        other.priority == priority &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.dueDate == dueDate &&
        other.completedAt == completedAt &&
        other.sortOrder == sortOrder &&
        other.isImportant == isImportant &&
        other.notes == notes &&
        _listEquals(other.tags, tags);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      listId,
      parentTaskId,
      isCompleted,
      priority,
      createdAt,
      updatedAt,
      dueDate,
      completedAt,
      sortOrder,
      isImportant,
      notes,
      Object.hashAll(tags),
    );
  }

  // Helper para comparar listas
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, listId: $listId, parentTaskId: $parentTaskId, isCompleted: $isCompleted)';
  }
}
