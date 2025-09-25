import 'package:flutter/material.dart';
import 'task_item/task_item.dart';
import 'today_task_item.dart';
import '../../models/task_model.dart';
import '../../controllers/task_controller.dart';
import '../../themes/app_theme.dart';
import 'expansible_group.dart';
import '../../../../../widgets/common/cards/task_card.dart';

/// **CardFactory** - Fábrica de cards de tarefas
///
/// Classe responsável por criar o tipo correto de card baseado no estilo selecionado
class CardFactory {
  /// Constrói um card de tarefa baseado no estilo especificado
  static Widget buildCard({
    required TaskCardStyle style,
    required Task task,
    required TaskController controller,
    bool isSelected = false,
    TaskGroupType? groupType,
    VoidCallback? onTap,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    switch (style) {
      case TaskCardStyle.compact:
        return TodayTaskItem(
          task: task,
          controller: controller,
          groupType: groupType ?? TaskGroupType.today,
          isSelected: isSelected,
        );
      case TaskCardStyle.standard:
        return TaskItem(
          task: task,
          controller: controller,
          onToggleComplete: () => controller.toggleTaskCompletion(task.id),
          onToggleImportant: () => controller.toggleTaskImportant(task.id),
          onTap: onTap ?? (() => controller.selectTask(task.id)),
          onEdit: onEdit ?? (() {}), // Implementar conforme necessário
          onDelete: onDelete ?? (() {}), // Implementar conforme necessário
        );
      case TaskCardStyle.modular:
        final selectedList =
            controller.selectedListId != null
                ? controller.getListById(controller.selectedListId!)
                : null;
        final listColor = selectedList?.color ?? Colors.blue;

        return TaskCard(
          title: task.title,
          description: task.description.isNotEmpty ? task.description : null,
          listColor: listColor,
          isSelected: isSelected,
          onTap: onTap ?? (() => controller.selectTask(task.id)),
          // Configurações do pomodoro (usando tempo dinâmico da tarefa)
          pomodoroTargetSeconds: task.pomodoroTimeMinutes * 60, // Converter minutos para segundos
          onPomodoroComplete: () {
            debugPrint('Pomodoro completo para tarefa: ${task.title}');
          },
          onToggleCompletion: () => controller.toggleTaskCompletion(task.id),
          // 🆕 Dados para log interno do PomodoroTimerModule
          task: task,
          taskList: selectedList,
          shouldLog: true, // Sempre registrar log para tarefas
        );
    }
  }
}
