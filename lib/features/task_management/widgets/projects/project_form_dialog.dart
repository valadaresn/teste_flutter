import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';

/// Dialog reutilizável para criar e editar projetos
/// Se `project` for null, funciona em modo criação
/// Se `project` for fornecido, funciona em modo edição
class ProjectFormDialog extends StatefulWidget {
  final TaskController controller;
  final dynamic project; // null para criação, objeto para edição

  const ProjectFormDialog({
    Key? key,
    required this.controller,
    this.project, // Opcional: null = criar, object = editar
  }) : super(key: key);

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedEmoji;
  late Color _selectedColor;

  /// Lista de emojis disponíveis para projetos
  static const List<String> _availableEmojis = [
    '📁',
    '💼',
    '🏠',
    '🎯',
    '📚',
    '🎨',
  ];

  /// Lista de cores disponíveis para projetos
  static const List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  /// Inicializa os controllers com valores padrão ou do projeto existente
  void _initializeControllers() {
    final isEditing = widget.project != null;

    _nameController = TextEditingController(
      text: isEditing ? widget.project.name : '',
    );
    _descriptionController = TextEditingController(
      text: isEditing ? (widget.project.description ?? '') : '',
    );
    _selectedEmoji = isEditing ? widget.project.emoji : _availableEmojis.first;
    _selectedColor = isEditing ? widget.project.color : _availableColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Projeto' : 'Novo Projeto'),
      content: _buildFormContent(),
      actions: _buildActions(context, isEditing),
    );
  }

  /// Constrói o conteúdo do formulário
  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo de nome (obrigatório)
          _buildNameField(),
          const SizedBox(height: 16),

          // Campo de descrição (opcional)
          _buildDescriptionField(),
          const SizedBox(height: 16),

          // Seletor de emoji
          _buildEmojiSelector(),
          const SizedBox(height: 16),

          // Seletor de cor
          _buildColorSelector(),
        ],
      ),
    );
  }

  /// Campo de texto para o nome do projeto
  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nome do Projeto',
        hintText: 'Ex: Projeto Pessoal',
        border: OutlineInputBorder(),
      ),
      autofocus: true,
      textCapitalization: TextCapitalization.words,
    );
  }

  /// Campo de texto para a descrição do projeto
  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descrição (opcional)',
        hintText: 'Descreva seu projeto',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  /// Seletor horizontal de emojis
  Widget _buildEmojiSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ícone',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              _availableEmojis
                  .map((emoji) => _buildEmojiOption(emoji))
                  .toList(),
        ),
      ],
    );
  }

  /// Item individual do seletor de emoji
  Widget _buildEmojiOption(String emoji) {
    final isSelected = _selectedEmoji == emoji;

    return GestureDetector(
      onTap: () => setState(() => _selectedEmoji = emoji),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : null,
          borderRadius: BorderRadius.circular(8),
          border:
              isSelected
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : null,
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  /// Seletor horizontal de cores
  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cor',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              _availableColors
                  .map((color) => _buildColorOption(color))
                  .toList(),
        ),
      ],
    );
  }

  /// Item individual do seletor de cor
  Widget _buildColorOption(Color color) {
    final isSelected = _selectedColor == color;

    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        child:
            isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
      ),
    );
  }

  /// Botões de ação do dialog
  List<Widget> _buildActions(BuildContext context, bool isEditing) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      ElevatedButton(
        onPressed: _canSave() ? () => _saveProject(context, isEditing) : null,
        child: Text(isEditing ? 'Salvar' : 'Criar'),
      ),
    ];
  }

  /// Verifica se o formulário pode ser salvo
  bool _canSave() {
    return _nameController.text.trim().isNotEmpty;
  }

  /// Salva o projeto (criar ou editar)
  void _saveProject(BuildContext context, bool isEditing) {
    final projectData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'color': _selectedColor,
      'emoji': _selectedEmoji,
    };

    if (isEditing) {
      // Modo edição: adiciona o ID e chama updateProject
      projectData['id'] = widget.project.id;
      widget.controller.updateProject(widget.project.id, projectData);
    } else {
      // Modo criação: chama addProject
      widget.controller.addProject(projectData);
    }

    Navigator.pop(context);
  }
}
