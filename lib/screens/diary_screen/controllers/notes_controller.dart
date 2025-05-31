import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../models/note.dart';

class NotesController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'notas';

  // Lista de tags sugeridas
  final List<String> suggestedTags = [
    'Trabalho',
    'Pessoal',
    'Saúde',
    'Finanças',
    'Ideias',
    'Importante',
    'Projeto',
    'Lembrete',
  ];

  // Mapa de cores para as tags sugeridas
  final Map<String, Color> tagColors = {
    'Trabalho': Colors.blue,
    'Pessoal': Colors.purple,
    'Saúde': Colors.green,
    'Finanças': Colors.amber.shade700,
    'Ideias': Colors.cyan,
    'Importante': Colors.red,
    'Projeto': Colors.indigo,
    'Lembrete': Colors.orange,
  };

  List<Note> _notes = [];
  bool isLoading = true;
  String? error;
  StreamSubscription? _subscription;

  List<Note> get notes => _notes;

  NotesController() {
    _loadNotes();
  }

  // Método para obter a cor de uma tag
  Color getTagColor(String tag) {
    return tagColors[tag] ??
        Colors.grey; // Cor padrão se a tag não tiver uma cor definida
  }

  Future<void> _loadNotes() async {
    isLoading = true;
    error = null;

    try {
      // Cancela qualquer subscription anterior
      await _subscription?.cancel();

      // Configura uma nova subscription usando o método recomendado
      _subscription = _firestore
          .collection(collectionPath)
          .orderBy('dateTime', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              // Este callback já é executado na thread principal
              _notes = snapshot.docs.map(_docToNote).toList();
              isLoading = false;
              notifyListeners();
            },
            onError: (e) {
              error = e.toString();
              isLoading = false;
              notifyListeners();
              debugPrint('Erro ao carregar notas: $e');
            },
          );
    } catch (e) {
      // Em caso de erro na configuração da subscription
      error = e.toString();
      isLoading = false;
      notifyListeners();
      debugPrint('Erro ao configurar stream: $e');
    }
  }

  Note _docToNote(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return Note(id: doc.id, title: '', content: '', dateTime: DateTime.now());
    }

    // Converte Timestamp para DateTime se necessário
    DateTime dateTime = DateTime.now();
    if (data['dateTime'] is Timestamp) {
      dateTime = (data['dateTime'] as Timestamp).toDate();
    } else if (data['dateTime'] is String) {
      try {
        dateTime = DateTime.parse(data['dateTime']);
      } catch (e) {
        debugPrint('Erro ao converter data: $e');
      }
    }

    // Tratamento seguro para tags
    List<String> tags = [];
    if (data['tags'] != null) {
      try {
        tags = List<String>.from(data['tags']);
      } catch (e) {
        debugPrint('Erro ao processar tags: $e');
      }
    }

    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      dateTime: dateTime,
      tags: tags,
    );
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addNote(String title, String content, List<String> tags) async {
    try {
      await _firestore.collection(collectionPath).add({
        'title': title,
        'content': content,
        'dateTime': DateTime.now().toIso8601String(),
        'tags': tags,
      });

      // Não precisamos recarregar - o listener já capturará a mudança
    } catch (e) {
      debugPrint('Erro ao adicionar nota: $e');
      rethrow;
    }
  }

  Future<void> updateNote(
    String id,
    String title,
    String content,
    List<String> tags,
  ) async {
    try {
      await _firestore.collection(collectionPath).doc(id).update({
        'title': title,
        'content': content,
        'dateTime': DateTime.now().toIso8601String(),
        'tags': tags,
      });

      // Não precisamos atualizar manualmente - o listener já capturará a mudança
    } catch (e) {
      debugPrint('Erro ao atualizar nota: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
