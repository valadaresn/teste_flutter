import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/list_model.dart' as Models;
import '../input/mobile_quick_add_task_input.dart';

/// **TaskPanelHeader** - Header unificado para TaskPanel
///
/// Segue exatamente o mesmo layout limpo do header do TodayView:
/// - Padding específico (horizontal: 8.0, vertical: 4.0)
/// - Icon/Emoji + Text com estilo específico
/// - Material + InkWell + Container para botão FAB
class TaskPanelHeader extends StatelessWidget {
  final TaskController controller;
  final Models.TaskList? selectedList;
  final VoidCallback? onToggleSidebar;
  final String? titleOverride; // Para permitir "Hoje" específico
  final IconData? iconOverride; // Para contextos especiais como "Hoje"

  const TaskPanelHeader({
    Key? key,
    required this.controller,
    required this.selectedList,
    this.onToggleSidebar,
    this.titleOverride,
    this.iconOverride,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // Mantém critério mobile original

    // Determinar título baseado na lista selecionada ou override
    final String title;

    if (titleOverride != null) {
      title = titleOverride!;
    } else if (selectedList != null) {
      title = selectedList!.name;
    } else {
      title = 'Todas as Tarefas';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          // Botão hambúrguer para recolher/expandir sidebar (opcional)
          if (onToggleSidebar != null)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onToggleSidebar,
              tooltip: 'Recolher/Expandir painel lateral',
            ),
          if (onToggleSidebar != null) const SizedBox(width: 8),

          // Ícone ou emoji baseado no contexto
          if (iconOverride != null)
            // Usar ícone específico (como para "Hoje")
            Icon(
              iconOverride!,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            )
          else if (selectedList != null)
            // Mostrar emoji da lista
            Text(selectedList!.emoji, style: const TextStyle(fontSize: 20))
          else
            // Ícone padrão para "Todas as Tarefas"
            Icon(
              Icons.inbox_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),

          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          // FAB para adicionar tarefa - APENAS NO MOBILE
          if (isMobile)
            Material(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => _showMobileAddTask(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Mostrar modal de adicionar tarefa no mobile
  void _showMobileAddTask(BuildContext context) {
    debugPrint('🚀 Tentando abrir modal mobile add task');
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          debugPrint('🚀 Builder do modal sendo executado');
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: MobileQuickAddTaskInput(controller: controller),
          );
        },
      );
    } catch (e) {
      debugPrint('🚨 Erro ao abrir modal: $e');
    }
  }
}
