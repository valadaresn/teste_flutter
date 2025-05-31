import 'package:flutter/material.dart';

/// A dialog widget for creating or editing diary entries
class DiaryEntryDialog extends StatefulWidget {
  final String? title;
  final String? content;
  final String? mood;
  final List<String>? tags;
  final String dialogTitle;
  final List<String> moodOptions;
  final List<String> availableTags;

  const DiaryEntryDialog({
    super.key,
    this.title,
    this.content,
    this.mood,
    this.tags,
    this.dialogTitle = 'Nova Entrada no Diário',
    required this.moodOptions,
    required this.availableTags,
  });

  @override
  State<DiaryEntryDialog> createState() => _DiaryEntryDialogState();

  /// Helper method to show the dialog
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    String? title,
    String? content,
    String? mood,
    List<String>? tags,
    String? dialogTitle,
    required List<String> moodOptions,
    required List<String> availableTags,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => DiaryEntryDialog(
            title: title,
            content: content,
            mood: mood,
            tags: tags,
            dialogTitle: dialogTitle ?? 'Nova Entrada no Diário',
            moodOptions: moodOptions,
            availableTags: availableTags,
          ),
    );
  }
}

class _DiaryEntryDialogState extends State<DiaryEntryDialog> {
  late final TextEditingController _contentController;
  late final TextEditingController _titleController;
  late final List<String> _selectedTags;
  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.content);
    _titleController = TextEditingController(text: widget.title);
    _selectedTags = List<String>.from(widget.tags ?? []);
    _selectedMood = widget.mood;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título (opcional)',
                hintText: 'Adicione um título',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Conteúdo',
                hintText: 'Escreva seus pensamentos...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            _buildTagsSection(),
            const SizedBox(height: 16),
            _buildMoodSelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _saveEntry, child: const Text('Salvar')),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Tags',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            value: null,
            hint: Text(
              _selectedTags.isEmpty
                  ? 'Selecione as tags'
                  : _selectedTags.map((t) => '#$t').join(', '),
            ),
            isExpanded: true,
            underline: const SizedBox(),
            items:
                widget.availableTags
                    .where((tag) => !_selectedTags.contains(tag))
                    .map((String tag) {
                      return DropdownMenuItem<String>(
                        value: tag,
                        child: Text('#$tag'),
                      );
                    })
                    .toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _selectedTags.add(value);
                });
              }
            },
          ),
        ),
        if (_selectedTags.isNotEmpty)
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children:
                _selectedTags
                    .map(
                      (tag) => Chip(
                        label: Text('#$tag'),
                        onDeleted: () {
                          setState(() {
                            _selectedTags.remove(tag);
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
          ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Wrap(
      spacing: 8,
      children:
          widget.moodOptions
              .map(
                (mood) => InkWell(
                  onTap: () {
                    setState(() => _selectedMood = mood);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          _selectedMood == mood
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      mood,
                      style: TextStyle(
                        fontSize: 24,
                        color:
                            _selectedMood == mood
                                ? Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer
                                : null,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  void _saveEntry() {
    if (_contentController.text.trim().isEmpty) return;
    Navigator.pop(context, {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'mood': _selectedMood,
      'tags': _selectedTags,
    });
  }
}
