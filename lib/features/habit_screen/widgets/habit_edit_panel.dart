import 'package:flutter/material.dart';
import '../habit_model.dart';
import 'habit_edit_form.dart';

class HabitEditPanel extends StatelessWidget {
  final Habit? habit; // Null para novo hábito
  final Future<void> Function(Map<String, dynamic>)
  onSave; // ✅ Corrigido: Future<void>
  final VoidCallback onClose;
  final List<String> emojiOptions;
  final List<Color> colorOptions;
  final List<String> dayNames;
  final List<String> dayLabels;

  const HabitEditPanel({
    Key? key,
    required this.habit,
    required this.onSave,
    required this.onClose,
    required this.emojiOptions,
    required this.colorOptions,
    required this.dayNames,
    required this.dayLabels,
  }) : super(key: key);

  // Construtor nomeado para criação de novos hábitos
  factory HabitEditPanel.forNewHabit({
    required Future<void> Function(Map<String, dynamic>)
    onSave, // ✅ Corrigido: Future<void>
    required VoidCallback onClose,
    required List<String> emojiOptions,
    required List<Color> colorOptions,
    required List<String> dayNames,
    required List<String> dayLabels,
  }) {
    return HabitEditPanel(
      habit: null,
      onSave: onSave,
      onClose: onClose,
      emojiOptions: emojiOptions,
      colorOptions: colorOptions,
      dayNames: dayNames,
      dayLabels: dayLabels,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                habit == null ? 'Novo Hábito' : 'Editar Hábito',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: HabitEditForm(
                habit: habit,
                emojiOptions: emojiOptions,
                colorOptions: colorOptions,
                dayNames: dayNames,
                dayLabels: dayLabels,
                onSave: onSave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
