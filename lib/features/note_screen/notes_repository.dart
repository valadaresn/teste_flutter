import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:async';

import 'note_model.dart';

class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'notes';
  final String _settingsPath = 'notes_settings';

  // Stream de todas as notas
  Stream<List<Note>> getNotesStream() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Note.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    });
  }

  // Stream das configurações (tags personalizadas)
  Stream<Map<String, dynamic>?> getSettingsStream() {
    return _firestore
        .collection(_settingsPath)
        .doc('user_tags')
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return snapshot.data();
          }
          return null;
        });
  }

  // Salvar tags personalizadas
  Future<void> saveUserTags({
    required List<String> customTags,
    required Map<String, int>
    tagColors, // Salvamos como int para facilitar serialização
  }) async {
    await _firestore.collection(_settingsPath).doc('user_tags').set({
      'customTags': customTags,
      'tagColors': tagColors,
      'lastUpdate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // CRUD Operations
  Future<void> addNote(Note note) async {
    await _firestore.collection(_collectionPath).doc(note.id).set(note.toMap());
  }

  Future<void> updateNote(Note note) async {
    await _firestore
        .collection(_collectionPath)
        .doc(note.id)
        .update(note.toMap());
  }

  Future<void> deleteNote(String id) async {
    await _firestore.collection(_collectionPath).doc(id).delete();
  }

  Future<Note?> getNoteById(String id) async {
    final doc = await _firestore.collection(_collectionPath).doc(id).get();

    if (doc.exists) {
      return Note.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
