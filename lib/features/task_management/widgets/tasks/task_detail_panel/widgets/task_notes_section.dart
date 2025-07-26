import 'package:flutter/material.dart';

/// **TaskNotesSection** - Seção de anotações
///
/// Componente independente para o campo de anotações da tarefa
class TaskNotesSection extends StatelessWidget {
  final TextEditingController controller;

  const TaskNotesSection({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de anotações
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            hintText: 'Adicionar anotação',
            hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          maxLines: null,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),

        const SizedBox(height: 16),

        // Divisor sutil
        Container(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}
