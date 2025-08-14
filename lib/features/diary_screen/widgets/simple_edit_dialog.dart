import 'package:flutter/material.dart';
import '../diary_controller.dart' as NewDiary;
import '../../../models/diary_entry.dart';

class SimpleEditDialog extends StatefulWidget {
  final DiaryEntry entry;
  final NewDiary.DiaryController controller;

  const SimpleEditDialog({
    Key? key,
    required this.entry,
    required this.controller,
  }) : super(key: key);

  @override
  State<SimpleEditDialog> createState() => _SimpleEditDialogState();
}

class _SimpleEditDialogState extends State<SimpleEditDialog> {
  late TextEditingController _contentController;
  late String _selectedMood;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.entry.content);
    _selectedMood = widget.entry.mood;
    _isFavorite = widget.entry.isFavorite;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Entrada'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              labelText: 'Conteúdo',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedMood,
            decoration: InputDecoration(
              labelText: 'Humor',
              border: OutlineInputBorder(),
            ),
            items:
                ['😊', '😐', '😢', '😡', '😴', '🤔']
                    .map(
                      (mood) =>
                          DropdownMenuItem(value: mood, child: Text(mood)),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedMood = value;
                });
              }
            },
          ),
          SizedBox(height: 16),
          CheckboxListTile(
            title: Text('Favorito'),
            value: _isFavorite,
            onChanged: (value) {
              setState(() {
                _isFavorite = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _saveChanges, child: Text('Salvar')),
      ],
    );
  }

  void _saveChanges() async {
    try {
      final formData = {
        'content': _contentController.text,
        'mood': _selectedMood,
        'isFavorite': _isFavorite,
        'tags': widget.entry.tags,
        'title': widget.entry.title,
        'taskId': widget.entry.taskId,
        'taskName': widget.entry.taskName,
        'projectId': widget.entry.projectId,
        'projectName': widget.entry.projectName,
      };

      final updatedEntry = DiaryEntry.updateFromForm(widget.entry, formData);
      await widget.controller.updateEntry(updatedEntry);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Entrada atualizada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
  }
}
