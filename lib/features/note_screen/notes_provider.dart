import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notes_controller.dart';

/// Provider do NotesController
/// Cria uma instância única do controlador para toda a aplicação
final notesControllerProvider = ChangeNotifierProvider<NotesController>((ref) {
  // Cria a instância do controlador
  final controller = NotesController();

  // Quando o provider for descartado, limpa o controlador
  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});
