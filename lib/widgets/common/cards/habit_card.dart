import 'package:flutter/material.dart';
import 'modular_card.dart';
import '../../../features/habit_screen/habit_model.dart';
import '../../../utils/widget_mods.dart';
import '../modules/pomodoro_timer_module.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onToggleActive, // compatibilidade
    this.onToggleTodayCompletion, // compatibilidade com HabitList
    this.onResetStreak, // compatibilidade com HabitList
    this.onUndoResetStreak, // compatibilidade com HabitList
    this.isSelected = false,
  });

  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onToggleActive;
  final VoidCallback? onToggleTodayCompletion;
  final VoidCallback? onResetStreak;
  final VoidCallback? onUndoResetStreak;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ModularCard(
      onTap: onTap,
      backgroundColor: isSelected ? Colors.blue.shade50 : Colors.white,
      borderRadius: BorderRadius.circular(16),
      crossAxisAlignment: CrossAxisAlignment.center, // ✅ Centraliza verticalmente
      paddingVertical: 8, // ✅ Padding compacto para HabitCard
      paddingHorizontal: 16, // ✅ Padding horizontal padrão
      // 🎯 Emoji do hábito em container colorido
      leading: Text(
        habit.emoji,
        style: const TextStyle(fontSize: 24),
      ).center().container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              habit.isActive
                  ? habit.color.withOpacity(0.25)
                  : habit.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // 📋 Título próximo ao emoji (posição normal)
      title: Text(
        habit.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ), // Sem .center() - fica na posição normal após o leading
      
      // 🍅 Timer modular (substitui toda a lógica anterior)
      actions: habit.hasTimer && habit.targetTime != null
          ? PomodoroTimerModule(
              habit: habit,                      // ✅ Passa objeto Habit diretamente
              targetSeconds: habit.targetTime! * 60, // Converter minutos para segundos
              color: habit.color,
              shouldLog: true,                   // ✅ Habilita logging para hábitos
              onToggleCompletion: onToggleTodayCompletion,
              habitTitle: habit.title,           // 🔄 Compatibilidade legacy
            )
          : null,
    );
  }
}
