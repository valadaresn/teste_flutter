import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/diary_entry.dart';

/// Repositório responsável por gerenciar operações CRUD de entradas do diário no Firestore.
class FirebaseDiaryRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'entradas_diario';

  // Construtor que permite injeção do Firestore para facilitar testes
  FirebaseDiaryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtém uma referência para a coleção de entradas do diário
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionPath);

  /// Converte um objeto DiaryEntry para um Map compatível com Firestore
  Map<String, dynamic> _entryToMap(DiaryEntry entry) {
    return {
      'title': entry.title,
      'content': entry.content,
      'dateTime': Timestamp.fromDate(entry.dateTime),
      'mood': entry.mood,
      'tags': entry.tags,
      'isFavorite': entry.isFavorite,
    };
  }

  /// Converte um documento do Firestore para um objeto DiaryEntry
  DiaryEntry _documentToEntry(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return DiaryEntry(
      id: doc.id,
      title: data['title'],
      content: data['content'] ?? '',
      dateTime:
          data['dateTime'] is Timestamp
              ? (data['dateTime'] as Timestamp).toDate()
              : DateTime.now(),
      mood: data['mood'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : <String>[],
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  /// Obtém todas as entradas de diário do Firestore
  Future<List<DiaryEntry>> getAllEntries() async {
    try {
      debugPrint('Buscando todas as entradas do diário...');
      final querySnapshot = await _collection.get();

      final entries =
          querySnapshot.docs.map((doc) => _documentToEntry(doc)).toList();

      debugPrint('Encontradas ${entries.length} entradas');
      return entries;
    } catch (e) {
      debugPrint('Erro ao buscar entradas: $e');
      return [];
    }
  }

  /// Obtém uma entrada específica pelo ID
  Future<DiaryEntry?> getEntry(String id) async {
    try {
      debugPrint('Buscando entrada com ID: $id');
      final docSnapshot = await _collection.doc(id).get();

      if (!docSnapshot.exists) {
        debugPrint('Entrada não encontrada');
        return null;
      }

      return _documentToEntry(docSnapshot);
    } catch (e) {
      debugPrint('Erro ao buscar entrada $id: $e');
      return null;
    }
  }

  /// Adiciona uma nova entrada ao Firestore
  Future<bool> addEntry(DiaryEntry entry) async {
    try {
      debugPrint('Adicionando entrada: ${entry.id}');
      await _collection.doc(entry.id).set(_entryToMap(entry));
      debugPrint('Entrada adicionada com sucesso');
      return true;
    } catch (e) {
      debugPrint('Erro ao adicionar entrada: $e');
      return false;
    }
  }

  /// Adiciona várias entradas ao Firestore em uma operação em lote
  Future<bool> addEntries(List<DiaryEntry> entries) async {
    try {
      debugPrint('Adicionando ${entries.length} entradas em lote');
      final batch = _firestore.batch();

      for (var entry in entries) {
        batch.set(_collection.doc(entry.id), _entryToMap(entry));
      }

      await batch.commit();
      debugPrint('Lote concluído com sucesso');
      return true;
    } catch (e) {
      debugPrint('Erro ao adicionar entradas em lote: $e');
      return false;
    }
  }

  /// Atualiza uma entrada existente no Firestore
  Future<bool> updateEntry(DiaryEntry entry) async {
    try {
      debugPrint('Atualizando entrada: ${entry.id}');
      await _collection.doc(entry.id).update(_entryToMap(entry));
      debugPrint('Entrada atualizada com sucesso');
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar entrada: $e');
      return false;
    }
  }

  /// Atualiza apenas o campo isFavorite de uma entrada
  Future<bool> updateFavorite(String id, bool isFavorite) async {
    try {
      debugPrint('Atualizando status favorito: $id -> $isFavorite');
      await _collection.doc(id).update({'isFavorite': isFavorite});
      debugPrint('Status favorito atualizado com sucesso');
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar status favorito: $e');
      return false;
    }
  }

  /// Remove uma entrada do Firestore
  Future<bool> deleteEntry(String id) async {
    try {
      debugPrint('Removendo entrada: $id');
      await _collection.doc(id).delete();
      debugPrint('Entrada removida com sucesso');
      return true;
    } catch (e) {
      debugPrint('Erro ao remover entrada: $e');
      return false;
    }
  }

  /// Configura um stream para ouvir mudanças em todas as entradas
  Stream<List<DiaryEntry>> entriesStream() {
    debugPrint('Iniciando stream de entradas do diário');
    return _collection.snapshots().map((snapshot) {
      final entries =
          snapshot.docs.map((doc) => _documentToEntry(doc)).toList();
      debugPrint('Stream atualizado: ${entries.length} entradas');
      return entries;
    });
  }

  /// Busca entradas com base em uma condição de filtro
  Future<List<DiaryEntry>> queryEntries({
    String? byMood,
    String? byTag,
    DateTime? fromDate,
    DateTime? toDate,
    bool? isFavorite,
    int? limit,
  }) async {
    try {
      debugPrint('Consultando entradas com filtros');
      Query<Map<String, dynamic>> query = _collection;

      // Aplicar filtros quando fornecidos
      if (byMood != null) {
        debugPrint('Filtro por humor: $byMood');
        query = query.where('mood', isEqualTo: byMood);
      }

      if (byTag != null) {
        debugPrint('Filtro por tag: $byTag');
        query = query.where('tags', arrayContains: byTag);
      }

      if (fromDate != null) {
        debugPrint('Filtro por data inicial: $fromDate');
        query = query.where(
          'dateTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
        );
      }

      if (toDate != null) {
        debugPrint('Filtro por data final: $toDate');
        query = query.where(
          'dateTime',
          isLessThanOrEqualTo: Timestamp.fromDate(toDate),
        );
      }

      if (isFavorite != null) {
        debugPrint('Filtro por favorito: $isFavorite');
        query = query.where('isFavorite', isEqualTo: isFavorite);
      }

      // Ordenação padrão por data mais recente
      query = query.orderBy('dateTime', descending: true);

      // Limitar resultados se especificado
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      final entries =
          querySnapshot.docs.map((doc) => _documentToEntry(doc)).toList();

      debugPrint('Consulta concluída: ${entries.length} entradas encontradas');
      return entries;
    } catch (e) {
      debugPrint('Erro ao consultar entradas: $e');
      return [];
    }
  }
}
