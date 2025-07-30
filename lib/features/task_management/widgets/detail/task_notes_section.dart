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
        // Título da seção
        Text(
          'Anotações',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 12),

        // Campo de texto
        TextField(
          controller: controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Adicionar anotações...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        ),

        const SizedBox(height: 16),

        // Divisor sutil
        Container(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}
