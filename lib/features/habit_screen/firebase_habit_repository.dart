import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'habit_model.dart';

class FirebaseHabitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'habits';
  bool _debugMode = true;

  // Stream de todas as hábitos
  Stream<List<Habit>> getHabitsStream() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Habit.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  // Adicionar hábito
  Future<void> addHabit(Habit habit) async {
    if (_debugMode) print('🆕 Adicionando hábito: ${habit.title}');
    await _firestore
        .collection(_collectionPath)
        .doc(habit.id)
        .set(habit.toMap());
    if (_debugMode) print('✅ Hábito adicionado com sucesso');
  }

  // Atualizar hábito - agora direto no Firebase
  Future<void> updateHabit(Habit habit) async {
    if (_debugMode) print('� Atualizando hábito: ${habit.title}');
    await _firestore
        .collection(_collectionPath)
        .doc(habit.id)
        .update(habit.toMap());
    if (_debugMode) print('✅ Hábito atualizado com sucesso');
  }

  // Deletar hábito
  Future<void> deleteHabit(String id) async {
    if (_debugMode) print('�️ Deletando hábito: $id');
    await _firestore.collection(_collectionPath).doc(id).delete();
    if (_debugMode) print('✅ Hábito deletado com sucesso');
  }

  // Toggle ativo
  Future<void> toggleActive(String id, bool isActive) async {
    if (_debugMode) print('🔄 Alterando status ativo: $id -> $isActive');
    await _firestore.collection(_collectionPath).doc(id).update({
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    if (_debugMode) print('✅ Status alterado com sucesso');
  }

  // Update streak
  Future<void> updateStreak(String id, int newStreak) async {
    if (_debugMode) print('🔥 Atualizando streak: $id -> $newStreak');
    final doc = await _firestore.collection(_collectionPath).doc(id).get();
    if (doc.exists) {
      final habit = Habit.fromMap(doc.data()!, doc.id);
      final updatedHabit = habit.updateStreak(newStreak);
      await _firestore
          .collection(_collectionPath)
          .doc(id)
          .update(updatedHabit.toMap());
      if (_debugMode) print('✅ Streak atualizado com sucesso');
    }
  }

  // Get hábito por ID
  Future<Habit?> getHabitById(String id) async {
    if (_debugMode) print('🔍 Buscando hábito: $id');
    final doc = await _firestore.collection(_collectionPath).doc(id).get();
    if (doc.exists) {
      if (_debugMode) print('✅ Hábito encontrado');
      return Habit.fromMap(doc.data()!, doc.id);
    }
    if (_debugMode) print('❌ Hábito não encontrado');
    return null;
  }
}
