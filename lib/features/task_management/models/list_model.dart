import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskList {
  final String id;
  final String name;
  final Color color;
  final String emoji;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;
  final int sortOrder;

  const TaskList({
    required this.id,
    required this.name,
    required this.color,
    required this.emoji,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
    this.sortOrder = 0,
  });

  // Factory para criar uma nova lista
  factory TaskList.create({
    required String id,
    required String name,
    required Color color,
    required String emoji,
    bool isDefault = false,
    int sortOrder = 0,
  }) {
    final now = DateTime.now();
    return TaskList(
      id: id,
      name: name,
      color: color,
      emoji: emoji,
      createdAt: now,
      updatedAt: now,
      isDefault: isDefault,
      sortOrder: sortOrder,
    );
  }

  // Factory para criar a partir de dados do formulário
  factory TaskList.fromFormData(Map<String, dynamic> formData, String id) {
    final now = DateTime.now();
    return TaskList(
      id: id,
      name: formData['name'] ?? '',
      color: formData['color'] ?? Colors.blue,
      emoji: formData['emoji'] ?? '📋',
      createdAt: now,
      updatedAt: now,
      isDefault: formData['isDefault'] ?? false,
      sortOrder: formData['sortOrder'] ?? 0,
    );
  }

  // Factory para criar a partir do Firestore
  factory TaskList.fromMap(Map<String, dynamic> map, String id) {
    return TaskList(
      id: id,
      name: map['name'] ?? '',
      color: _parseColor(map['color']),
      emoji: map['emoji'] ?? '📋',
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
      isDefault: map['isDefault'] ?? false,
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  // Converter para Map para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color.value,
      'emoji': emoji,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDefault': isDefault,
      'sortOrder': sortOrder,
    };
  }

  // Método para criar uma cópia com alterações
  TaskList copyWith({
    String? id,
    String? name,
    Color? color,
    String? emoji,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
    int? sortOrder,
  }) {
    return TaskList(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
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

  // Helper para converter Color
  static Color _parseColor(dynamic value) {
    if (value == null) return Colors.blue;
    if (value is int) return Color(value);
    if (value is String) {
      try {
        return Color(int.parse(value));
      } catch (e) {
        return Colors.blue;
      }
    }
    return Colors.blue;
  }

  // Implementação de equals e hashCode completos
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskList &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.emoji == emoji &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isDefault == isDefault &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      color,
      emoji,
      createdAt,
      updatedAt,
      isDefault,
      sortOrder,
    );
  }

  @override
  String toString() {
    return 'TaskList(id: $id, name: $name, emoji: $emoji, isDefault: $isDefault)';
  }
}
