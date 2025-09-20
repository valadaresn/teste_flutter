import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Tag {
  final String id;
  final String name;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tag({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory para criar nova tag
  factory Tag.create({required String name, required Color color, String? id}) {
    final now = DateTime.now();
    return Tag(
      id: id ?? '',
      name: name,
      colorValue: color.value,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Converte Map para Tag (para Firestore)
  factory Tag.fromMap(Map<String, dynamic> map, String id) {
    return Tag(
      id: id,
      name: map['name'] ?? '',
      colorValue: map['colorValue'] ?? Colors.blue.value,
      createdAt:
          map['createdAt'] is String
              ? DateTime.parse(map['createdAt'])
              : (map['createdAt'] is Timestamp
                  ? (map['createdAt'] as Timestamp).toDate()
                  : DateTime.now()),
      updatedAt:
          map['updatedAt'] is String
              ? DateTime.parse(map['updatedAt'])
              : (map['updatedAt'] is Timestamp
                  ? (map['updatedAt'] as Timestamp).toDate()
                  : DateTime.now()),
    );
  }

  // Converte Tag para Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Método copyWith para criar cópias modificadas
  Tag copyWith({
    String? id,
    String? name,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getter para obter a cor como objeto Color
  Color get color => Color(colorValue);

  // Método para atualizar o timestamp
  Tag updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // Método para atualizar o nome
  Tag updateName(String newName) {
    return copyWith(name: newName, updatedAt: DateTime.now());
  }

  // Método para atualizar a cor
  Tag updateColor(Color newColor) {
    return copyWith(colorValue: newColor.value, updatedAt: DateTime.now());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          colorValue == other.colorValue;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ colorValue.hashCode;

  @override
  String toString() {
    return 'Tag(id: $id, name: $name, colorValue: $colorValue, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
