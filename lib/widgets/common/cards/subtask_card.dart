import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/task_management/models/task_model.dart';
import '../../../features/task_management/controllers/task_controller.dart';
import '../../../features/log_screen/controllers/log_controller.dart';
import '../modules/pomodoro_timer_module.dart';
import '../modules/context_menu_module.dart';
import 'modular_card.dart';

/// 🧩 **SubtaskCard** - Card de subtarefa modular e reutilizável
///
/// **FILOSOFIA:** Usar ModularCard como base + módulos plugáveis
/// **INSPIRAÇÃO:** TaskCard (simplicidade) + NoteCard (modularidade)
///
/// **ARQUITETURA:**
/// - ModularCard como base (layout estruturado)
/// - Checkbox circular inline (não é módulo)
/// - PomodoroTimerModule para timer
/// - ContextMenuModule para menu edit/delete
///
/// **VISUAL:**
/// - Checkbox circular (24x24, verde quando completo)
/// - Título com lineThrough se completo
/// - Tempo acumulado (condicional, só se > 0)
/// - Botão timer play/stop
/// - Menu de contexto (clique direito/toque longo)
/// - SEM bordas, SEM sombras, background transparente
///
/// **EXEMPLO DE USO:**
/// ```dart
/// SubtaskCard(
///   subtask: mySubtask,
///   controller: taskController,
///   onToggleComplete: () => controller.toggleTask(subtask.id),
///   onEdit: () => _showEditDialog(),
///   onDelete: () => _confirmDelete(),
/// )
/// ```
class SubtaskCard extends StatelessWidget {
  final Task subtask;
  final TaskController controller;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SubtaskCard({
    super.key,
    required this.subtask,
    required this.controller,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LogController>(
      builder: (context, logController, child) {
        // Buscar subtask atualizada para ter tempo mais recente
        final updatedSubtask = controller.getTaskById(subtask.id) ?? subtask;

        // Calcular tempo total acumulado
        final totalAccumulatedSeconds = logController.getTotalAccumulatedTimeSync(
          subtask.id,
          updatedSubtask.accumulatedTimeSeconds,
        );

        return ContextMenuModule.editDelete(
          onEdit: onEdit ?? () {},
          onDelete: onDelete ?? () {},
          child: ModularCard(
            backgroundColor: Colors.transparent,
            elevation: 0,
            borderRadius: BorderRadius.zero,
            margin: const EdgeInsets.only(bottom: 8),
            paddingVertical: 4,
            paddingHorizontal: 8,
            crossAxisAlignment: CrossAxisAlignment.center,

            // Checkbox circular inline
            leading: _buildCheckbox(context),

            // Título da subtarefa
            title: Text(
              subtask.title,
              style: TextStyle(
                fontSize: 15,
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: subtask.isCompleted
                    ? Colors.grey.shade500
                    : Colors.black87,
              ),
            ),

            // Tempo acumulado (condicional)
            content: totalAccumulatedSeconds > 0
                ? _buildTimeDisplay(context, logController, totalAccumulatedSeconds)
                : null,

            // Botão timer play/stop
            actions: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tempo acumulado ou pomodoro
                if (totalAccumulatedSeconds > 0 ||
                    logController.isPomodoroRunning(subtask.id))
                  _buildTimeDisplay(
                    context,
                    logController,
                    totalAccumulatedSeconds,
                  ),

                const SizedBox(width: 8),

                // Timer play/stop
                PomodoroTimerModule(
                  task: updatedSubtask,
                  listTitle: controller.getListById(updatedSubtask.listId)?.name,
                  targetSeconds: updatedSubtask.pomodoroTimeMinutes * 60,
                  color: Theme.of(context).colorScheme.primary,
                  shouldLog: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🎯 Checkbox circular
  Widget _buildCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: onToggleComplete,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: subtask.isCompleted
                ? Colors.green
                : Colors.grey.shade400,
            width: 2,
          ),
          color: subtask.isCompleted
              ? Colors.green
              : Colors.transparent,
        ),
        child: subtask.isCompleted
            ? const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  /// ⏱️ Display de tempo acumulado ou countdown do pomodoro
  Widget _buildTimeDisplay(
    BuildContext context,
    LogController logController,
    int totalAccumulatedSeconds,
  ) {
    final isBeingLogged = logController.isTaskBeingLogged(subtask.id);
    final isPomodoroRunning = logController.isPomodoroRunning(subtask.id);

    // Determinar qual tempo mostrar
    String timeText;
    IconData timeIcon;

    if (isPomodoroRunning) {
      // Countdown do pomodoro
      final remainingTime = logController.getPomodoroRemainingTime(subtask.id);
      if (remainingTime != null && remainingTime > 0) {
        final minutes = (remainingTime ~/ 60).toString().padLeft(2, '0');
        final seconds = (remainingTime % 60).toString().padLeft(2, '0');
        timeText = '$minutes:$seconds';
        timeIcon = Icons.hourglass_bottom;
      } else {
        timeText = _formatTime(totalAccumulatedSeconds);
        timeIcon = Icons.timer;
      }
    } else {
      // Tempo acumulado
      timeText = _formatTime(totalAccumulatedSeconds);
      timeIcon = isBeingLogged ? Icons.timer : Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isBeingLogged
            ? Colors.green.shade50
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBeingLogged
              ? Colors.green.shade200
              : Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            timeIcon,
            size: 12,
            color: isBeingLogged
                ? Colors.green.shade600
                : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            timeText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isBeingLogged
                  ? Colors.green.shade700
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// 🕐 Formata tempo em HH:MM:SS ou MM:SS
  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
}
