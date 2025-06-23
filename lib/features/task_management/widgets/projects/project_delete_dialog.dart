import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';

/// Dialog de confirmação para exclusão de projetos
/// Mostra informações sobre listas vinculadas e consequências da exclusão
class ProjectDeleteDialog extends StatelessWidget {
  final TaskController controller;
  final dynamic project;

  const ProjectDeleteDialog({
    Key? key,
    required this.controller,
    required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Busca listas vinculadas ao projeto
    final linkedLists =
        controller.lists.where((list) => list.projectId == project.id).toList();

    return AlertDialog(
      title: const Text('Excluir Projeto'),
      content: _buildContent(context, linkedLists),
      actions: _buildActions(context),
    );
  }

  /// Constrói o conteúdo do dialog com avisos e informações
  Widget _buildContent(BuildContext context, List linkedLists) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pergunta de confirmação
        Text(
          'Tem certeza que deseja excluir o projeto "${project.name}"?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Aviso sobre listas vinculadas (se houver)
        if (linkedLists.isNotEmpty) ...[
          _buildLinkedListsWarning(context, linkedLists),
          const SizedBox(height: 16),
        ],

        // Aviso sobre irreversibilidade
        _buildIrreversibilityWarning(context),
      ],
    );
  }

  /// Widget de aviso sobre listas vinculadas
  Widget _buildLinkedListsWarning(BuildContext context, List linkedLists) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do aviso
          Row(
            children: [
              Icon(Icons.warning, size: 16, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Atenção:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Descrição do problema
          Text(
            'Este projeto possui ${linkedLists.length} lista(s) associada(s):',
            style: TextStyle(color: Colors.orange.shade700),
          ),
          const SizedBox(height: 4),

          // Lista das listas vinculadas (máximo 3 + contador)
          ...linkedLists
              .take(3)
              .map(
                (list) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '• ${list.emoji} ${list.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ),
              ),

          // Indicador de mais listas (se houver)
          if (linkedLists.length > 3)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '... e mais ${linkedLists.length - 3}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Explicação do que acontecerá
          Text(
            'As listas serão movidas para "Sem projeto".',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget de aviso sobre a irreversibilidade da ação
  Widget _buildIrreversibilityWarning(BuildContext context) {
    return const Text(
      'Esta ação não pode ser desfeita.',
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    );
  }

  /// Botões de ação do dialog
  List<Widget> _buildActions(BuildContext context) {
    return [
      // Botão cancelar
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),

      // Botão confirmar exclusão
      ElevatedButton(
        onPressed: () => _confirmDelete(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: const Text('Excluir'),
      ),
    ];
  }

  /// Confirma e executa a exclusão do projeto
  void _confirmDelete(BuildContext context) {
    // Chama o método de exclusão do controller
    controller.deleteProject(project.id);

    // Fecha o dialog
    Navigator.pop(context);

    // Opcional: Mostrar snackbar de confirmação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Projeto "${project.name}" foi excluído'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
