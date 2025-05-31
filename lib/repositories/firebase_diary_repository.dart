import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/diary_entry.dart';

/// Repositório responsável por gerenciar operações CRUD de entradas do diário no Firestore
class FirebaseDiaryRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'entradas_diario';

  // Estado
  bool _isLoading = false;
  String? _error;
  List<DiaryEntry> _entries = [];
  Map<String, bool> _favorites = {};

  // Stream controller para UI
  final _entriesStreamController =
      StreamController<List<DiaryEntry>>.broadcast();
  StreamSubscription? _firestoreSubscription;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DiaryEntry> get entries => _entries;
  Map<String, bool> get favorites => _favorites;
  Stream<List<DiaryEntry>> get entriesStream => _entriesStreamController.stream;

  // Acesso à coleção para FirestoreListView
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(_collectionPath);

  FirebaseDiaryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    // Habilitar persistência do Firebase (suporte offline nativo)
    _enableOfflinePersistence();

    // Iniciar o streaming de dados
    _subscribeToFirestore();
  }

  Future<void> _enableOfflinePersistence() async {
    try {
      await _firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
      debugPrint('Persistência offline do Firebase habilitada');
    } catch (e) {
      // Ignora erro se a persistência já estiver habilitada
      debugPrint('Persistência já habilitada ou erro: $e');
    }
  }

  void _subscribeToFirestore() {
    _firestoreSubscription?.cancel();

    debugPrint('Iniciando stream do Firestore');
    _firestoreSubscription = _firestore
        .collection(_collectionPath)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final entries = snapshot.docs.map(_documentToEntry).toList();
            _updateLocalState(entries);
            _entriesStreamController.add(entries);
            debugPrint('Stream atualizado: ${entries.length} entradas');
          },
          onError: (error) {
            debugPrint('Erro no stream do Firestore: $error');
            _setError('Erro ao receber atualizações');
          },
        );
  }

  void _updateLocalState(List<DiaryEntry> entries) {
    _entries = entries;
    _favorites = {
      for (var entry in entries)
        if (entry.isFavorite) entry.id: true,
    };
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMsg) {
    _error = errorMsg;
    notifyListeners();
  }

  // ===== Métodos públicos para o DiaryController =====

  Future<List<DiaryEntry>> getAllEntries() async {
    try {
      _setLoading(true);
      // Se ainda não temos dados, forçar uma consulta
      if (_entries.isEmpty) {
        final snapshot =
            await _firestore
                .collection(_collectionPath)
                .orderBy('dateTime', descending: true)
                .get();

        final entries = snapshot.docs.map(_documentToEntry).toList();
        _updateLocalState(entries);
      }
      return _entries;
    } catch (e) {
      debugPrint('Erro ao buscar entradas: $e');
      _setError('Erro ao buscar entradas');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<DiaryEntry?> getEntry(String id) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(id).get();
      return doc.exists ? _documentToEntry(doc) : null;
    } catch (e) {
      debugPrint('Erro ao buscar entrada: $e');
      return null;
    }
  }

  Future<bool> addEntry(DiaryEntry entry) async {
    try {
      _setLoading(true);
      await _firestore
          .collection(_collectionPath)
          .doc(entry.id)
          .set(_toFirestoreMap(entry));
      return true;
    } catch (e) {
      debugPrint('Erro ao adicionar entrada: $e');
      _setError('Erro ao adicionar entrada');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEntry(DiaryEntry entry) async {
    try {
      _setLoading(true);
      await _firestore
          .collection(_collectionPath)
          .doc(entry.id)
          .update(_toFirestoreMap(entry));
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar entrada: $e');
      _setError('Erro ao atualizar entrada');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateFavorite(String id, bool isFavorite) async {
    try {
      _setLoading(true);
      await _firestore.collection(_collectionPath).doc(id).update({
        'isFavorite': isFavorite,
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar favorito: $e');
      _setError('Erro ao atualizar favorito');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteEntry(String id) async {
    try {
      _setLoading(true);
      await _firestore.collection(_collectionPath).doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Erro ao remover entrada: $e');
      _setError('Erro ao remover entrada');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    _entriesStreamController.close();
    super.dispose();
  }
}
