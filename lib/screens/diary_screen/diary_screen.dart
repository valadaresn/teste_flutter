import 'package:flutter/material.dart';
import '../../models/diary_entry.dart';
import 'package:uuid/uuid.dart';
import 'diary_view_type.dart';
import 'views/temporal_view.dart';
import 'views/mood_view.dart';
import '../../data/diary_test_data.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late List<DiaryEntry> _entries;
  final _uuid = const Uuid();
  final List<String> _moodOptions = ['😊', '😐', '😢', '😡', '🤔', '😴'];
  DiaryViewType _currentView = DiaryViewType.daily;

  @override
  void initState() {
    super.initState();
    _entries = List.from(testEntries); // Usando os dados de teste
  }

  Future<Map<String, dynamic>?> _showEntryDialog({
    String? title,
    String? content,
    String? mood,
    String? dialogTitle,
  }) async {
    final contentController = TextEditingController(text: content);
    final titleController = TextEditingController(text: title);
    String? selectedMood = mood;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(dialogTitle ?? 'Nova Entrada no Diário'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título (opcional)',
                            hintText: 'Adicione um título',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: contentController,
                          decoration: const InputDecoration(
                            labelText: 'Conteúdo',
                            hintText: 'Escreva seus pensamentos...',
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children:
                              _moodOptions
                                  .map(
                                    (mood) => InkWell(
                                      onTap: () {
                                        setState(() => selectedMood = mood);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color:
                                              mood == selectedMood
                                                  ? Theme.of(
                                                    context,
                                                  ).primaryColor.withAlpha(51)
                                                  : null,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          mood,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (contentController.text.trim().isEmpty) return;
                        Navigator.pop(context, {
                          'title': titleController.text.trim(),
                          'content': contentController.text.trim(),
                          'mood': selectedMood,
                        });
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _addEntry() async {
    final result = await _showEntryDialog();

    if (result != null) {
      setState(() {
        _entries.add(
          DiaryEntry(
            id: _uuid.v4(),
            title: result['title'].isEmpty ? null : result['title'],
            content: result['content'],
            dateTime: DateTime.now(),
            mood: result['mood'],
          ),
        );
      });
    }
  }

  void _editEntry(DiaryEntry entry) async {
    final result = await _showEntryDialog(
      title: entry.title,
      content: entry.content,
      mood: entry.mood,
      dialogTitle: 'Editar Entrada',
    );

    if (result != null) {
      setState(() {
        final index = _entries.indexWhere((e) => e.id == entry.id);
        if (index != -1) {
          _entries[index] = DiaryEntry(
            id: entry.id,
            title: result['title'].isEmpty ? null : result['title'],
            content: result['content'],
            dateTime: entry.dateTime,
            mood: result['mood'],
          );
        }
      });
    }
  }

  void _deleteEntry(String id) {
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
    });
  }

  Widget _buildCurrentView() {
    if (_currentView == DiaryViewType.mood) {
      return MoodView(
        entries: _entries,
        onTap: _editEntry,
        onDelete: _deleteEntry,
      );
    }

    return TemporalView(
      entries: _entries,
      onTap: _editEntry,
      onDelete: _deleteEntry,
      viewType: _currentView,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Diário'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children:
                  DiaryViewType.values
                      .map(
                        (type) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(type.label),
                            selected: _currentView == type,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _currentView = type);
                              }
                            },
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ),
      body:
          _entries.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.book, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Seu diário está vazio',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _addEntry,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar primeira entrada'),
                    ),
                  ],
                ),
              )
              : _buildCurrentView(),
      floatingActionButton:
          _entries.isNotEmpty
              ? FloatingActionButton(
                onPressed: _addEntry,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
