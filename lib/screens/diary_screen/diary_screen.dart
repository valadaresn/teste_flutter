// lib/screens/diary_screen/diary_screen.dart

import 'package:flutter/material.dart';
import 'dart:math';

import '../../models/diary_entry.dart';
import 'widgets/diary_card.dart';
import 'widgets/diary_entry_dialog.dart';
import 'widgets/diary_menu_widget.dart';
import 'diary_view_type.dart';

/// Tela de Diário 100% local para testes (sem Firebase ou controller)
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  // Estado local - totalmente desconectado, com dados de exemplo
  final Map<String, DiaryEntry> _localEntries = {};
  List<String> _entryIds = [];

  // UI state
  DiaryCardLayout _cardLayout = DiaryCardLayout.standard;
  String _currentView = 'timeline';
  int _rebuildCount = 0;

  @override
  void initState() {
    super.initState();

    // Carregar dados de exemplo
    _loadSampleData();
  }

  void _loadSampleData() {
    // 5 entradas de exemplo
    final sampleEntries = [
      DiaryEntry(
        id: '1',
        title: 'Reunião de Projeto',
        content:
            'Hoje discutimos as novas funcionalidades para o app. Todos parecem animados com o progresso!',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        mood: '😊',
        tags: ['trabalho', 'projeto'],
        isFavorite: true,
      ),
      DiaryEntry(
        id: '2',
        title: 'Aula de Yoga',
        content:
            'A aula de hoje foi particularmente difícil, mas me senti muito bem depois.',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        mood: '😐',
        tags: ['saúde', 'pessoal'],
        isFavorite: false,
      ),
      DiaryEntry(
        id: '3',
        title: 'Bug Crítico',
        content:
            'Passei o dia inteiro tentando resolver um bug na função de login. Consegui no final do dia!',
        dateTime: DateTime.now().subtract(const Duration(days: 3)),
        mood: '😡',
        tags: ['trabalho', 'bugs'],
        isFavorite: false,
      ),
      DiaryEntry(
        id: '4',
        title: 'Almoço em Família',
        content:
            'Encontramos todos para almoçar. Foi muito bom ver todo mundo depois de tanto tempo.',
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
        mood: '😊',
        tags: ['família', 'pessoal'],
        isFavorite: true,
      ),
      DiaryEntry(
        id: '5',
        title: 'Ideias para Nova Funcionalidade',
        content:
            'Tive algumas ideias interessantes para adicionar ao app. Vou compartilhar na próxima reunião.',
        dateTime: DateTime.now().subtract(const Duration(days: 7)),
        mood: '🤔',
        tags: ['trabalho', 'ideias'],
        isFavorite: false,
      ),
    ];

    setState(() {
      for (var entry in sampleEntries) {
        _localEntries[entry.id] = entry;
      }
      _entryIds = sampleEntries.map((e) => e.id).toList();
    });
  }

  // Métodos puramente locais

  void _toggleFavoriteLocally(String id) {
    setState(() {
      _rebuildCount++;

      final entry = _localEntries[id]!;
      _localEntries[id] = DiaryEntry(
        id: entry.id,
        title: entry.title,
        content: entry.content,
        dateTime: entry.dateTime,
        mood: entry.mood,
        tags: entry.tags,
        isFavorite: !entry.isFavorite,
      );

      print('⭐ Favorito alterado para ${_localEntries[id]!.isFavorite}');
      print('🔄 Lista reconstruída $_rebuildCount vezes');

      _showSnack(
        _localEntries[id]!.isFavorite ? 'Favoritado!' : 'Desfavoritado!',
      );
    });
  }

  void _deleteLocally(String id) {
    setState(() {
      _rebuildCount++;
      _localEntries.remove(id);
      _entryIds.remove(id);

      print('🗑️ Item removido: $id');
      print('🔄 Lista reconstruída $_rebuildCount vezes');

      _showSnack('Entrada removida!');
    });
  }

  Future<void> _addEntryLocally() async {
    // Opções hardcoded para teste
    final moodOptions = ['😊', '😐', '😢', '😡', '🤔', '😴'];
    final availableTags = [
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

    final result = await DiaryEntryDialog.show(
      context: context,
      moodOptions: moodOptions,
      availableTags: availableTags,
    );

    if (result != null) {
      final id = Random().nextInt(10000).toString();

      final entry = DiaryEntry(
        id: id,
        title: result['title'] as String?,
        content: result['content'] as String,
        dateTime: DateTime.now(),
        mood: result['mood'] as String,
        tags: List<String>.from(result['tags'] as List),
        isFavorite: false,
      );

      setState(() {
        _rebuildCount++;
        _localEntries[id] = entry;
        _entryIds.insert(0, id); // Adiciona no início da lista

        print('➕ Nova entrada adicionada: $id');
        print('🔄 Lista reconstruída $_rebuildCount vezes');

        _showSnack('Entrada adicionada!');
      });
    }
  }

  Future<void> _editEntryLocally(DiaryEntry entry) async {
    // Opções hardcoded para teste
    final moodOptions = ['😊', '😐', '😢', '😡', '🤔', '😴'];
    final availableTags = [
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

    final updated = await DiaryEntryDialog.show(
      context: context,
      title: entry.title,
      content: entry.content,
      mood: entry.mood,
      tags: entry.tags,
      dialogTitle: 'Editar Entrada',
      moodOptions: moodOptions,
      availableTags: availableTags,
    );

    if (updated != null) {
      setState(() {
        _rebuildCount++;

        _localEntries[entry.id] = DiaryEntry(
          id: entry.id,
          title: updated['title'] as String?,
          content: updated['content'] as String,
          dateTime: entry.dateTime,
          mood: updated['mood'] as String,
          tags: List<String>.from(updated['tags'] as List),
          isFavorite: entry.isFavorite,
        );

        print('✏️ Entrada editada: ${entry.id}');
        print('🔄 Lista reconstruída $_rebuildCount vezes');

        _showSnack('Entrada atualizada!');
      });
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Widget para um card individual com contador de reconstruções
  Widget _buildIsolatedDiaryCard(String id) {
    return _IsolatedDiaryCard(
      key: ValueKey('isolated_card_$id'),
      entry: _localEntries[id]!,
      cardLayout: _cardLayout,
      onEdit: _editEntryLocally,
      onDelete: _deleteLocally,
      onToggleFavorite: _toggleFavoriteLocally,
    );
  }

  // Widget para um card normal (não isolado)
  Widget _buildStandardDiaryCard(String id) {
    final entry = _localEntries[id];
    if (entry == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      key: ValueKey('card_${id}_${_rebuildCount}'),
      padding: const EdgeInsets.only(bottom: 8),
      child: DiaryCard(
        entry: entry,
        onTap: () => _editEntryLocally(entry),
        onDelete: () => _deleteLocally(id),
        onToggleFavorite: () => _toggleFavoriteLocally(id),
        isFavorite: entry.isFavorite,
        layout: _cardLayout,
      ),
    );
  }

  // Constrói a lista de cards
  Widget _buildList({bool useIsolatedCards = false}) {
    if (_entryIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Seu diário está vazio.\nComece a registrar seus pensamentos!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addEntryLocally,
              child: const Text('Adicionar Primeira Entrada'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Contador de rebuilds
        Container(
          width: double.infinity,
          color: Colors.blue.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '🔄 Lista reconstruída: $_rebuildCount vezes | '
            'Modo: ${useIsolatedCards ? "Isolado" : "Regular"}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),

        // Switch para alternar entre cards isolados e não isolados
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Cards Isolados'),
            Switch(
              value: useIsolatedCards,
              onChanged: (value) {
                setState(() {
                  _useIsolatedCards = value;
                  _rebuildCount++;
                });
              },
            ),
          ],
        ),

        // Lista de cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _entryIds.length,
            itemBuilder: (context, i) {
              final id = _entryIds[i];
              return useIsolatedCards
                  ? _buildIsolatedDiaryCard(id)
                  : _buildStandardDiaryCard(id);
            },
          ),
        ),
      ],
    );
  }

  // Status de isolamento de cards
  bool _useIsolatedCards = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Diário (Teste Local)'),
        actions: [
          // Botão para forçar rebuild (teste)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Forçar rebuild',
            onPressed:
                () => setState(() {
                  _rebuildCount++;
                  print('🔃 Rebuild forçado: $_rebuildCount');
                }),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder:
                (_) => DiaryMenuWidget.buildMenuItems(
                  cardLayout: _cardLayout,
                  currentView: _currentView,
                ),
            onSelected: (v) {
              setState(() {
                DiaryMenuWidget.handleMenuSelection(
                  v,
                  onLayoutChanged: (l) => _cardLayout = l,
                  onViewChanged: (view) => _currentView = view,
                );
              });
            },
          ),
        ],
      ),
      body: _buildList(useIsolatedCards: _useIsolatedCards),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntryLocally,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Card de diário isolado que gerencia seu próprio estado
class _IsolatedDiaryCard extends StatefulWidget {
  final DiaryEntry entry;
  final DiaryCardLayout cardLayout;
  final Function(DiaryEntry) onEdit;
  final Function(String) onDelete;
  final Function(String) onToggleFavorite;

  const _IsolatedDiaryCard({
    required this.entry,
    required this.cardLayout,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
    Key? key,
  }) : super(key: key);

  @override
  State<_IsolatedDiaryCard> createState() => _IsolatedDiaryCardState();
}

class _IsolatedDiaryCardState extends State<_IsolatedDiaryCard> {
  int _rebuildCount = 0;
  late DiaryEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  @override
  void didUpdateWidget(covariant _IsolatedDiaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id ||
        oldWidget.entry.isFavorite != widget.entry.isFavorite ||
        oldWidget.entry.title != widget.entry.title ||
        oldWidget.entry.content != widget.entry.content) {
      _entry = widget.entry;
      _rebuildCount++;
    }
  }

  @override
  Widget build(BuildContext context) {
    _rebuildCount++;
    final cardColor =
        _rebuildCount % 2 == 0
            ? Colors.transparent
            : Colors.amber.withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          // Cor de fundo para mostrar quando o card reconstrói
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DiaryCard(
              entry: _entry,
              onTap: () => widget.onEdit(_entry),
              onDelete: () => widget.onDelete(_entry.id),
              onToggleFavorite: () => widget.onToggleFavorite(_entry.id),
              isFavorite: _entry.isFavorite,
              layout: widget.cardLayout,
            ),
          ),

          // Contador de reconstruções específico deste card
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#$_rebuildCount',
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
