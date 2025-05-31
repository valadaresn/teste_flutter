import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

/// A generic service for storing and retrieving data using Sembast database
class SembastService<T> {
  final String dbPath;
  final String storeName;
  final Map<String, dynamic> Function(T item) toMap;
  final T Function(Map<String, dynamic>, String id) fromMap;

  Database? _database;
  final StoreRef<String, Map<String, dynamic>> _store;

  SembastService({
    required String dbName,
    required this.storeName,
    required this.toMap,
    required this.fromMap,
  }) : dbPath = dbName,
       _store = stringMapStoreFactory.store(storeName) {
    _openDatabase();
  }

  Future<void> _openDatabase() async {
    if (_database != null) return;

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocDir.path, this.dbPath);
      _database = await databaseFactoryIo.openDatabase(dbPath);
      debugPrint('Sembast database opened at $dbPath');
    } catch (e) {
      debugPrint('Error opening Sembast database: $e');
      rethrow;
    }
  }

  /// Add a single item to the store
  Future<bool> addItem(T item, String id) async {
    try {
      await _openDatabase();
      await _store.record(id).put(_database!, toMap(item));
      return true;
    } catch (e) {
      debugPrint('Error adding item to Sembast: $e');
      return false;
    }
  }

  /// Add multiple items to the store
  Future<bool> addItems(List<T> items, String Function(T item) idGetter) async {
    try {
      await _openDatabase();

      final batch = _database!.transaction((txn) async {
        for (final item in items) {
          final id = idGetter(item);
          await _store.record(id).put(txn, toMap(item));
        }
      });

      await batch;
      return true;
    } catch (e) {
      debugPrint('Error adding multiple items to Sembast: $e');
      return false;
    }
  }

  /// Update an item in the store
  Future<bool> updateItem(T item, String id) async {
    try {
      await _openDatabase();
      await _store.record(id).update(_database!, toMap(item));
      return true;
    } catch (e) {
      debugPrint('Error updating item in Sembast: $e');
      return false;
    }
  }

  /// Get an item from the store by id
  Future<T?> getItem(String id) async {
    try {
      await _openDatabase();
      final record = await _store.record(id).get(_database!);
      return record != null ? fromMap(record, id) : null;
    } catch (e) {
      debugPrint('Error getting item from Sembast: $e');
      return null;
    }
  }

  /// Get all items from the store
  Future<List<T>> getAllItems() async {
    try {
      await _openDatabase();
      final snapshots = await _store.find(_database!);
      return snapshots
          .map((snapshot) => fromMap(snapshot.value, snapshot.key))
          .toList();
    } catch (e) {
      debugPrint('Error getting all items from Sembast: $e');
      return [];
    }
  }

  /// Delete an item from the store by id
  Future<bool> deleteItem(String id) async {
    try {
      await _openDatabase();
      await _store.record(id).delete(_database!);
      return true;
    } catch (e) {
      debugPrint('Error deleting item from Sembast: $e');
      return false;
    }
  }

  /// Query items using a Finder
  Future<List<T>> query(Finder finder) async {
    try {
      await _openDatabase();
      final snapshots = await _store.find(_database!, finder: finder);
      return snapshots
          .map((snapshot) => fromMap(snapshot.value, snapshot.key))
          .toList();
    } catch (e) {
      debugPrint('Error querying items from Sembast: $e');
      return [];
    }
  }

  /// Watch for changes in the store
  Stream<List<T>> watchItems() {
    _openDatabase();
    return _store
        .query()
        .onSnapshots(_database!)
        .map(
          (snapshots) =>
              snapshots
                  .map((snapshot) => fromMap(snapshot.value, snapshot.key))
                  .toList(),
        );
  }

  /// Check if an item exists in the store
  Future<bool> exists(String id) async {
    try {
      await _openDatabase();
      final record = await _store.record(id).exists(_database!);
      return record;
    } catch (e) {
      debugPrint('Error checking if item exists in Sembast: $e');
      return false;
    }
  }

  /// Close the database
  Future<void> close() async {
    try {
      await _database?.close();
      _database = null;
      debugPrint('Sembast database closed');
    } catch (e) {
      debugPrint('Error closing Sembast database: $e');
    }
  }
}
