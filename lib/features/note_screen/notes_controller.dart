import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'note_model.dart';
import 'notes_repository.dart';
import '../../models/tag.dart';
import '../../repositories/tag_repository.dart';

class NotesController extends ChangeNotifier {
  final NotesRepository _repository = NotesRepository();
  final TagRepository _tagRepository = TagRepository();
  final _uuid = Uuid();
  StreamSubscription? _notesSubscription;
  StreamSubscription<List<Tag>>? _tagsSubscription;

  // Estado da UI
  bool _isLoading = false;
  String? _error;
  List<Note> _notes = [];
  List<String> _selectedFilterTags = [];
  String _searchQuery = ''; // ✅ Texto de busca
  List<Tag> _availableTags = []; // ✅ Tags carregadas do Firebase

  // Tags e cores (configuração da UI) - REMOVIDO: Agora usa o sistema de tags do Firebase

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Note> get notes => _getFilteredAndSearchedNotes();
  List<Tag> get availableTags => _availableTags;
  List<String> get suggestedTags =>
      _availableTags.map((tag) => tag.name).toList();
  List<String> get selectedFilterTags => _selectedFilterTags;
  String get searchQuery => _searchQuery;
  bool get hasActiveFilters =>
      _selectedFilterTags.isNotEmpty || _searchQuery.isNotEmpty;

  NotesController() {
    _subscribeToNotes();
    _subscribeToTags();
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    _tagsSubscription?.cancel();
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

  void _subscribeToTags() {
    _tagsSubscription = _tagRepository.getTags().listen(
      (tags) {
        _availableTags = tags;
        notifyListeners();
      },
      onError: (e) {
        print('Erro ao carregar tags: $e');
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
      // Se a tag já está selecionada, remove ela (desmarca)
      _selectedFilterTags.remove(tag);
    } else {
      // Seleção exclusiva: limpa todas as tags e adiciona apenas esta
      _selectedFilterTags.clear();
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

  Color getTagColor(String tagName) {
    try {
      final tag = _availableTags.firstWhere((tag) => tag.name == tagName);
      return tag.color;
    } catch (e) {
      return Colors.grey;
    }
  }

  // ============================================================================
  // MÉTODOS DE GERENCIAMENTO DE TAGS
  // ============================================================================

  /// Adiciona uma nova tag ao sistema
  Future<bool> addNewTag(String tagName, {Color? color}) async {
    if (tagName.trim().isEmpty) {
      return false;
    }

    // Verificar se já existe
    final existing = _availableTags.any((tag) => tag.name == tagName);
    if (existing) {
      return false;
    }

    final newTag = Tag.create(
      name: tagName.trim(),
      color: color ?? _generateNewColor(),
    );

    final id = await _tagRepository.createTag(newTag);
    return id != null;
  }

  /// Renomeia uma tag existente em todo o sistema
  Future<bool> renameTag(String oldTagName, String newTagName) async {
    if (oldTagName == newTagName || newTagName.trim().isEmpty) {
      return false;
    }

    try {
      // Encontrar a tag existente
      final oldTag = _availableTags.firstWhere((tag) => tag.name == oldTagName);

      // Verificar se o novo nome já existe
      final nameExists = _availableTags.any((tag) => tag.name == newTagName);
      if (nameExists) {
        return false;
      }

      // Atualizar a tag
      final updatedTag = oldTag.updateName(newTagName.trim());
      await _tagRepository.updateTag(updatedTag);

      // Atualizar filtros selecionados se necessário
      if (_selectedFilterTags.contains(oldTagName)) {
        _selectedFilterTags.remove(oldTagName);
        _selectedFilterTags.add(newTagName);
        notifyListeners();
      }

      // Atualizar todas as notas que usam essa tag
      await _updateTagInAllNotes(oldTagName, newTagName);

      return true;
    } catch (e) {
      print('Erro ao renomear tag: $e');
      return false;
    }
  }

  /// Remove uma tag do sistema
  Future<bool> deleteTag(String tagName) async {
    try {
      // Encontrar a tag
      final tag = _availableTags.firstWhere((tag) => tag.name == tagName);

      // Remover do filtro se estiver selecionada
      _selectedFilterTags.remove(tagName);

      // Remover a tag de todas as notas
      await _removeTagFromAllNotes(tagName);

      // Deletar a tag
      await _tagRepository.deleteTag(tag.id);

      notifyListeners();
      return true;
    } catch (e) {
      print('Erro ao deletar tag: $e');
      return false;
    }
  }

  /// Gera uma nova cor para tags personalizadas
  Color _generateNewColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    // Retorna uma cor que ainda não está sendo usada, ou uma aleatória
    final usedColors = _availableTags.map((tag) => tag.color).toSet();
    for (final color in colors) {
      if (!usedColors.contains(color)) {
        return color;
      }
    }

    return colors[_availableTags.length % colors.length];
  }

  /// Atualiza uma tag em todas as notas que a contêm
  Future<void> _updateTagInAllNotes(String oldTag, String newTag) async {
    for (final note in _notes) {
      if (note.tags.contains(oldTag)) {
        final updatedTags = List<String>.from(note.tags);
        final index = updatedTags.indexOf(oldTag);
        updatedTags[index] = newTag;

        final updatedNote = note.copyWith(tags: updatedTags);
        await _repository.updateNote(updatedNote);
      }
    }
  }

  /// Remove uma tag de todas as notas que a contêm
  Future<void> _removeTagFromAllNotes(String tag) async {
    for (final note in _notes) {
      if (note.tags.contains(tag)) {
        final updatedTags = List<String>.from(note.tags)..remove(tag);
        final updatedNote = note.copyWith(tags: updatedTags);
        await _repository.updateNote(updatedNote);
      }
    }
  }

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
