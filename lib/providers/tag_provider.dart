import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../repositories/tag_repository.dart';

// Provider do repositório de tags
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository();
});

// Provider do stream de tags
final tagsStreamProvider = StreamProvider<List<Tag>>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.getTags();
});

// Provider para gerenciar estado de tags selecionadas para filtro
final selectedTagsProvider =
    StateNotifierProvider<SelectedTagsNotifier, List<String>>((ref) {
      return SelectedTagsNotifier();
    });

class SelectedTagsNotifier extends StateNotifier<List<String>> {
  SelectedTagsNotifier() : super([]);

  void toggleTag(String tagName) {
    if (state.contains(tagName)) {
      state = state.where((tag) => tag != tagName).toList();
    } else {
      state = [...state, tagName];
    }
  }

  void selectOnlyTag(String tagName) {
    state = [tagName];
  }

  void clearSelection() {
    state = [];
  }

  void selectTags(List<String> tags) {
    state = [...tags];
  }
}

// Provider para cores padrão das tags
final tagColorsProvider = Provider<List<Color>>((ref) {
  return [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];
});

// Provider para obter tag por ID
final tagByIdProvider = FutureProvider.family<Tag?, String>((ref, id) async {
  final repository = ref.watch(tagRepositoryProvider);
  return await repository.getTagById(id);
});

// Provider para obter tags por nomes
final tagsByNamesProvider = FutureProvider.family<List<Tag>, List<String>>((
  ref,
  names,
) async {
  final repository = ref.watch(tagRepositoryProvider);
  return await repository.getTagsByNames(names);
});
