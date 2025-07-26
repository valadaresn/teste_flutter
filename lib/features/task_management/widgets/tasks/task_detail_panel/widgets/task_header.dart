import 'package:flutter/material.dart';
import '../../../../controllers/task_controller.dart';

/// **TaskHeader** - Header com seta de voltar e título editável
///
/// Componente independente que combina a seta de navegação
/// com o campo de título editável na mesma linha
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
    return Container(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          // Seta de voltar (fechar painel)
          IconButton(
            onPressed: () => taskController.selectTask(null),
            icon: const Icon(Icons.arrow_back, size: 20),
            splashRadius: 20,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),

          const SizedBox(width: 8),

          // Título editável ocupando espaço restante
          Expanded(child: _TaskTitleField(controller: titleController)),
        ],
      ),
    );
  }
}

/// Campo de título editável
class _TaskTitleField extends StatelessWidget {
  final TextEditingController controller;

  const _TaskTitleField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
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
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}
