import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../components/generic_selector_list.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../themes/theme_provider.dart';
import '../../../../../widgets/common/cards/task_card.dart';
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
                    // Obter cor da lista selecionada
                    final selectedList =
                        controller.selectedListId != null
                            ? controller.getListById(controller.selectedListId!)
                            : null;
                    final listColor = selectedList?.color ?? Colors.blue;

                    return TaskCard(
                      title: task.title,
                      description:
                          task.description.isNotEmpty ? task.description : null,
                      listColor: listColor,
                      isSelected: controller.selectedTaskId == task.id,
                      onTap: () => _showTaskDetails(context, task),
                      // Configurações do pomodoro (usando tempo dinâmico da tarefa)
                      pomodoroTargetSeconds: task.pomodoroTimeMinutes * 60, // Converter minutos para segundos
                      onPomodoroComplete: () {
                        debugPrint('Pomodoro completo para tarefa: ${task.title}');
                      },
                      onToggleCompletion: () => controller.toggleTaskCompletion(task.id),
                      // 🆕 Dados para log interno do PomodoroTimerModule
                      task: task,
                      taskList: selectedList,
                      shouldLog: true, // Sempre registrar log para tarefas
                    );
                  },
                ),
            // Configurações de layout
            padding: const EdgeInsets.all(16),
            spacing: 2.0,
          ),
        ),

        // Campo de entrada rápida no bottom - APENAS NO DESKTOP (>= 1024px)
        if (MediaQuery.of(context).size.width >= 1024)
          QuickAddTaskInput(controller: controller),
      ],
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    // Selecionar a tarefa no controller
    controller.selectTask(task.id);
  }
}
