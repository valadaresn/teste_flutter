import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/list_model.dart' as Models;

/// **ListFormDialog** - Diálogo para criação e edição de listas
///
/// Este componente é responsável por:
/// - Exibir formulário para criar novas listas
/// - Exibir formulário para editar listas existentes
/// - Validar dados de entrada
/// - Permitir seleção de emoji e cor
/// - Mostrar informações do projeto selecionado
///
/// **Funcionalidades:**
/// - Campos de entrada: nome da lista
/// - Seleção de emoji de uma lista predefinida
/// - Seleção de cor de uma paleta predefinida
/// - Informação contextual do projeto ativo
/// - Validação de nome obrigatório
/// - Integração com TaskController para operações CRUD
/// - Suporte para criação (list = null) e edição (list != null)
class ListFormDialog extends StatefulWidget {
  final TaskController controller;
  final Models.TaskList? list; // null = criação, não-null = edição

  const ListFormDialog({
    Key? key,
    required this.controller,
    this.list, // Parâmetro opcional para edição
  }) : super(key: key);

  @override
  State<ListFormDialog> createState() => _ListFormDialogState();
}

class _ListFormDialogState extends State<ListFormDialog> {
  late final TextEditingController _nameController;
  late String _selectedEmoji;
  late Color _selectedColor;

  // Lista de emojis disponíveis
  static const List<String> _availableEmojis = [
    '📋',
    '📝',
    '📚',
    '🏠',
    '🛒',
    '💼',
    '🎯',
    '⭐',
    '🔥',
    '💡',
    '🚀',
    '📱',
  ];

  // Lista de cores disponíveis
  static const List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];
  @override
  void initState() {
    super.initState();

    // Inicializar campos baseado no modo (criação vs edição)
    final editingList = widget.list;

    if (editingList != null) {
      // Modo edição - pré-preencher com dados existentes
      _nameController = TextEditingController(text: editingList.name);
      _selectedEmoji = editingList.emoji;
      _selectedColor = editingList.color;
    } else {
      // Modo criação - valores padrão
      _nameController = TextEditingController();
      _selectedEmoji = '📋';
      _selectedColor = Colors.blue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedProject =
        widget.controller.selectedProjectId != null
            ? widget.controller.projects.firstWhere(
              (p) => p.id == widget.controller.selectedProjectId,
            )
            : null;

    return AlertDialog(
      title: Row(
        children: [
          Text(widget.list != null ? 'Editar Lista' : 'Nova Lista'),

          // Mostrar projeto selecionado (apenas para criação)
          if (widget.list == null && selectedProject != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                selectedProject.name,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de nome
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Lista',
                hintText: 'Ex: Compras, Trabalho, Pessoal',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            // Seleção de emoji
            Text('Emoji', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _availableEmojis.map((emoji) {
                    final isSelected = _selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = emoji),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer
                                  : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.outline.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),

            // Seleção de cor
            Text('Cor', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  _availableColors.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                  : null,
                        ),
                      ),
                    );
                  }).toList(),
            ), // Informação do projeto (apenas para criação)
            if (widget.list == null && selectedProject != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta lista será criada no projeto "${selectedProject.name}"',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        // Botão Cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ), // Botão de ação principal
        ElevatedButton(
          onPressed: () => _saveList(),
          child: Text(widget.list != null ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }

  /// Salva a lista (criação ou edição)
  void _saveList() {
    final name = _nameController.text.trim();

    // Validação
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome da lista é obrigatório'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final editingList = widget.list;
    if (editingList != null) {
      // Modo edição - atualizar lista existente
      final formData = {
        'name': name,
        'color': _selectedColor,
        'emoji': _selectedEmoji,
        'sortOrder': editingList.sortOrder, // Manter ordem atual
      };
      widget.controller.updateList(editingList.id, formData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lista atualizada com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Modo criação - criar nova lista
      final newList = Models.TaskList.create(
        id: '', // ID será gerado automaticamente
        name: name,
        color: _selectedColor,
        emoji: _selectedEmoji,
        projectId: widget.controller.selectedProjectId,
      );
      widget.controller.createList(newList);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lista criada com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }

    Navigator.of(context).pop();
  }
}
