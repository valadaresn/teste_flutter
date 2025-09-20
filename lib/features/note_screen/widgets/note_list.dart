import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notes_provider.dart';
import '../note_model.dart';
import 'note_card.dart';

class NotesList extends ConsumerWidget {
  final void Function(Note) onNoteTap;
  final String? selectedNoteId; // ✅ NOVO: ID da nota selecionada

  const NotesList({
    super.key,
    required this.onNoteTap,
    this.selectedNoteId, // ✅ NOVO: Opcional
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Um único watch externo (record): lista + flag de filtro.
    // Rebuilda só se notes OU hasActiveFilters mudarem.
    final data = ref.watch(
      notesControllerProvider.select(
        (c) => (notes: c.notes, hasFilters: c.hasActiveFilters),
      ),
    );

    // Função utilitária não precisa disparar rebuild.
    final getTagColor = ref.read(notesControllerProvider).getTagColor;

    if (data.notes.isEmpty) {
      return Center(
        child: Text(
          data.hasFilters
              ? 'Nenhuma nota encontrada com os filtros selecionados.'
              : 'Nenhuma nota encontrada. Adicione uma nota.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.notes.length,
      itemBuilder: (context, index) {
        final id = data.notes[index].id;

        // Rebuild fino por item:
        // este item só reconstrói se o resultado de getNoteById(id) mudar.
        final note = ref.watch(
          notesControllerProvider.select((c) => c.getNoteById(id)),
        );
        if (note == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: NoteCard(
            key: ValueKey(id),
            note: note,
            onTap: () => onNoteTap(note),
            getTagColor: getTagColor,
            hasActiveFilters: data.hasFilters,
            isSelected:
                note.id == selectedNoteId, // ✅ NOVO: Indica se está selecionado
          ),
        );
      },
    );
  }
}
