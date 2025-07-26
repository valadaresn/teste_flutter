import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';

/// Seletor de lista simplificado para QuickAddTaskInput
class QuickListSelector extends StatelessWidget {
  final String? selectedListId;
  final TaskController controller;
  final Function(String) onListChanged;

  const QuickListSelector({
    Key? key,
    required this.selectedListId,
    required this.controller,
    required this.onListChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedList =
        selectedListId != null ? controller.getListById(selectedListId!) : null;

    return GestureDetector(
      onTap: () => _showListSelector(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.list_outlined, size: 16, color: Colors.grey.shade500),
            if (selectedList != null) ...[
              const SizedBox(width: 6),
              Text(
                selectedList.name,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showListSelector(BuildContext context) {
    // Buscar projetos com suas listas agrupadas
    final projectsWithLists = controller.getProjectsWithLists();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    // Construir itens do menu com hierarquia
    final List<PopupMenuEntry<String>> menuItems = [];

    projectsWithLists.forEach((project, lists) {
      // Se o projeto não tem listas, pular
      if (lists.isEmpty) return;

      // Adicionar cabeçalho do projeto (não selecionável)
      menuItems.add(
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            children: [
              // Ícone do projeto ou casa para "Tarefas"
              Icon(
                project.name == 'Tarefas'
                    ? Icons.home_outlined
                    : Icons.folder_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Text(
                project.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );

      // Adicionar listas do projeto (recuadas)
      for (final list in lists) {
        final isSelected = list.id == selectedListId;

        menuItems.add(
          PopupMenuItem<String>(
            value: list.id,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
              ), // Recuo para hierarquia
              child: Row(
                children: [
                  // Ícone de lista pequeno
                  Icon(
                    Icons.format_list_bulleted,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 12),

                  // Nome da lista
                  Expanded(
                    child: Text(
                      list.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                        color:
                            isSelected
                                ? Colors.grey.shade800
                                : Colors.grey.shade700,
                      ),
                    ),
                  ),

                  // Ícone de selecionado
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check, size: 16, color: Colors.grey.shade600),
                  ],
                ],
              ),
            ),
          ),
        );
      }
    });

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy - 200,
        position.dx + renderBox.size.width,
        position.dy,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      elevation: 8,
      items: menuItems,
    ).then((selectedListId) {
      if (selectedListId != null) {
        onListChanged(selectedListId);
      }
    });
  }
}
