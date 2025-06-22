import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/list_model.dart';

class ListCreationDialog extends StatefulWidget {
  final TaskController controller;

  const ListCreationDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<ListCreationDialog> createState() => _ListCreationDialogState();
}

class _ListCreationDialogState extends State<ListCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedEmoji = '📋';
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;

  // Lista de emojis comuns para listas
  final List<String> _emojiOptions = [
    '📋', '📝', '✅', '📌', '🎯', '⭐', '🏠', '💼', 
    '🎓', '🛒', '💡', '🚀', '❤️', '🎉', '🔥', '⚡',
    '🌟', '🎪', '🎨', '🏆', '🎮', '📚', '🎬', '🎵',
  ];

  // Lista de cores predefinidas
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Lista'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Lista',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.list),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _createList(),
              ),

              const SizedBox(height: 16),

              // Campo descrição
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Seleção de emoji
              const Text(
                'Emoji:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: _emojiOptions.length,
                  itemBuilder: (context, index) {
                    final emoji = _emojiOptions[index];
                    final isSelected = emoji == _selectedEmoji;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEmoji = emoji;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Seleção de cor
              const Text(
                'Cor:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colorOptions.length,
                  itemBuilder: (context, index) {
                    final color = _colorOptions[index];
                    final isSelected = color == _selectedColor;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createList,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Criar Lista'),
        ),
      ],
    );
  }

  Future<void> _createList() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {      final newList = TaskList.create(
        id: '', // Será substituído pelo controller
        name: _nameController.text.trim(),
        color: _selectedColor,
        emoji: _selectedEmoji,
      );

      await widget.controller.createList(newList);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lista "${newList.name}" criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar lista: $e'),
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
}
