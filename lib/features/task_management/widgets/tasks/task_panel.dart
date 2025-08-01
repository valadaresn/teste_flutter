import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../themes/theme_provider.dart';
import '../../filters/task_filter.dart';
import '../../filters/basic_filters.dart';
import '../../models/task_model.dart';
import '../../models/list_model.dart' as Models;
import 'task_panel_header.dart';
import 'task_list.dart';

// Arquivo renomeado de task_area.dart para task_panel.dart para padronização com outros componentes do projeto.

/// **TaskPanel** - Área principal de tarefas
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
/// - Header unificado seguindo layout do TodayView
class TaskPanel extends StatelessWidget {
  final TaskController controller;
  final TaskFilter? filter; // Filtro opcional
  final VoidCallback? onToggleSidebar;

  const TaskPanel({
    Key? key,
    required this.controller,
    this.filter, // PARÂMETRO OPCIONAL
    this.onToggleSidebar,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          children: [
            // Header unificado seguindo layout do TodayView
            TaskPanelHeader(
              controller: controller,
              selectedList: _getSelectedListForHeader(),
              onToggleSidebar: onToggleSidebar,
            ),

            // Lista com filtro aplicado
            Expanded(
              child: Container(
                color: themeProvider.getBackgroundColor(
                  context,
                  listColor: _getListColorForBackground(),
                ),
                child: TaskList(
                  controller: controller,
                  tasks: _getFilteredTasks(), // 🆕 Lista filtrada
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 🔍 Aplicar filtro às tarefas
  List<Task> _getFilteredTasks() {
    if (filter != null) {
      return controller.tasks
          .where((task) => filter!.matches(task, controller))
          .toList();
    }
    return controller.tasks; // Comportamento atual se sem filtro
  }

  /// Obter lista selecionada baseada no filtro
  Models.TaskList? _getSelectedListForHeader() {
    if (filter is ListFilter) {
      final listFilter = filter as ListFilter;
      return controller.getListById(listFilter.listId);
    }
    return null; // AllTasksFilter ou TodayFilter não têm lista específica
  }

  /// Obter cor de fundo baseada no filtro
  Color? _getListColorForBackground() {
    if (filter is ListFilter) {
      final listFilter = filter as ListFilter;
      final list = controller.getListById(listFilter.listId);
      return list?.color;
    }
    return null; // AllTasksFilter ou TodayFilter não têm cor específica
  }
}
