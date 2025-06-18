import 'package:flutter/material.dart';
import '../../../components/generic_selector_list.dart';
import '../habit_controller.dart';
import '../habit_model.dart';
import 'habit_card.dart';

class HabitList extends StatelessWidget {
  final HabitController controller;
  final Function(Habit) onHabitTap;
  final String? selectedHabitId; // ID do hábito selecionado

  const HabitList({
    Key? key,
    required this.controller,
    required this.onHabitTap,
    this.selectedHabitId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenericSelectorList<HabitController, Habit>(
      listSelector: (ctrl) => ctrl.habits,
      // Fix 1: Return a valid Habit or throw an exception instead of null
      itemById:
          (ctrl, id) => ctrl.habits.firstWhere(
            (habit) => habit.id == id,
            orElse: () => throw Exception('Habit not found'),
          ),
      idExtractor: (habit) => habit.id,
      itemBuilder: (context, habit) {
        final isSelected = habit.id == selectedHabitId;

        return HabitCard(
          habit: habit,
          onTap: () => onHabitTap(habit),
          // Fix 2: Use correct method names from HabitController
          onToggleActive: () => controller.toggleActive(habit.id),
          onToggleTodayCompletion:
              () => controller.toggleTodayCompletion(habit.id),
          onResetStreak: () => controller.resetStreak(habit.id),
          // Fix 3: For now, reuse resetStreak but we can implement a proper undo later
          onUndoResetStreak: () => controller.incrementStreak(habit.id),
          isSelected: isSelected,
        );
      },
    );
  }
}
