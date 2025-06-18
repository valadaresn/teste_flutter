import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String title;
  final String emoji;
  final bool hasQualityRating;
  final bool hasTimer;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<String> daysOfWeek;
  final int? targetTime;
  final Color color;
  final int streak;
  final int bestStreak;
  final DateTime? lastCompletedDate; // ✅ NOVO CAMPO

  const Habit({
    required this.id,
    required this.title,
    required this.emoji,
    this.hasQualityRating = false,
    this.hasTimer = false,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.daysOfWeek = const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
    this.targetTime,
    this.color = Colors.blue,
    this.streak = 0,
    this.bestStreak = 0,
    this.lastCompletedDate, // ✅ NOVO CAMPO
  });

  // ✅ NOVO MÉTODO: Verifica se foi feito hoje
  bool isDoneToday() {
    if (lastCompletedDate == null) return false;

    final today = DateTime.now();
    final lastCompleted = lastCompletedDate!;

    return lastCompleted.year == today.year &&
        lastCompleted.month == today.month &&
        lastCompleted.day == today.day;
  }

  factory Habit.fromFormData(Map<String, dynamic> formData, String id) {
    return Habit(
      id: id,
      title: formData['title'] ?? '',
      emoji: formData['emoji'] ?? '💪',
      hasQualityRating: formData['hasQualityRating'] ?? false,
      hasTimer: formData['hasTimer'] ?? false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: formData['isActive'] ?? true,
      daysOfWeek: List<String>.from(
        formData['daysOfWeek'] ??
            ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
      ),
      targetTime: formData['targetTime'],
      color: Color(formData['colorValue'] ?? Colors.blue.value),
      streak: 0,
      bestStreak: 0,
      lastCompletedDate: null, // ✅ NOVO CAMPO
    );
  }

  factory Habit.fromMap(Map<String, dynamic> map, String id) {
    return Habit(
      id: id,
      title: map['title'] ?? '',
      emoji: map['emoji'] ?? '💪',
      hasQualityRating: map['hasQualityRating'] ?? false,
      hasTimer: map['hasTimer'] ?? false,
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      daysOfWeek: List<String>.from(
        map['daysOfWeek'] ?? ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
      ),
      targetTime: map['targetTime'],
      color: Color(map['colorValue'] ?? Colors.blue.value),
      streak: map['streak'] ?? 0,
      bestStreak: map['bestStreak'] ?? 0,
      lastCompletedDate: _parseDateTime(
        map['lastCompletedDate'],
      ), // ✅ NOVO CAMPO
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  factory Habit.updateFromForm(Habit original, Map<String, dynamic> formData) {
    return Habit(
      id: original.id,
      title: formData['title'] ?? original.title,
      emoji: formData['emoji'] ?? original.emoji,
      hasQualityRating:
          formData['hasQualityRating'] ?? original.hasQualityRating,
      hasTimer: formData['hasTimer'] ?? original.hasTimer,
      createdAt: original.createdAt,
      updatedAt: DateTime.now(),
      isActive: formData['isActive'] ?? original.isActive,
      daysOfWeek: List<String>.from(
        formData['daysOfWeek'] ?? original.daysOfWeek,
      ),
      targetTime: formData['targetTime'] ?? original.targetTime,
      color:
          formData['colorValue'] != null
              ? Color(formData['colorValue'])
              : original.color,
      streak: original.streak,
      bestStreak: original.bestStreak,
      lastCompletedDate: original.lastCompletedDate, // ✅ PRESERVAR CAMPO
    );
  }

  Habit updateStreak(int newStreak) {
    return Habit(
      id: id,
      title: title,
      emoji: emoji,
      hasQualityRating: hasQualityRating,
      hasTimer: hasTimer,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive,
      daysOfWeek: daysOfWeek,
      targetTime: targetTime,
      color: color,
      streak: newStreak,
      bestStreak: newStreak > bestStreak ? newStreak : bestStreak,
      lastCompletedDate: lastCompletedDate, // ✅ PRESERVAR CAMPO
    );
  }

  // ✅ NOVO MÉTODO: Marcar como feito hoje
  Habit markAsDoneToday() {
    final today = DateTime.now();
    final newStreak = isDoneToday() ? streak : streak + 1;

    return Habit(
      id: id,
      title: title,
      emoji: emoji,
      hasQualityRating: hasQualityRating,
      hasTimer: hasTimer,
      createdAt: createdAt,
      updatedAt: today,
      isActive: isActive,
      daysOfWeek: daysOfWeek,
      targetTime: targetTime,
      color: color,
      streak: newStreak,
      bestStreak: newStreak > bestStreak ? newStreak : bestStreak,
      lastCompletedDate: today, // ✅ ATUALIZAR CAMPO
    );
  }

  // ✅ NOVO MÉTODO: Desmarcar como feito hoje
  Habit unmarkAsDoneToday() {
    if (!isDoneToday()) return this; // Se não foi feito hoje, não muda nada

    return Habit(
      id: id,
      title: title,
      emoji: emoji,
      hasQualityRating: hasQualityRating,
      hasTimer: hasTimer,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive,
      daysOfWeek: daysOfWeek,
      targetTime: targetTime,
      color: color,
      streak: streak > 0 ? streak - 1 : 0,
      bestStreak: bestStreak,
      lastCompletedDate: null, // ✅ LIMPAR CAMPO
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'emoji': emoji,
      'hasQualityRating': hasQualityRating,
      'hasTimer': hasTimer,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'daysOfWeek': daysOfWeek,
      'targetTime': targetTime,
      'colorValue': color.value,
      'streak': streak,
      'bestStreak': bestStreak,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(), // ✅ NOVO CAMPO
    };
  }

  bool shouldShowToday() {
    if (!isActive) return false;

    final today = DateTime.now();
    final dayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final todayName = dayNames[today.weekday - 1];

    return daysOfWeek.contains(todayName);
  }

  @override
  String toString() {
    return 'Habit(id: $id, title: $title, emoji: $emoji, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit &&
        other.id == id &&
        other.title == title &&
        other.emoji == emoji &&
        other.hasQualityRating == hasQualityRating &&
        other.hasTimer == hasTimer &&
        other.isActive == isActive &&
        other.targetTime == targetTime &&
        other.color.value == color.value &&
        other.streak == streak &&
        other.bestStreak == bestStreak &&
        other.updatedAt == updatedAt &&
        other.lastCompletedDate == lastCompletedDate; // ✅ INCLUIR NOVO CAMPO
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        emoji.hashCode ^
        hasQualityRating.hashCode ^
        hasTimer.hashCode ^
        isActive.hashCode ^
        targetTime.hashCode ^
        color.value.hashCode ^
        streak.hashCode ^
        bestStreak.hashCode ^
        updatedAt.hashCode ^
        lastCompletedDate.hashCode; // ✅ INCLUIR NOVO CAMPO
  }
}
