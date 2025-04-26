import 'package:flutter/material.dart';

/// Widget modal para adicionar uma nova tarefa (apenas título).
/// Mantém o nome 'modal' pois é exibido como um bottom sheet/modal.
class AddTaskModal extends StatefulWidget {
  const AddTaskModal({super.key});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.of(context).pop(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Adicionar uma tarefa',
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.send),
          onPressed: _submit,
        ),
      ),
      onSubmitted: (_) => _submit(),
    );
  }
}
