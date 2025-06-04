import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:async';

import 'note_model.dart';

class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'notes';

  // Stream de todas as notas
  Stream<List<Note>> getNotesStream() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Note.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    });
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
