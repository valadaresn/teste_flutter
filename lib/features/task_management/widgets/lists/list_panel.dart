import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/list_model.dart';
import 'list_item.dart';
import 'list_creation_dialog.dart';

class ListPanel extends StatelessWidget {
  final TaskController controller;

  const ListPanel({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cabeçalho com botão "+"
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Listas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => _showCreateListDialog(context),
                tooltip: 'Nova lista',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        // Lista de listas
        Expanded(
          child: _buildListsList(context),
        ),
      ],
    );
  }

  Widget _buildListsList(BuildContext context) {
    if (controller.lists.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhuma lista encontrada'),
            Text('Clique no + para criar uma nova lista'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.lists.length,
      itemBuilder: (context, index) {
        final list = controller.lists[index];
        return ListItem(
          list: list,
          controller: controller,
          isSelected: controller.selectedListId == list.id,
          onTap: () => _selectList(list),
        );
      },
    );
  }

  void _selectList(TaskList list) {
    final isCurrentlySelected = controller.selectedListId == list.id;
    controller.selectList(isCurrentlySelected ? null : list.id);
  }
  void _showCreateListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ListCreationDialog(
        controller: controller,
      ),
    );
  }
}
