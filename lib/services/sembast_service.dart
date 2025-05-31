import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

/// Serviço genérico para armazenamento local usando Sembast
/// T é o tipo de objeto a ser armazenado
class SembastService<T> {
  final String storeName;
  final String databaseName;

  /// Função para converter um objeto T para Map<String, dynamic>
  final Map<String, dynamic> Function(T item) toMap;

  /// Função para criar um objeto T a partir de um Map<String, dynamic> e um ID
  final T Function(Map<String, dynamic> map, String id) fromMap;

  /// Store de objetos
  late final StoreRef<String, Map<String, dynamic>> _store;

  /// Database instance
  Database? _database;

  /// Construtor do serviço
  SembastService({
    required this.storeName,
    required this.toMap,
    required this.fromMap,
    this.databaseName = 'app.db',
  }) {
    _store = StoreRef<String, Map<String, dynamic>>(storeName);
  }

  /// Obtém a instância do banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;

    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, databaseName);

    _database = await databaseFactoryIo.openDatabase(dbPath);
    return _database!;
  }

  /// Obtém todos os itens
  Future<List<T>> getAllItems() async {
    try {
      final db = await database;
      final snapshots = await _store.find(db);

      return snapshots.map((snapshot) {
        return fromMap(snapshot.value, snapshot.key);
      }).toList();
    } catch (e) {
      debugPrint('Erro ao carregar itens do cache: $e');
      return [];
    }
  }

  /// Obtém um item pelo ID
  Future<T?> getItem(String id) async {
    try {
      final db = await database;
      final snapshot = await _store.record(id).get(db);

      if (snapshot == null) return null;
      return fromMap(snapshot, id);
    } catch (e) {
      debugPrint('Erro ao buscar item do cache: $e');
      return null;
    }
  }

  /// Adiciona ou atualiza um item
  Future<bool> saveItem(T item, String id) async {
    try {
      final db = await database;
      await _store.record(id).put(db, toMap(item));
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar item no cache: $e');
      return false;
    }
  }

  /// Adiciona ou atualiza vários itens
  Future<bool> saveItems(List<T> items, List<String> ids) async {
    try {
      if (items.length != ids.length) {
        throw ArgumentError(
          'As listas de itens e IDs devem ter o mesmo tamanho',
        );
      }

      final db = await database;

      await db.transaction((txn) async {
        for (var i = 0; i < items.length; i++) {
          await _store.record(ids[i]).put(txn, toMap(items[i]));
        }
      });

      return true;
    } catch (e) {
      debugPrint('Erro ao salvar itens em lote no cache: $e');
      return false;
    }
  }

  /// Remove um item pelo ID
  Future<bool> deleteItem(String id) async {
    try {
      final db = await database;
      await _store.record(id).delete(db);
      return true;
    } catch (e) {
      debugPrint('Erro ao remover item do cache: $e');
      return false;
    }
  }

  /// Remove vários itens pelos IDs
  Future<bool> deleteItems(List<String> ids) async {
    try {
      final db = await database;

      await db.transaction((txn) async {
        for (var id in ids) {
          await _store.record(id).delete(txn);
        }
      });

      return true;
    } catch (e) {
      debugPrint('Erro ao remover itens em lote do cache: $e');
      return false;
    }
  }

  /// Limpa todo o store
  Future<bool> clearStore() async {
    try {
      final db = await database;
      await _store.drop(db);
      return true;
    } catch (e) {
      debugPrint('Erro ao limpar cache: $e');
      return false;
    }
  }

  /// Salva um valor de metadados
  Future<bool> saveMetadata(String key, dynamic value) async {
    try {
      final db = await database;
      final metaStore = StoreRef.main();
      await metaStore.record('meta_${storeName}_$key').put(db, value);
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar metadados: $e');
      return false;
    }
  }

  /// Obtém um valor de metadados
  Future<T?> getMetadata<T>(String key) async {
    try {
      final db = await database;
      final metaStore = StoreRef.main();
      return await metaStore.record('meta_${storeName}_$key').get(db) as T?;
    } catch (e) {
      debugPrint('Erro ao obter metadados: $e');
      return null;
    }
  }

  /// Obtém a data da última sincronização
  Future<DateTime?> getLastSyncTime() async {
    final timeStr = await getMetadata<String>('last_sync');
    if (timeStr == null) return null;
    return DateTime.parse(timeStr);
  }

  /// Define a data da última sincronização
  Future<bool> setLastSyncTime(DateTime time) async {
    return await saveMetadata('last_sync', time.toIso8601String());
  }
}
