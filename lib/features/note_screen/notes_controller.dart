import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'note_model.dart';
import 'notes_repository.dart';

class NotesController extends ChangeNotifier {
  final NotesRepository _repository = NotesRepository();
  final _uuid = Uuid();
  StreamSubscription? _notesSubscription;

  // Estado da UI
  bool _isLoading = false;
  String? _error;
  List<Note> _notes = [];
  List<String> _selectedFilterTags = [];
  String _searchQuery = ''; // ✅ Texto de busca

  // Tags e cores (configuração da UI)
  final List<String> _suggestedTags = [
    'Importante',
    'Trabalho',
    'Pessoal',
    'Ideias',
    'Lembrete',
    'Compras',
  ];

  final Map<String, Color> _tagColors = {
    'Importante': Colors.red,
    'Trabalho': Colors.blue,
    'Pessoal': Colors.purple,
    'Ideias': Colors.green,
    'Lembrete': Colors.orange,
    'Compras': Colors.teal,
  };

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Note> get notes => _getFilteredAndSearchedNotes();
  List<String> get suggestedTags => _suggestedTags;
  List<String> get selectedFilterTags => _selectedFilterTags;
  String get searchQuery => _searchQuery;
  bool get hasActiveFilters =>
      _selectedFilterTags.isNotEmpty || _searchQuery.isNotEmpty;

  NotesController() {
    _subscribeToNotes();
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToNotes() {
    _setLoading(true);
    _setError(null);

    _notesSubscription = _repository.getNotesStream().listen(
      (notes) {
        _notes = notes;
        _setLoading(false);
        notifyListeners();
      },
      onError: (e) {
        _setError('Erro ao carregar notas: $e');
        _setLoading(false);
      },
    );
  }

  // ✅ MUDANÇA: Busca SOMENTE em título e conteúdo (removido tags)
  List<Note> _getFilteredAndSearchedNotes() {
    List<Note> filtered = _notes;

    // Aplicar filtro de tags
    if (_selectedFilterTags.isNotEmpty) {
      filtered =
          filtered.where((note) {
            return _selectedFilterTags.any(
              (filterTag) => note.tags.contains(filterTag),
            );
          }).toList();
    }

    // ✅ MUDANÇA: Busca de texto SOMENTE em título e conteúdo
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered.where((note) {
            return note.title.toLowerCase().contains(query) || // ✅ Título
                note.content.toLowerCase().contains(query); // ✅ Conteúdo
            // ❌ REMOVIDO: note.tags.any((tag) => tag.toLowerCase().contains(query));
          }).toList();
    }

    return filtered;
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  // Métodos de filtro por tags
  void toggleFilterTag(String tag) {
    if (_selectedFilterTags.contains(tag)) {
      _selectedFilterTags.remove(tag);
    } else {
      _selectedFilterTags.add(tag);
    }
    notifyListeners();
  }

  void clearTagFilters() {
    _selectedFilterTags.clear();
    notifyListeners();
  }

  // Métodos de busca
  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Limpa tudo (tags + busca)
  void clearAllFilters() {
    _selectedFilterTags.clear();
    _searchQuery = '';
    notifyListeners();
  }

  Color getTagColor(String tag) => _tagColors[tag] ?? Colors.grey;

  // Métodos que delegam para o Repository (sem _setLoading para não piscar)
  Future<bool> addNoteFromDialog(Map<String, dynamic> dialogData) async {
    try {
      final id = _uuid.v4();
      final note = Note.fromDialogData(dialogData, id);
      await _repository.addNote(note);
      return true;
    } catch (e) {
      _setError('Erro ao adicionar nota: $e');
      return false;
    }
  }

  Future<bool> updateNoteFromDialog(
    Note existingNote,
    Map<String, dynamic> dialogData,
  ) async {
    try {
      final updatedNote = Note.updateFromDialog(existingNote, dialogData);
      await _repository.updateNote(updatedNote);
      return true;
    } catch (e) {
      _setError('Erro ao atualizar nota: $e');
      return false;
    }
  }

  Future<bool> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      return true;
    } catch (e) {
      _setError('Erro ao excluir nota: $e');
      return false;
    }
  }

  // Helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMsg) {
    _error = errorMsg;
    notifyListeners();
  }
}
