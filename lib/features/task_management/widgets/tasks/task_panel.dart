import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../themes/theme_provider.dart';
import 'task_panel_header.dart';
import 'task_list.dart';

// Arquivo renomeado de task_area.dart para task_panel.dart para padronização com outros componentes do projeto.

/// **TaskArea** - Área principal de tarefas
///
/// Este componente é responsável por:
/// - Exibir o cabeçalho da área de tarefas com informações da lista selecionada
/// - Mostrar a lista de tarefas filtrada
/// - Aplicar cor de fundo baseada na lista selecionada
/// - Fornecer contexto visual (lista específica vs. todas as tarefas)
///
/// **Funcionalidades:**
/// - Cabeçalho dinâmico baseado na lista selecionada
/// - Integração com TaskList para exibição das tarefas
/// - Aplicação de tema de cores da lista selecionada
/// - Botões de ação (busca, filtros) no cabeçalho
class TaskPanel extends StatelessWidget {
  final TaskController controller;
  final VoidCallback onShowSearch;
  final VoidCallback onShowFilter;
  final VoidCallback? onToggleSidebar;

  const TaskPanel({
    Key? key,
    required this.controller,
    required this.onShowSearch,
    required this.onShowFilter,
    this.onToggleSidebar,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final selectedList =
        controller.selectedListId != null
            ? controller.getListById(controller.selectedListId!)
            : null;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          children: [
            // Cabeçalho da área de tarefas
            TaskPanelHeader(
              controller: controller,
              selectedList: selectedList,
              onShowSearch: onShowSearch,
              onShowFilter: onShowFilter,
              onToggleSidebar: onToggleSidebar,
            ),

            // Área da lista - USAR o sistema de temas getBackgroundColor
            Expanded(
              child: Container(
                color: themeProvider.getBackgroundColor(
                  context,
                  listColor: selectedList?.color,
                ),
                child: TaskList(controller: controller),
              ),
            ),
          ],
        );
      },
    );
  }
}
