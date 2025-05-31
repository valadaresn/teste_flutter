import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/diary_entry.dart';
import 'widgets/diary_entry_dialog.dart';

class DiaryScreenOptimized extends StatefulWidget {
  const DiaryScreenOptimized({Key? key}) : super(key: key);

  @override
  State<DiaryScreenOptimized> createState() => _DiaryScreenOptimizedState();
}

class _DiaryScreenOptimizedState extends State<DiaryScreenOptimized> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'entradas_diario';
  int _rebuildCount = 0;
  bool _isLoading = false;
  String? _error;

  // Lista de IDs de documentos - mantida estável
  List<String> _documentIds = [];
  bool _hasLoadedIds = false;

  @override
  void initState() {
    super.initState();
    // Carregar apenas os IDs uma vez
    _loadDocumentIds();
  }

  // Carrega apenas os IDs dos documentos uma vez
  Future<void> _loadDocumentIds() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot =
          await _firestore
              .collection(_collectionPath)
              .orderBy('dateTime', descending: true)
              .get();

      setState(() {
        _documentIds = snapshot.docs.map((doc) => doc.id).toList();
        _hasLoadedIds = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário Otimizado'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: Text(
              'Rebuilds: $_rebuildCount',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Forçar rebuild',
            onPressed:
                () => setState(() {
                  _rebuildCount++;
                  print('🔃 Rebuild forçado da tela principal: $_rebuildCount');
                }),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Erro: $_error'))
              : _buildCardList(),
    );
  }

  Widget _buildCardList() {
    if (!_hasLoadedIds) {
      return const Center(child: Text('Carregando IDs...'));
    }

    if (_documentIds.isEmpty) {
      return const Center(
        child: Text('Nenhuma entrada encontrada. Adicione pelo app principal.'),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.blue.withOpacity(0.1),
          child: const Text(
            'Cada card é isolado e atualiza independentemente.\n'
            'Clique em um item para editar seu conteúdo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ),

        // Lista estável, sem StreamBuilder aqui!
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _documentIds.length,
            itemBuilder: (context, index) {
              final id = _documentIds[index];
              final docRef = _firestore.collection(_collectionPath).doc(id);

              return _IsolatedEntryCard(
                key: ValueKey('card_$id'),
                documentRef: docRef,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _IsolatedEntryCard extends StatefulWidget {
  final DocumentReference documentRef;

  const _IsolatedEntryCard({required this.documentRef, Key? key})
    : super(key: key);

  @override
  State<_IsolatedEntryCard> createState() => _IsolatedEntryCardState();
}

class _IsolatedEntryCardState extends State<_IsolatedEntryCard> {
  int _rebuildCount = 0;
  bool _isUpdating = false;

  Future<void> _editEntry(DiaryEntry entry) async {
    if (_isUpdating) return;

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
      title: entry.title,
      content: entry.content,
      mood: entry.mood,
      tags: entry.tags,
      dialogTitle: 'Editar Entrada',
      moodOptions: moodOptions,
      availableTags: availableTags,
    );

    if (result == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final updates = {
        'title': result['title'],
        'content': result['content'],
        'mood': result['mood'],
        'tags': result['tags'],
      };

      await widget.documentRef.update(updates);

      setState(() {
        _isUpdating = false;
      });

      // Removido snackbar de sucesso para melhor visualizar que apenas o item atual muda
    } catch (e) {
      print('❌ Erro ao atualizar: $e');
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _rebuildCount++;

    // Cor fixa - sem mudanças visuais temporárias
    const cardColor = Colors.white;

    return StreamBuilder<DocumentSnapshot>(
      stream: widget.documentRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Card(
            margin: EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Erro: ${snapshot.error ?? "Documento não encontrado"}',
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return const SizedBox.shrink();

        final mapData = Map<String, dynamic>.from(data);
        if (data['dateTime'] is Timestamp) {
          mapData['dateTime'] =
              (data['dateTime'] as Timestamp).toDate().toIso8601String();
        }

        final entry = DiaryEntry.fromMap(mapData, snapshot.data!.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: cardColor,
          child: InkWell(
            onTap: () => _editEntry(entry),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title ?? 'Sem título',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${entry.dateTime.day}/${entry.dateTime.month}/${entry.dateTime.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.mood,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(entry.content),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children:
                            entry.tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                padding: EdgeInsets.zero,
                                labelStyle: const TextStyle(fontSize: 10),
                                visualDensity: VisualDensity.compact,
                              );
                            }).toList(),
                      ),
                      // Removido indicador de progresso para mostrar atualização sem efeitos visuais
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Rebuilds: $_rebuildCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
