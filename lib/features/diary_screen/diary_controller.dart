import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/diary_entry.dart';
import 'firebase_diary_repository.dart';

/// 🎯 Controller seguindo instruções críticas do docs/instrucoes_lista.txt:
/// - NUNCA implementar Repository como ChangeNotifier
/// - SEMPRE usar StreamSubscription no Controller
/// - Controller deve se inscrever ao Stream do Repository no construtor
class DiaryController extends ChangeNotifier {
  final FirebaseDiaryRepository _repository = FirebaseDiaryRepository();
  StreamSubscription<List<DiaryEntry>>? _entriesSubscription;

  List<DiaryEntry> _entries = [];
  bool _isLoading = true;
  String? _error;

  // Filtros
  DateTime? _selectedDate;
  String? _selectedMood;
  String? _searchQuery;
  bool _showOnlyFavorites = false;

  // Seleção de entry
  String? _selectedDiaryId;

  /// 📋 Getters para o estado atual
  List<DiaryEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedMood => _selectedMood;
  String? get searchQuery => _searchQuery;
  bool get showOnlyFavorites => _showOnlyFavorites;
  String? get selectedDiaryId => _selectedDiaryId;

  /// 📅 Getter para entradas filtradas
  List<DiaryEntry> get filteredEntries => _getFilteredEntries();

  /// 🔧 Construtor - Se inscreve no Stream do Repository
  DiaryController() {
    _initializeStream();
  }

  /// 🌊 Inicializa a subscrição ao Stream do Repository
  void _initializeStream() {
    _entriesSubscription = _repository.getEntriesStream().listen(
      (entries) {
        _entries = entries;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// 🔍 Buscar entrada específica por ID (necessário para GenericSelectorList)
  DiaryEntry? getDiaryEntryById(String id) {
    try {
      return _entries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 📋 Lista filtrada para GenericSelectorList
  List<DiaryEntry> getFilteredEntries() {
    return _getFilteredEntries();
  }

  /// 🔍 Lógica privada de filtros
  List<DiaryEntry> _getFilteredEntries() {
    List<DiaryEntry> filtered = List.from(_entries);

    // Filtro por data
    if (_selectedDate != null) {
      final startOfDay = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );
      final endOfDay = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        23,
        59,
        59,
      );

      filtered =
          filtered.where((entry) {
            final isInRange =
                entry.dateTime.isAfter(startOfDay) &&
                entry.dateTime.isBefore(
                  endOfDay.add(Duration(milliseconds: 1)),
                );

            return isInRange;
          }).toList();
    }

    // Filtro por humor
    if (_selectedMood != null && _selectedMood!.isNotEmpty) {
      filtered =
          filtered.where((entry) => entry.mood == _selectedMood).toList();
    }

    // Filtro por busca textual
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      filtered =
          filtered.where((entry) {
            return entry.content.toLowerCase().contains(query) ||
                (entry.title?.toLowerCase().contains(query) ?? false) ||
                entry.tags.any((tag) => tag.toLowerCase().contains(query));
          }).toList();
    }

    // Filtro por favoritos
    if (_showOnlyFavorites) {
      filtered = filtered.where((entry) => entry.isFavorite).toList();
    }

    return filtered;
  }

  /// 📅 Definir filtro de data
  void setDateFilter(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// 😊 Definir filtro de humor
  void setMoodFilter(String? mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  /// 🔍 Definir filtro de busca
  void setSearchQuery(String? query) {
    _searchQuery = query?.trim();
    notifyListeners();
  }

  /// ⭐ Alternar filtro de favoritos
  void toggleFavoritesFilter() {
    _showOnlyFavorites = !_showOnlyFavorites;
    notifyListeners();
  }

  /// 🧹 Limpar todos os filtros
  void clearFilters() {
    _selectedDate = null;
    _selectedMood = null;
    _searchQuery = null;
    _showOnlyFavorites = false;
    notifyListeners();
  }

  /// ➕ Adicionar nova entrada
  Future<void> addEntry(DiaryEntry entry) async {
    try {
      await _repository.addEntry(entry);
      // O Stream já vai atualizar automaticamente
    } catch (e) {
      _error = 'Erro ao adicionar entrada: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// ✏️ Atualizar entrada existente
  Future<void> updateEntry(DiaryEntry entry) async {
    try {
      await _repository.updateEntry(entry);
      // O Stream já vai atualizar automaticamente
    } catch (e) {
      _error = 'Erro ao atualizar entrada: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 🗑️ Deletar entrada
  Future<void> deleteEntry(String entryId) async {
    try {
      await _repository.deleteEntry(entryId);
      // O Stream já vai atualizar automaticamente
    } catch (e) {
      _error = 'Erro ao deletar entrada: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// ⭐ Alternar favorito
  Future<void> toggleFavorite(String entryId, bool isFavorite) async {
    try {
      await _repository.toggleFavorite(entryId, isFavorite);
      // O Stream já vai atualizar automaticamente
    } catch (e) {
      _error = 'Erro ao alterar favorito: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 🎯 Selecionar diary entry
  void selectDiaryEntry(String? entryId) {
    _selectedDiaryId = entryId;
    notifyListeners();
  }

  /// 🧹 Dispose - Cancela o StreamSubscription
  @override
  void dispose() {
    _entriesSubscription?.cancel();
    super.dispose();
  }
}
