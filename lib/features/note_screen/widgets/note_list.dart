import 'package:flutter/material.dart';
import '../../../components/generic_selector_list.dart';
import '../notes_controller.dart';
import '../note_model.dart';
import 'note_card.dart';

class NotesList extends StatelessWidget {
  final NotesController controller;
  final Function(Note) onNoteTap;

  const NotesList({Key? key, required this.controller, required this.onNoteTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.notes.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            controller.hasActiveFilters
                ? 'Nenhuma nota encontrada com os filtros selecionados.' // ✅ Mensagem específica para filtros
                : 'Nenhuma nota encontrada. Adicione uma nota.',
          ),
        ),
      );
    }

    return Expanded(
      child: GenericSelectorList<NotesController, Note>(
        listSelector: (ctrl) => ctrl.notes,
        itemById: (ctrl, id) => ctrl.getNoteById(id),
        idExtractor: (note) => note.id,
        itemBuilder: (context, note) {
          return NoteCard(
            note: note,
            onTap: () => onNoteTap(note),
            getTagColor: controller.getTagColor,
            hasActiveFilters:
                controller.hasActiveFilters, // ✅ NOVO: Passa info do filtro
          );
        },
      ),
    );
  }
}
