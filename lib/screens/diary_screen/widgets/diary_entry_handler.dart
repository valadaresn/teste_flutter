// import 'package:flutter/material.dart';
// import '../../../models/diary_entry.dart';
// import '../../../repositories/firebase_diary_repository.dart';
// import 'diary_entry_dialog.dart';

// /// Handles all the operations related to diary entries
// class DiaryEntryHandler {
//   final FirebaseDiaryRepository repository;
//   final Function(String) logCallback;
//   final Function(bool) setLoadingCallback;
//   final Function() refreshCallback;

//   DiaryEntryHandler({
//     required this.repository,
//     required this.logCallback,
//     required this.setLoadingCallback,
//     required this.refreshCallback,
//   });

//   /// Shows dialog to add a new entry
//   Future<void> addEntry({
//     required BuildContext context,
//     required List<String> moodOptions,
//     required List<String> availableTags,
//     required String Function() generateId,
//   }) async {
//     final result = await DiaryEntryDialog.show(
//       context: context,
//       moodOptions: moodOptions,
//       availableTags: availableTags,
//     );

//     if (result != null) {
//       setLoadingCallback(true);
//       try {
//         // Criar objeto DiaryEntry diretamente usando o construtor do modelo
//         final entry = DiaryEntry(
//           id: generateId(),
//           title: result['title'].isEmpty ? null : result['title'],
//           content: result['content'],
//           dateTime: DateTime.now(),
//           mood: result['mood'],
//           tags: result['tags'] as List<String>,
//           isFavorite: false,
//         );

//         logCallback("Adicionando entrada ao Firebase...");
//         final success = await repository.addEntry(entry);
//         if (success) {
//           await refreshCallback();
//           logCallback("Entrada adicionada com sucesso!");
//         } else {
//           logCallback("Falha ao adicionar entrada");
//         }
//       } catch (e) {
//         logCallback("Erro ao adicionar entrada: $e");
//       } finally {
//         setLoadingCallback(false);
//       }
//     }
//   }

//   /// Shows dialog to edit an existing entry
//   Future<void> editEntry({
//     required BuildContext context,
//     required DiaryEntry entry,
//     required List<String> moodOptions,
//     required List<String> availableTags,
//   }) async {
//     final result = await DiaryEntryDialog.show(
//       context: context,
//       title: entry.title,
//       content: entry.content,
//       mood: entry.mood,
//       tags: entry.tags,
//       dialogTitle: 'Editar Entrada',
//       moodOptions: moodOptions,
//       availableTags: availableTags,
//     );

//     if (result != null) {
//       setLoadingCallback(true);
//       try {
//         // Usar o método copyWith do modelo DiaryEntry
//         final updatedEntry = entry.copyWith(
//           title: result['title'].isEmpty ? null : result['title'],
//           content: result['content'],
//           mood: result['mood'],
//           tags: result['tags'] as List<String>,
//         );

//         logCallback("Atualizando entrada no Firebase...");
//         final success = await repository.updateEntry(updatedEntry);
//         if (success) {
//           await refreshCallback();
//           logCallback("Entrada atualizada com sucesso!");
//         } else {
//           logCallback("Falha ao atualizar entrada");
//         }
//       } catch (e) {
//         logCallback("Erro ao atualizar entrada: $e");
//       } finally {
//         setLoadingCallback(false);
//       }
//     }
//   }

//   /// Deletes an entry
//   Future<void> deleteEntry(String id) async {
//     setLoadingCallback(true);

//     try {
//       logCallback("Deletando entrada do Firebase...");
//       final success = await repository.deleteEntry(id);
//       if (success) {
//         await refreshCallback();
//         logCallback("Entrada deletada com sucesso!");
//       } else {
//         logCallback("Falha ao deletar entrada");
//       }
//     } catch (e) {
//       logCallback("Erro ao deletar entrada: $e");
//     } finally {
//       setLoadingCallback(false);
//     }
//   }

//   /// Toggles favorite status of an entry
//   Future<void> toggleFavorite(String id, bool value) async {
//     try {
//       logCallback("Atualizando favorito no Firebase...");
//       final success = await repository.updateFavorite(id, value);
//       if (success) {
//         await refreshCallback();
//         logCallback("Favorito atualizado!");
//       } else {
//         logCallback("Falha ao atualizar favorito");
//       }
//     } catch (e) {
//       logCallback("Erro ao atualizar favorito: $e");
//     }
//   }
// }
