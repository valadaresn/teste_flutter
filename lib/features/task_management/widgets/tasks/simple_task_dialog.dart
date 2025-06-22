import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';

class TaskCreationDialog extends StatefulWidget {
  final TaskController controller;

  const TaskCreationDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  final _titleController = TextEditingController();
  String? _selectedListId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller.lists.isNotEmpty) {
      _selectedListId = widget.controller.lists.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Tarefa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título da tarefa',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.controller.lists.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _selectedListId,
              decoration: const InputDecoration(
                labelText: 'Lista',
                border: OutlineInputBorder(),
              ),
              items: widget.controller.lists.map((list) {
                return DropdownMenuItem(
                  value: list.id,
                  child: Text('${list.emoji} ${list.name}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedListId = value;
                });
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createTask,
          child: _isLoading 
            ? const CircularProgressIndicator()
            : const Text('Criar'),
        ),
      ],
    );
  }

  Future<void> _createTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um título para a tarefa')),
      );
      return;
    }

    if (_selectedListId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma lista')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newTask = Task.create(
        id: '',
        title: _titleController.text.trim(),
        description: '',
        listId: _selectedListId!,
        priority: TaskPriority.medium,
        isImportant: false,
        dueDate: null,
        tags: [],
      );

      await widget.controller.createTask(newTask);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
