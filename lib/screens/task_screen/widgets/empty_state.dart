import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onAddTask;

  const EmptyState({super.key, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa pendente',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddTask,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar tarefa'),
          ),
        ],
      ),
    );
  }
}
