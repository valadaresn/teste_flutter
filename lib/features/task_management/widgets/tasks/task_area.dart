import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import 'task_area_header.dart';
import 'task_list.dart';

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
class TaskArea extends StatelessWidget {
  final TaskController controller;
  final VoidCallback onShowSearch;
  final VoidCallback onShowFilter;

  const TaskArea({
    Key? key,
    required this.controller,
    required this.onShowSearch,
    required this.onShowFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedList =
        controller.selectedListId != null
            ? controller.getListById(controller.selectedListId!)
            : null;

    return Column(
      children: [
        // Cabeçalho da área de tarefas
        TaskAreaHeader(
          controller: controller,
          selectedList: selectedList,
          onShowSearch: onShowSearch,
          onShowFilter: onShowFilter,
        ),

        // Área da lista com fundo colorido baseado na lista selecionada
        Expanded(
          child: Container(
            color:
                selectedList?.color ?? Theme.of(context).colorScheme.background,
            child: TaskList(controller: controller),
          ),
        ),
      ],
    );
  }
}
