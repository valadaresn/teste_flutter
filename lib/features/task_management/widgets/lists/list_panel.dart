import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/list_model.dart' as Models;
import 'list_form_dialog.dart';
import 'list_item.dart';

/// **ListPanel** - Painel de gerenciamento de listas de tarefas
///
/// Este componente é responsável por:
/// - Exibir o cabeçalho da seção de listas
/// - Mostrar a lista de listas do projeto selecionado ou todas as listas
/// - Permitir seleção de listas
/// - Fornecer botão para criar novas listas
/// - Exibir estado vazio quando não há listas
///
/// **Funcionalidades:**
/// - Filtragem automática por projeto selecionado
/// - Contador de tarefas pendentes por lista
/// - Estado vazio personalizado por contexto (projeto específico vs. geral)
/// - Integração com o TaskController para operações CRUD
class ListPanel extends StatelessWidget {
  final TaskController controller;

  const ListPanel({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtrar listas com base no projeto selecionado
    final filteredLists = _getFilteredLists();

    return Expanded(
      child: Column(
        children: [
          // Cabeçalho da seção de listas
          _buildListsHeader(context, filteredLists),

          // Lista de listas ou estado vazio
          Expanded(
            child:
                filteredLists.isEmpty
                    ? _buildEmptyListsState(context)
                    : _buildListsList(context, filteredLists),
          ),
        ],
      ),
    );
  }

  /// Filtra as listas baseado no projeto selecionado
  List<Models.TaskList> _getFilteredLists() {
    return controller.selectedProjectId == null
        ? controller
            .lists // Mostrar todas as listas quando "Todos os projetos" está selecionado
        : controller.lists
            .where((list) => list.projectId == controller.selectedProjectId)
            .toList();
  }

  /// Constrói o cabeçalho da seção de listas
  Widget _buildListsHeader(
    BuildContext context,
    List<Models.TaskList> filteredLists,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Título e contador
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Listas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // Mostrar contador apenas quando há filtro por projeto
              if (controller.selectedProjectId != null)
                Text(
                  '${filteredLists.length} de ${controller.lists.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),

          // Botão para nova lista
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => _showCreateListDialog(context),
            tooltip: 'Nova lista',
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a lista de listas
  Widget _buildListsList(BuildContext context, List<Models.TaskList> lists) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        final isSelected = controller.selectedListId == list.id;

        return ListItem(
          list: list,
          controller: controller,
          isSelected: isSelected,
          onTap: () => _selectList(list),
        );
      },
    );
  }

  /// Constrói o estado vazio das listas
  Widget _buildEmptyListsState(BuildContext context) {
    final selectedProject =
        controller.selectedProjectId != null
            ? controller.projects.firstWhere(
              (p) => p.id == controller.selectedProjectId,
            )
            : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone contextual
            Icon(
              selectedProject != null ? Icons.folder_open : Icons.list_alt,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),

            // Título contextual
            Text(
              selectedProject != null
                  ? 'Nenhuma lista em "${selectedProject.name}"'
                  : 'Nenhuma lista criada',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtítulo contextual
            Text(
              selectedProject != null
                  ? 'Crie uma nova lista para este projeto'
                  : 'Comece criando sua primeira lista',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Botão de ação
            ElevatedButton.icon(
              onPressed: () => _showCreateListDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Nova Lista'),
            ),
          ],
        ),
      ),
    );
  }

  /// Seleciona ou deseleciona uma lista
  void _selectList(Models.TaskList list) {
    final isCurrentlySelected = controller.selectedListId == list.id;
    controller.selectList(isCurrentlySelected ? null : list.id);
  }

  /// Exibe o diálogo para criar uma nova lista
  void _showCreateListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ListFormDialog(controller: controller),
    );
  }
}
