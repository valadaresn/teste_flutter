import 'package:flutter/material.dart';
import '../habit_model.dart';
import 'habit_edit_form.dart';

class HabitEditScreen extends StatelessWidget {
  final Habit? habit; // Null para novo hábito
  final Future<void> Function(Map<String, dynamic>)
  onSave; // ✅ Corrigido: Future<void>
  final List<String> emojiOptions;
  final List<Color> colorOptions;
  final List<String> dayNames;
  final List<String> dayLabels;

  const HabitEditScreen({
    Key? key,
    required this.habit,
    required this.onSave,
    required this.emojiOptions,
    required this.colorOptions,
    required this.dayNames,
    required this.dayLabels,
  }) : super(key: key);

  // Construtor nomeado para criação de novos hábitos
  factory HabitEditScreen.forNewHabit({
    required Future<void> Function(Map<String, dynamic>)
    onSave, // ✅ Corrigido: Future<void>
    required List<String> emojiOptions,
    required List<Color> colorOptions,
    required List<String> dayNames,
    required List<String> dayLabels,
  }) {
    return HabitEditScreen(
      habit: null,
      onSave: onSave,
      emojiOptions: emojiOptions,
      colorOptions: colorOptions,
      dayNames: dayNames,
      dayLabels: dayLabels,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(habit == null ? 'Criar Hábito' : 'Editar Hábito'),
        actions: [
          if (habit != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Implementar exclusão
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: HabitEditForm(
          habit: habit,
          emojiOptions: emojiOptions,
          colorOptions: colorOptions,
          dayNames: dayNames,
          dayLabels: dayLabels,
          onSave: onSave,
        ),
      ),
    );
  }
}
