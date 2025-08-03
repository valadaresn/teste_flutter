import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../../models/diary_entry.dart';
import 'views/temporal_view.dart';
import 'views/mood_view.dart';
import 'views/tag_view.dart';
import 'diary_view_type.dart';
import 'widgets/diary_card.dart';

/// Controller unificado para gerenciamento do diário e acesso ao Firestore
/// Otimizado para evitar reconstrução desnecessária da lista
class DiaryController extends ChangeNotifier {
  // Firebase
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'entradas_diario';
  final _uuid = Uuid();
  StreamSubscription? _firestoreSubscription;

  // Estado
  bool _isLoading = false;
  String? _error;
  List<DiaryEntry> _entries = [];
  final Map<String, bool> _favorites = {};

  // Stream controller para UI
  final _entriesStreamController =
      StreamController<List<DiaryEntry>>.broadcast();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DiaryEntry> get entries => _entries;
  Map<String, bool> get favorites => _favorites;
  Stream<List<DiaryEntry>> get entriesStream => _entriesStreamController.stream;

  // Acesso à coleção para FirestoreListView
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(_collectionPath);

  // Lista de opções fixas
  final List<String> moodOptions = ['😊', '😐', '😢', '😡', '🤔', '😴'];
  final List<String> availableTags = [
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

  DiaryController({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    // Habilitar persistência offline
    _enableOfflinePersistence();
    // Iniciar stream de dados
    _subscribeToFirestore();
  }

  // CONFIGURAÇÃO FIRESTORE

  Future<void> _enableOfflinePersistence() async {
    try {
      await _firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
      _log('Persistência offline habilitada');
    } catch (e) {
      _log('Persistência já habilitada ou erro: $e');
    }
  }

  void _subscribeToFirestore() {
    _firestoreSubscription?.cancel();

    _log('Iniciando stream do Firestore');
    _firestoreSubscription = _firestore
        .collection(_collectionPath)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            // SOLUÇÃO: Processar apenas documentos modificados em vez de recriar tudo
            bool hasStructuralChange = false;

            for (var change in snapshot.docChanges) {
              final docId = change.doc.id;

              switch (change.type) {
                case DocumentChangeType.added:
                  _log('Documento adicionado: $docId');
                  final newEntry = _documentToEntry(change.doc);
                  // Adiciona à lista existente em vez de recriar a lista
                  _entries.add(newEntry);
                  if (newEntry.isFavorite) {
                    _favorites[newEntry.id] = true;
                  }
                  hasStructuralChange = true;
                  break;

                case DocumentChangeType.modified:
                  _log('Documento modificado: $docId');
                  final index = _entries.indexWhere((e) => e.id == docId);
                  if (index >= 0) {
                    final updatedEntry = _documentToEntry(change.doc);
                    _entries[index] = updatedEntry;

                    // Atualiza favoritos sem reconstruir o mapa inteiro
                    if (updatedEntry.isFavorite) {
                      _favorites[docId] = true;
                    } else {
                      _favorites.remove(docId);
                    }

                    // NÃO notifica para modificações individuais
                    // Os StreamBuilders individuais irão atualizar somente os cards afetados
                  }
                  break;

                case DocumentChangeType.removed:
                  _log('Documento removido: $docId');
                  _entries.removeWhere((e) => e.id == docId);
                  _favorites.remove(docId);
                  hasStructuralChange = true;
                  break;
              }
            }

            // Só notifica se houve mudança estrutural na lista (adição/remoção)
            if (hasStructuralChange) {
              _log('Notificando listeners - mudança estrutural');
              notifyListeners();
            }

            // Sempre envia para o stream (para atualizar widgets individuais)
            _entriesStreamController.add(_entries);
          },
          onError: (error) {
            _log('Erro no stream: $error');
            _setError('Erro ao receber atualizações');
          },
        );
  }

  // UTILITÁRIOS INTERNOS

  // Este método agora só é usado para inicialização completa
  void _updateLocalState(List<DiaryEntry> entries) {
    _entries = entries;
    _favorites.clear();
    for (var entry in entries) {
      if (entry.isFavorite) {
        _favorites[entry.id] = true;
      }
    }
    notifyListeners();
  }

  DiaryEntry _documentToEntry(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final mapData = Map<String, dynamic>.from(data);

    if (data['dateTime'] is Timestamp) {
      mapData['dateTime'] =
          (data['dateTime'] as Timestamp).toDate().toIso8601String();
    }

    return DiaryEntry.fromMap(mapData, doc.id);
  }

  Map<String, dynamic> _toFirestoreMap(DiaryEntry entry) {
    final map = entry.toMap();
    if (map['dateTime'] is String) {
      map['dateTime'] = Timestamp.fromDate(entry.dateTime);
    }
    return map;
  }

  void _log(String message) {
    debugPrint('[DIARY] $message');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMsg) {
    _error = errorMsg;
    notifyListeners();
  }

  // MÉTODOS PÚBLICOS CRUD

  /// Carrega todas as entradas do diário
  Future<void> loadEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _log("Carregando entradas...");
      if (_entries.isEmpty) {
        final snapshot =
            await _firestore
                .collection(_collectionPath)
                .orderBy('dateTime', descending: true)
                .get();

        final entries = snapshot.docs.map(_documentToEntry).toList();
        _updateLocalState(entries);
      }
      _log("${_entries.length} entradas carregadas");
    } catch (e) {
      _error = e.toString();
      _log("Erro ao carregar entradas: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona uma nova entrada ao diário
  Future<bool> addEntry(Map<String, dynamic> data) async {
    _setLoading(true);

    try {
      final id = _uuid.v4();
      final entry = DiaryEntry.fromFormData(data, id);

      _log("Adicionando entrada...");
      await _firestore
          .collection(_collectionPath)
          .doc(entry.id)
          .set(_toFirestoreMap(entry));

      _log("Entrada adicionada com sucesso");
      return true;
    } catch (e) {
      _log("Erro ao adicionar entrada: $e");
      _setError('Erro ao adicionar entrada');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza uma entrada existente
  Future<bool> updateEntry(DiaryEntry entry, Map<String, dynamic> data) async {
    _setLoading(true);

    try {
      // 🔥 DEBUG: LOG DETALHADO DO QUE ESTÁ SENDO ATUALIZADO
      debugPrint('🔄 DiaryController.updateEntry()');
      debugPrint('📝 Entrada original: ${entry.content}');
      debugPrint('🎭 Mood original: ${entry.mood}');
      debugPrint('⭐ Favorito original: ${entry.isFavorite}');
      debugPrint('📊 Dados recebidos: $data');

      // Usar factory para atualização
      final updatedEntry = DiaryEntry.updateFromForm(entry, data);

      debugPrint('📝 Entrada atualizada: ${updatedEntry.content}');
      debugPrint('🎭 Mood atualizado: ${updatedEntry.mood}');
      debugPrint('⭐ Favorito atualizado: ${updatedEntry.isFavorite}');

      _log("Atualizando entrada no Firebase...");
      await _firestore
          .collection(_collectionPath)
          .doc(entry.id)
          .update(_toFirestoreMap(updatedEntry));

      // 🔥 ATUALIZAR ESTADO LOCAL
      final index = _entries.indexWhere((e) => e.id == entry.id);
      debugPrint('📍 Índice na lista: $index');
      debugPrint('📋 Total de entradas antes: ${_entries.length}');

      if (index != -1) {
        final oldEntry = _entries[index];
        debugPrint('🔄 Substituindo entrada no índice $index');
        debugPrint('   Anterior: ${oldEntry.content} (${oldEntry.mood})');

        _entries[index] = updatedEntry;

        debugPrint(
          '   Nova: ${_entries[index].content} (${_entries[index].mood})',
        );

        // Atualizar favoritos se necessário
        if (data.containsKey('isFavorite')) {
          _favorites[entry.id] = data['isFavorite'] as bool;
          debugPrint('💝 Favorito atualizado: ${_favorites[entry.id]}');
        }

        // Notificar mudanças
        debugPrint('🔔 Notificando listeners...');
        notifyListeners();
        debugPrint('🌊 Adicionando ao stream...');
        _entriesStreamController.add(_entries);
        debugPrint('✅ Estado local atualizado com sucesso!');
      } else {
        debugPrint('❌ ERRO: Entrada não encontrada na lista local!');
      }

      _log("Entrada atualizada com sucesso");
      return true;
    } catch (e) {
      debugPrint('❌ ERRO no updateEntry: $e');
      _log("Erro ao atualizar entrada: $e");
      _setError('Erro ao atualizar entrada');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deleta uma entrada
  Future<bool> deleteEntry(String id) async {
    _setLoading(true);

    try {
      _log("Deletando entrada...");
      await _firestore.collection(_collectionPath).doc(id).delete();
      _log("Entrada deletada com sucesso");
      return true;
    } catch (e) {
      _log("Erro ao deletar entrada: $e");
      _setError('Erro ao deletar entrada');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Busca entradas de diário específicas para uma tarefa
  Future<List<DiaryEntry>> getEntriesForTask(String taskId) async {
    try {
      _log("Buscando entradas para tarefa: $taskId");

      // Solução temporária: carregar todas as entradas e filtrar localmente
      // Isso evita problemas de índice no Firestore durante desenvolvimento
      final snapshot = await _firestore.collection(_collectionPath).get();

      var allEntries = snapshot.docs.map(_documentToEntry).toList();

      // Filtrar localmente por taskId
      var entries =
          allEntries.where((entry) => entry.taskId == taskId).toList();

      // Ordenar localmente por data (mais recente primeiro)
      entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      _log(
        "${entries.length} entradas encontradas para a tarefa (de ${allEntries.length} total)",
      );
      return entries;
    } catch (e) {
      _log("Erro ao buscar entradas da tarefa: $e");
      return [];
    }
  }

  /// Adiciona uma entrada de diário diretamente (para uso em task panels)
  Future<bool> addDiaryEntry(DiaryEntry entry) async {
    try {
      _log("Adicionando entrada de diário...");
      await _firestore
          .collection(_collectionPath)
          .doc(entry.id)
          .set(entry.toMap());

      _log("Entrada de diário adicionada com sucesso");
      return true;
    } catch (e) {
      _log("Erro ao adicionar entrada de diário: $e");
      return false;
    }
  }

  /// Alterna status de favorito
  Future<bool> toggleFavorite(String id, bool value) async {
    try {
      _log("Atualizando favorito...");
      await _firestore.collection(_collectionPath).doc(id).update({
        'isFavorite': value,
      });
      _log("Favorito atualizado com sucesso");
      return true;
    } catch (e) {
      _log("Erro ao atualizar favorito: $e");
      return false;
    }
  }

  // MÉTODOS DE VISUALIZAÇÃO

  /// Filtra entradas baseado na visualização atual
  List<DiaryEntry> getFilteredEntries(String currentView) {
    if (currentView == 'favorites') {
      return _entries.where((entry) => _favorites[entry.id] ?? false).toList();
    }
    return _entries;
  }

  /// Constrói a visualização baseada no tipo selecionado
  Widget buildView({
    required String currentView,
    required Function(DiaryEntry) onTap,
    required DiaryCardLayout cardLayout,
  }) {
    final filteredEntries = getFilteredEntries(currentView);

    switch (currentView) {
      case 'mood':
        return MoodView(
          entries: filteredEntries,
          onTap: onTap,
          onDelete: deleteEntry,
          cardLayout: cardLayout,
          onToggleFavorite: toggleFavorite,
          favorites: _favorites,
        );
      case 'tags':
        return TagView(
          entries: filteredEntries,
          onTap: onTap,
          onDelete: deleteEntry,
          cardLayout: cardLayout,
          onToggleFavorite: toggleFavorite,
          favorites: _favorites,
        );
      default:
        return TemporalView(
          entries: filteredEntries,
          onTap: onTap,
          onDelete: deleteEntry,
          viewType:
              currentView == 'favorites'
                  ? DiaryViewType.daily
                  : DiaryViewType.monthly,
          cardLayout: cardLayout,
          onToggleFavorite: toggleFavorite,
          favorites: _favorites,
        );
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    _entriesStreamController.close();
    super.dispose();
  }
}
