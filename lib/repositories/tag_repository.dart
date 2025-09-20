import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tag.dart';

class TagRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'tags';

  // Stream de todas as tags
  Stream<List<Tag>> getTags() {
    return _firestore.collection(_collection).orderBy('name').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => Tag.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Buscar tag por ID
  Future<Tag?> getTagById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Tag.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar tag: $e');
      return null;
    }
  }

  // Buscar tag por nome
  Future<Tag?> getTagByName(String name) async {
    try {
      final query =
          await _firestore
              .collection(_collection)
              .where('name', isEqualTo: name)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return Tag.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar tag por nome: $e');
      return null;
    }
  }

  // Criar nova tag
  Future<String?> createTag(Tag tag) async {
    try {
      // Verificar se já existe uma tag com este nome
      final existingTag = await getTagByName(tag.name);
      if (existingTag != null) {
        throw Exception('Já existe uma tag com este nome');
      }

      final docRef = await _firestore.collection(_collection).add(tag.toMap());
      return docRef.id;
    } catch (e) {
      print('Erro ao criar tag: $e');
      return null;
    }
  }

  // Atualizar tag existente
  Future<bool> updateTag(Tag tag) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(tag.id)
          .update(tag.updateTimestamp().toMap());
      return true;
    } catch (e) {
      print('Erro ao atualizar tag: $e');
      return false;
    }
  }

  // Deletar tag
  Future<bool> deleteTag(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Erro ao deletar tag: $e');
      return false;
    }
  }

  // Buscar tags por lista de IDs
  Future<List<Tag>> getTagsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      final chunks = <List<String>>[];
      for (int i = 0; i < ids.length; i += 10) {
        chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
      }

      final List<Tag> allTags = [];
      for (final chunk in chunks) {
        final query =
            await _firestore
                .collection(_collection)
                .where(FieldPath.documentId, whereIn: chunk)
                .get();

        allTags.addAll(
          query.docs.map((doc) => Tag.fromMap(doc.data(), doc.id)).toList(),
        );
      }

      return allTags;
    } catch (e) {
      print('Erro ao buscar tags por IDs: $e');
      return [];
    }
  }

  // Buscar tags por nomes
  Future<List<Tag>> getTagsByNames(List<String> names) async {
    if (names.isEmpty) return [];

    try {
      final chunks = <List<String>>[];
      for (int i = 0; i < names.length; i += 10) {
        chunks.add(
          names.sublist(i, i + 10 > names.length ? names.length : i + 10),
        );
      }

      final List<Tag> allTags = [];
      for (final chunk in chunks) {
        final query =
            await _firestore
                .collection(_collection)
                .where('name', whereIn: chunk)
                .get();

        allTags.addAll(
          query.docs.map((doc) => Tag.fromMap(doc.data(), doc.id)).toList(),
        );
      }

      return allTags;
    } catch (e) {
      print('Erro ao buscar tags por nomes: $e');
      return [];
    }
  }
}
