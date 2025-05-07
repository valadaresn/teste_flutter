import 'package:collection/collection.dart';
import '../models/diary_entry.dart';

class DiaryEntriesManager {
  final Map<String, DiaryEntry> _entriesMap = {};
  final Map<String, bool> _favorites = {};
  final Map<String, List<DiaryEntry>> _entriesByDate = {};
  final Map<String, List<DiaryEntry>> _entriesByMood = {};
  final Map<String, List<DiaryEntry>> _entriesByTag = {};
  List<DiaryEntry>? _sortedEntries;
  List<DiaryEntry>? _favoriteEntries;

  void addEntry(DiaryEntry entry) {
    _entriesMap[entry.id] = entry;
    _invalidateCache();
    _addToIndexes(entry);
  }

  void updateEntry(DiaryEntry entry) {
    final oldEntry = _entriesMap[entry.id];
    if (oldEntry != null) {
      _removeFromIndexes(oldEntry);
    }
    _entriesMap[entry.id] = entry;
    _addToIndexes(entry);
    _invalidateCache();
  }

  void deleteEntry(String id) {
    final entry = _entriesMap[id];
    if (entry != null) {
      _removeFromIndexes(entry);
    }
    _entriesMap.remove(id);
    _favorites.remove(id);
    _invalidateCache();
  }

  void toggleFavorite(String id, bool value) {
    _favorites[id] = value;
    _favoriteEntries = null;
  }

  bool isFavorite(String id) => _favorites[id] ?? false;

  List<DiaryEntry> getEntries({bool favoritesOnly = false}) {
    if (favoritesOnly) {
      _favoriteEntries ??= 
          _entriesMap.values.where((e) => _favorites[e.id] ?? false).toList()
            ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return _favoriteEntries!;
    }

    _sortedEntries ??= 
        _entriesMap.values.toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return _sortedEntries!;
  }

  List<DiaryEntry> getEntriesByDate(String date) {
    return _entriesByDate[date] ?? [];
  }

  List<DiaryEntry> getEntriesByMood(String mood) {
    return _entriesByMood[mood] ?? [];
  }

  List<DiaryEntry> getEntriesByTag(String tag) {
    return _entriesByTag[tag] ?? [];
  }

  void _invalidateCache() {
    _sortedEntries = null;
    _favoriteEntries = null;
  }

  void _addToIndexes(DiaryEntry entry) {
    // Indexar por data
    final dateKey = _formatDateKey(entry.dateTime);
    _entriesByDate.putIfAbsent(dateKey, () => []).add(entry);
    _entriesByDate[dateKey]!.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // Indexar por humor
    if (entry.mood != null) {
      _entriesByMood.putIfAbsent(entry.mood!, () => []).add(entry);
      _entriesByMood[entry.mood!]!.sort(
        (a, b) => b.dateTime.compareTo(a.dateTime),
      );
    }

    // Indexar por tags
    for (final tag in entry.tags) {
      _entriesByTag.putIfAbsent(tag, () => []).add(entry);
      _entriesByTag[tag]!.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }
  }

  void _removeFromIndexes(DiaryEntry entry) {
    // Remover de índice por data
    final dateKey = _formatDateKey(entry.dateTime);
    _entriesByDate[dateKey]?.remove(entry);
    if (_entriesByDate[dateKey]?.isEmpty ?? false) {
      _entriesByDate.remove(dateKey);
    }

    // Remover de índice por humor
    if (entry.mood != null) {
      _entriesByMood[entry.mood!]?.remove(entry);
      if (_entriesByMood[entry.mood!]?.isEmpty ?? false) {
        _entriesByMood.remove(entry.mood!);
      }
    }

    // Remover de índice por tags
    for (final tag in entry.tags) {
      _entriesByTag[tag]?.remove(entry);
      if (_entriesByTag[tag]?.isEmpty ?? false) {
        _entriesByTag.remove(tag);
      }
    }
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) {
      return 'Hoje';
    } else if (entryDate == yesterday) {
      return 'Ontem';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}
