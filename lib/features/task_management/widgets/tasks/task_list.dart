import 'package:flutter/material.dart';
import '../../../../components/generic_selector_list.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import 'task_card.dart';
import 'quick_add_task_input.dart';

class TaskList extends StatelessWidget {
  final TaskController controller;

  const TaskList({Key? key, required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de entrada rápida no topo
        QuickAddTaskInput(controller: controller),
        
        // Lista de tarefas
        Expanded(
          child: GenericSelectorList<TaskController, Task>(
            // Função para extrair a lista filtrada do controller
            listSelector: (controller) => controller.tasks,
            
            // Função para extrair um item pelo seu ID - ITEM #5 das instruções
            itemById: (controller, id) => controller.getTaskById(id),
            
            // Função para extrair o ID de cada item
            idExtractor: (task) => task.id,
            
            // Constrói o widget de cada item
            itemBuilder: (context, task) => TaskCard(
              task: task,
              controller: controller,
              onToggleComplete: () => controller.toggleTaskCompletion(task.id),
              onToggleImportant: () => controller.toggleTaskImportant(task.id),
              onTap: () => _showTaskDetails(context, task),
              onEdit: () => _showEditTask(context, task),
              onDelete: () => _showDeleteConfirmation(context, task),
            ),
              // Configurações de layout
            padding: const EdgeInsets.all(16),
            spacing: 2.0,
          ),
        ),
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
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a tarefa "${task.title}"?'),
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
                SnackBar(
                  content: Text('Tarefa "${task.title}" excluída'),
                ),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
