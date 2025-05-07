import 'package:flutter/material.dart';
import '../../models/diary_entry.dart';
import 'package:uuid/uuid.dart';
import 'views/temporal_view.dart';
import 'views/mood_view.dart';
import 'views/tag_view.dart';
import 'widgets/diary_card.dart';
import '../../data/diary_test_data.dart';
import 'diary_view_type.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late List<DiaryEntry> _entries;
  final _uuid = Uuid(); // Removed const
  final List<String> _moodOptions = ['😊', '😐', '😢', '😡', '🤔', '😴'];
  final List<String> _availableTags = [
    'trabalho',
    'pessoal',
    'saúde',
    'família',
    'projeto',
    'estudo',
    'reunião',
    'importante',
    'ideias',
    'bugs',
  ];
  DiaryCardLayout _cardLayout = DiaryCardLayout.standard;
  String _currentView = 'timeline'; // timeline, mood, tags, favorites
  final Map<String, bool> _favorites = {};

  @override
  void initState() {
    super.initState();
    _entries = List.from(testEntries);
    // Inicializa favoritos dos dados de teste
    for (var entry in _entries) {
      if (entry.isFavorite) {
        _favorites[entry.id] = true;
      }
    }
  }

  Future<Map<String, dynamic>?> _showEntryDialog({
    String? title,
    String? content,
    String? mood,
    List<String>? tags,
    String? dialogTitle,
  }) async {
    final contentController = TextEditingController(text: content);
    final titleController = TextEditingController(text: title);
    final selectedTags = List<String>.from(tags ?? []);
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
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tags',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButton<String>(
                            value: null,
                            hint: Text(
                              selectedTags.isEmpty
                                  ? 'Selecione as tags'
                                  : selectedTags.map((t) => '#$t').join(', '),
                            ),
                            isExpanded: true,
                            underline: SizedBox(),
                            items:
                                _availableTags
                                    .where((tag) => !selectedTags.contains(tag))
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
                                  selectedTags.add(value);
                                });
                              }
                            },
                          ),
                        ),
                        if (selectedTags.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children:
                                selectedTags
                                    .map(
                                      (tag) => Chip(
                                        label: Text('#$tag'),
                                        onDeleted:
                                            () => setState(
                                              () => selectedTags.remove(tag),
                                            ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    )
                                    .toList(),
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
                          'tags': selectedTags,
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
        _entries.insert(
          0,
          DiaryEntry(
            id: _uuid.v4(),
            title: result['title'].isEmpty ? null : result['title'],
            content: result['content'],
            dateTime: DateTime.now(),
            mood: result['mood'],
            tags: result['tags'] as List<String>,
          ),
        );
        // Ensure entries are sorted by date
        _entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      });
    }
  }

  void _editEntry(DiaryEntry entry) async {
    final result = await _showEntryDialog(
      title: entry.title,
      content: entry.content,
      mood: entry.mood,
      tags: entry.tags,
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
            tags: result['tags'] as List<String>,
            isFavorite: _favorites[entry.id] ?? false,
          );
        }
      });
    }
  }

  void _deleteEntry(String id) {
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
      _favorites.remove(id);
    });
  }

  void _toggleFavorite(String id, bool value) {
    setState(() {
      _favorites[id] = value;
    });
  }

  List<DiaryEntry> _getFilteredEntries() {
    if (_currentView == 'favorites') {
      return _entries.where((entry) => _favorites[entry.id] ?? false).toList();
    }
    return _entries;
  }

  Widget _buildCurrentView() {
    final filteredEntries = _getFilteredEntries();

    switch (_currentView) {
      case 'mood':
        return MoodView(
          entries: filteredEntries,
          onTap: _editEntry,
          onDelete: _deleteEntry,
          cardLayout: _cardLayout,
          onToggleFavorite: _toggleFavorite,
          favorites: _favorites,
        );
      case 'tags':
        return TagView(
          entries: filteredEntries,
          onTap: _editEntry,
          onDelete: _deleteEntry,
          cardLayout: _cardLayout,
          onToggleFavorite: _toggleFavorite,
          favorites: _favorites,
        );
      default:
        return TemporalView(
          entries: filteredEntries,
          onTap: _editEntry,
          onDelete: _deleteEntry,
          viewType:
              _currentView == 'favorites'
                  ? DiaryViewType.daily
                  : DiaryViewType.monthly,
          cardLayout: _cardLayout,
          onToggleFavorite: _toggleFavorite,
          favorites: _favorites,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Diário'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'view_standard',
                    child: Row(
                      children: [
                        Icon(Icons.view_agenda),
                        SizedBox(width: 8),
                        Text('Visualização Completa'),
                        Spacer(),
                        if (_cardLayout == DiaryCardLayout.standard)
                          Icon(Icons.check, size: 20),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'view_clean',
                    child: Row(
                      children: [
                        Icon(Icons.view_stream),
                        SizedBox(width: 8),
                        Text('Visualização Simples'),
                        Spacer(),
                        if (_cardLayout == DiaryCardLayout.clean)
                          Icon(Icons.check, size: 20),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'view_timeline',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text('Por Data'),
                        Spacer(),
                        if (_currentView == 'timeline')
                          Icon(Icons.check, size: 20),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'view_favorites',
                    child: Row(
                      children: [
                        Icon(Icons.star),
                        SizedBox(width: 8),
                        Text('Favoritos'),
                        Spacer(),
                        if (_currentView == 'favorites')
                          Icon(Icons.check, size: 20),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'view_mood',
                    child: Row(
                      children: [
                        Icon(Icons.emoji_emotions),
                        SizedBox(width: 8),
                        Text('Por Humor'),
                        Spacer(),
                        if (_currentView == 'mood') Icon(Icons.check, size: 20),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'view_tags',
                    child: Row(
                      children: [
                        Icon(Icons.tag),
                        SizedBox(width: 8),
                        Text('Por Tags'),
                        Spacer(),
                        if (_currentView == 'tags') Icon(Icons.check, size: 20),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'view_clean':
                    _cardLayout = DiaryCardLayout.clean;
                    break;
                  case 'view_standard':
                    _cardLayout = DiaryCardLayout.standard;
                    break;
                  case 'view_timeline':
                    _currentView = 'timeline';
                    break;
                  case 'view_favorites':
                    _currentView = 'favorites';
                    break;
                  case 'view_mood':
                    _currentView = 'mood';
                    break;
                  case 'view_tags':
                    _currentView = 'tags';
                    break;
                }
              });
            },
          ),
        ],
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
