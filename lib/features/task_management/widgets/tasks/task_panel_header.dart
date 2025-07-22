import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/list_model.dart' as Models;

/// **TaskPanelHeader** - Cabeçalho da área de tarefas
///
/// Este componente é responsável por:
/// - Exibir informações da lista selecionada (nome, emoji, contador)
/// - Mostrar informações de "Todas as Tarefas" quando nenhuma lista está selecionada
/// - Fornecer botões de ação (busca, filtros)
/// - Aplicar estilo visual consistente
///
/// **Funcionalidades:**
/// - Exibição dinâmica baseada na lista selecionada
/// - Contadores de tarefas pendentes contextual
/// - Botões de ação integrados
/// - Design responsivo e acessível
class TaskPanelHeader extends StatelessWidget {
  final TaskController controller;
  final Models.TaskList? selectedList;
  final VoidCallback onShowSearch;
  final VoidCallback onShowFilter;
  final VoidCallback? onToggleSidebar;

  const TaskPanelHeader({
    Key? key,
    required this.controller,
    required this.selectedList,
    required this.onShowSearch,
    required this.onShowFilter,
    this.onToggleSidebar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
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

          // Informações da lista/contexto
          ..._buildContextInfo(context),

          // Espaçamento
          const SizedBox(width: 16),

          // Botões de ação
          ..._buildActionButtons(context),
        ],
      ),
    );
  }

  /// Constrói as informações contextuais (lista selecionada ou todas as tarefas)
  List<Widget> _buildContextInfo(BuildContext context) {
    if (selectedList != null) {
      // Exibir informações da lista selecionada
      final pendingCount = controller.countPendingTasksInList(selectedList!.id);

      return [
        // Emoji da lista
        Text(selectedList!.emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),

        // Informações da lista
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedList!.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getPendingTasksText(pendingCount),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ];
    } else {
      // Exibir informações de "Todas as Tarefas"
      final totalPendingCount =
          controller.tasks.where((t) => !t.isCompleted).length;

      return [
        // Ícone de inbox
        Icon(
          Icons.inbox,
          size: 28,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),

        // Informações gerais
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Todas as Tarefas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getPendingTasksText(totalPendingCount),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ];
    }
  }

  /// Constrói os botões de ação do cabeçalho
  List<Widget> _buildActionButtons(BuildContext context) {
    return [
      // Botão de busca
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: onShowSearch,
        tooltip: 'Buscar tarefas',
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      ),

      const SizedBox(width: 8),

      // Botão de filtros
      IconButton(
        icon: const Icon(Icons.filter_list),
        onPressed: onShowFilter,
        tooltip: 'Filtrar tarefas',
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ];
  }

  /// Gera o texto para contador de tarefas pendentes
  String _getPendingTasksText(int count) {
    if (count == 0) {
      return 'Nenhuma tarefa pendente';
    } else if (count == 1) {
      return '1 tarefa pendente';
    } else {
      return '$count tarefas pendentes';
    }
  }
}

// Arquivo renomeado de task_area_header.dart para task_panel_header.dart para padronização com outros componentes do projeto.
