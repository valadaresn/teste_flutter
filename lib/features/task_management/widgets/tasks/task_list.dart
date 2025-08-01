import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../components/generic_selector_list.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../themes/theme_provider.dart';
import 'card_factory.dart';
import '../input/quick_add_task_input.dart';

class TaskList extends StatelessWidget {
  final TaskController controller;
  final List<Task>? tasks; // 🆕 NOVO: Lista opcional pré-filtrada

  const TaskList({
    Key? key,
    required this.controller,
    this.tasks, // 🆕 Se não fornecida, usa controller.tasks
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lista de tarefas
        Expanded(
          child: GenericSelectorList<TaskController, Task>(
            // 🔍 USA LISTA FORNECIDA OU LISTA COMPLETA DO CONTROLLER
            listSelector: (controller) => tasks ?? controller.tasks,

            // Função para extrair um item pelo seu ID - ITEM #5 das instruções
            itemById: (controller, id) => controller.getTaskById(id),

            // Função para extrair o ID de cada item
            idExtractor: (task) => task.id,

            // Constrói o widget de cada item
            itemBuilder:
                (context, task) => Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    // Determinar se é visualização de todas as tarefas ou lista específica
                    final isAllTasksView = controller.selectedListId == null;
                    final cardStyle =
                        isAllTasksView
                            ? themeProvider.allTasksViewCardStyle
                            : themeProvider.listViewCardStyle;

                    return CardFactory.buildCard(
                      style: cardStyle,
                      task: task,
                      controller: controller,
                      isSelected: controller.selectedTaskId == task.id,
                      onTap: () => _showTaskDetails(context, task),
                      onEdit: () => _showEditTask(context, task),
                      onDelete: () => _showDeleteConfirmation(context, task),
                    );
                  },
                ),
            // Configurações de layout
            padding: const EdgeInsets.all(16),
            spacing: 2.0,
          ),
        ),

        // Campo de entrada rápida no bottom
        QuickAddTaskInput(controller: controller),
      ],
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    // Selecionar a tarefa no controller
    controller.selectTask(task.id);
  }

  void _showEditTask(BuildContext context, Task task) {
    // TODO: Implementar formulário de edição
    print('✏️ Editar tarefa: ${task.title}');
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Text(
              'Tem certeza que deseja excluir a tarefa "${task.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  controller.deleteTask(task.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tarefa "${task.title}" excluída')),
                  );
                },
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }
}
