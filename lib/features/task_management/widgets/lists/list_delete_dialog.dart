import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/list_model.dart' as Models;

/// **ListDeleteDialog** - Diálogo para confirmação de exclusão de lista
///
/// Este componente é responsável por:
/// - Confirmar a exclusão de uma lista vazia
/// - Exibir informações sobre a lista a ser excluída
/// - Validar se a lista está vazia antes da exclusão
/// - Executar a exclusão via TaskController
/// - Fornecer feedback visual adequado
///
/// **Funcionalidades:**
/// - Confirmação de exclusão com informações da lista
/// - Validação de lista vazia (regra de negócio)
/// - Integração com TaskController para exclusão
/// - Feedback de sucesso/erro via SnackBar
/// - Interface responsiva e acessível
class ListDeleteDialog extends StatelessWidget {
  final TaskController controller;
  final Models.TaskList list;

  const ListDeleteDialog({
    Key? key,
    required this.controller,
    required this.list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Verificar se a lista tem tarefas
    final taskCount = controller.getTasksByList(list.id).length;
    final isEmpty = taskCount == 0;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isEmpty ? Icons.delete_outline : Icons.warning_amber_outlined,
            color: isEmpty ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 8),
          const Text('Excluir Lista'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações da lista
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: list.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: list.color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(list.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$taskCount tarefa${taskCount != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mensagem baseada no estado da lista
          if (isEmpty) ...[
            Text(
              'Tem certeza que deseja excluir esta lista?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta ação não pode ser desfeita.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta lista contém $taskCount tarefa${taskCount != 1 ? 's' : ''} e não pode ser excluída.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Para excluir esta lista, primeiro remova ou mova todas as tarefas para outras listas.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Botão Cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),

        // Botão de exclusão (apenas se lista vazia)
        if (isEmpty)
          ElevatedButton(
            onPressed: () => _deleteList(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
      ],
    );
  }

  /// Executa a exclusão da lista
  void _deleteList(BuildContext context) async {
    try {
      await controller.deleteList(list.id);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lista "${list.name}" excluída com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir lista: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
