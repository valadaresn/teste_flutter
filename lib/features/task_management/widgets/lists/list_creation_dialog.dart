import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/list_model.dart';

class ListCreationDialog extends StatefulWidget {
  final TaskController controller;

  const ListCreationDialog({Key? key, required this.controller})
    : super(key: key);

  @override
  State<ListCreationDialog> createState() => _ListCreationDialogState();
}

class _ListCreationDialogState extends State<ListCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedEmoji = '📋';
  Color _selectedColor = Colors.blue;
  String? _selectedProjectId;
  bool _isLoading = false;

  final List<String> _emojiOptions = [
    '📋',
    '📝',
    '✅',
    '📌',
    '🎯',
    '⭐',
    '🏠',
    '💼',
    '🎓',
    '🛒',
    '💡',
    '🚀',
    '❤️',
    '🎉',
    '🔥',
    '⚡',
  ];

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.controller.selectedProjectId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createList() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newList = TaskList.create(
        id: '',
        name: _nameController.text.trim(),
        color: _selectedColor,
        emoji: _selectedEmoji,
        isDefault: false,
        sortOrder: 0,
        projectId: _selectedProjectId,
      );

      await widget.controller.createList(newList);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao criar lista: $e')));
      setState(() {
        _isLoading = false;
      });
    }
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
              // Nome da lista
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da lista',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Projeto (dropdown)
              Text('Projeto', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _selectedProjectId,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Sem projeto'),
                  ),
                  ...widget.controller.projects.map(
                    (project) => DropdownMenuItem<String?>(
                      value: project.id,
                      child: Row(
                        children: [
                          Text(project.emoji),
                          const SizedBox(width: 8),
                          Text(project.name),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Emoji
              Text('Ícone', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1.0,
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
                          color:
                              isSelected ? Colors.blue.withOpacity(0.2) : null,
                          border: Border.all(
                            color:
                                isSelected ? Colors.blue : Colors.transparent,
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
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Cor
              Text('Cor', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Row(
                children:
                    _colorOptions.map((color) {
                      final isSelected = color.value == _selectedColor.value;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.black
                                        : Colors.transparent,
                                width: isSelected ? 2 : 0,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createList,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Criar Lista'),
        ),
      ],
    );
  }
}
