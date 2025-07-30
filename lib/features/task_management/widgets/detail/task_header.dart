import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';

/// **TaskHeader** - Cabeçalho do painel de detalhes da tarefa
///
/// Componente que exibe a seta de voltar e o campo de título editável
class TaskHeader extends StatelessWidget {
  final TextEditingController titleController;
  final TaskController taskController;

  const TaskHeader({
    Key? key,
    required this.titleController,
    required this.taskController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Seta de voltar
        IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => taskController.selectTask(null),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),

        const SizedBox(width: 16),

        // Campo de título
        Expanded(
          child: TextField(
            controller: titleController,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              hintText: 'Título da tarefa',
              hintStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
