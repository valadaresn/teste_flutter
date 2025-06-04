import 'package:flutter/material.dart';

class NoteDialog extends StatefulWidget {
  final String title;
  final String initialTitle;
  final String initialContent;
  final List<String> initialTags;
  final List<String> availableTags;
  final Color Function(String) getTagColor;

  const NoteDialog({
    Key? key,
    required this.title,
    this.initialTitle = '',
    this.initialContent = '',
    this.initialTags = const [],
    required this.availableTags,
    required this.getTagColor,
  }) : super(key: key);

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late List<String> _selectedTags;
  late Map<String, Color> _contrastColors; // Cache das cores de contraste

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _selectedTags = List<String>.from(widget.initialTags);

    // Pre-calcular todas as cores de contraste para evitar cálculos durante o build
    _contrastColors = {};
    for (String tag in widget.availableTags) {
      final tagColor = widget.getTagColor(tag);
      _contrastColors[tag] = _getContrastColor(tagColor);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Conteúdo'),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            const Text('Tags:'),
            const SizedBox(height: 8),
            _buildTagsSelection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _onSave, child: const Text('Salvar')),
      ],
    );
  }

  Widget _buildTagsSelection() {
    return Wrap(
      spacing: 8,
      children:
          widget.availableTags.map((tag) {
            final tagColor = widget.getTagColor(tag);
            final contrastColor = _contrastColors[tag]!; // Usa o cache
            final isSelected = _selectedTags.contains(tag);

            return FilterChip(
              label: Text(
                tag,
                style: TextStyle(color: isSelected ? contrastColor : null),
              ),
              backgroundColor: tagColor.withOpacity(0.2),
              selectedColor: tagColor,
              checkmarkColor: contrastColor,
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _onSave() {
    Navigator.pop(context, {
      'title': _titleController.text,
      'content': _contentController.text,
      'tags': _selectedTags,
    });
  }
}
