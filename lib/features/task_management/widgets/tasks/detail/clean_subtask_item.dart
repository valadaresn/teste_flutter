import 'package:flutter/material.dart';
import '../../../controllers/task_controller.dart';
import '../../../models/task_model.dart';
import '../../../../../widgets/common/cards/subtask_card.dart';
import 'subtask_edit_dialog.dart';

/// **CleanSubtaskItem** - Item de subtarefa para o CleanTaskPanel
///
/// Componente isolado refatorado para usar SubtaskCard modular.
/// Mantém compatibilidade de API, mas delega toda a lógica para SubtaskCard.
///
/// **ANTES:** ~400 linhas com lógica complexa
/// **DEPOIS:** ~50 linhas delegando para SubtaskCard
///
/// **BREAKING CHANGES:**
/// - textController não é mais usado (edição via dialog)
/// - onTitleChanged não é mais usado (edição via dialog)
class CleanSubtaskItem extends StatelessWidget {
  final Task subtask;
  final TaskController taskController;
  final TextEditingController textController; // ⚠️ Mantido para compatibilidade, mas não usado
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final Function(String) onTitleChanged; // ⚠️ Mantido para compatibilidade, mas não usado

  const CleanSubtaskItem({
    Key? key,
    required this.subtask,
    required this.taskController,
    required this.textController,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onTitleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🎯 Toda a lógica agora é delegada para SubtaskCard
    return SubtaskCard(
      subtask: subtask,
      controller: taskController,
      onToggleComplete: onToggleComplete,
      onEdit: () => _showEditDialog(context),
      onDelete: onDelete,
    );
  }

  /// 📝 Abrir dialog de edição da subtarefa
  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SubtaskEditDialog(
        subtask: subtask,
        controller: taskController,
      ),
    );
  }
}
