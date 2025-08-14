import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/diary_entry.dart';

/// 🔥 Repository simples SEM ChangeNotifier - previne piscar da tela
///
/// Seguindo instruções críticas do docs/instrucoes_lista.txt:
/// - Repository deve ser classe simples que retorna Stream
/// - NUNCA implementar como ChangeNotifier
class FirebaseDiaryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'entradas_diario';

  /// 🌊 Stream principal - fonte única da verdade
  /// Retorna Stream diretamente do Firestore
  Stream<List<DiaryEntry>> getEntriesStream() {
    debugPrint(
      '🔥 FirebaseDiaryRepository - Conectando à coleção: $_collection',
    );

    return _firestore
        .collection(_collection)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
          debugPrint(
            '📦 Firebase snapshot recebido: ${snapshot.docs.length} documentos',
          );

          final entries =
              snapshot.docs.map((doc) {
                final data = doc.data();
                debugPrint(
                  '📄 Doc ${doc.id}: ${data['title'] ?? 'Sem título'} - ${data['content']?.toString().substring(0, 30) ?? ''}...',
                );
                return DiaryEntry.fromMap(data, doc.id);
              }).toList();

          debugPrint('✅ Processadas ${entries.length} entradas do Firebase');
          return entries;
        });
  }

  /// 📝 Adicionar nova entrada
  Future<void> addEntry(DiaryEntry entry) async {
    await _firestore.collection(_collection).doc(entry.id).set(entry.toMap());
  }

  /// ✏️ Atualizar entrada existente
  Future<void> updateEntry(DiaryEntry entry) async {
    await _firestore
        .collection(_collection)
        .doc(entry.id)
        .update(entry.toMap());
  }

  /// 🗑️ Deletar entrada
  Future<void> deleteEntry(String entryId) async {
    await _firestore.collection(_collection).doc(entryId).delete();
  }

  /// ⭐ Toggle favorito (operação específica)
  Future<void> toggleFavorite(String entryId, bool isFavorite) async {
    await _firestore.collection(_collection).doc(entryId).update({
      'isFavorite': isFavorite,
    });
  }

  /// 📅 Buscar entradas por data específica
  Future<List<DiaryEntry>> getEntriesByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot =
        await _firestore
            .collection(_collection)
            .where(
              'dateTime',
              isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
            )
            .where('dateTime', isLessThanOrEqualTo: endOfDay.toIso8601String())
            .orderBy('dateTime', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      return DiaryEntry.fromMap(doc.data(), doc.id);
    }).toList();
  }

  /// 🔍 Buscar entrada específica por ID
  Future<DiaryEntry?> getEntryById(String entryId) async {
    final doc = await _firestore.collection(_collection).doc(entryId).get();

    if (doc.exists && doc.data() != null) {
      return DiaryEntry.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// 🏷️ Buscar entradas por tag
  Future<List<DiaryEntry>> getEntriesByTag(String tag) async {
    final snapshot =
        await _firestore
            .collection(_collection)
            .where('tags', arrayContains: tag)
            .orderBy('dateTime', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      return DiaryEntry.fromMap(doc.data(), doc.id);
    }).toList();
  }

  /// ⭐ Buscar apenas favoritas
  Future<List<DiaryEntry>> getFavoriteEntries() async {
    final snapshot =
        await _firestore
            .collection(_collection)
            .where('isFavorite', isEqualTo: true)
            .orderBy('dateTime', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      return DiaryEntry.fromMap(doc.data(), doc.id);
    }).toList();
  }
}
