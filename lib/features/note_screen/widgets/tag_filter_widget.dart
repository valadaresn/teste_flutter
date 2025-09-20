import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notes_provider.dart';

class TagFilterWidget extends ConsumerWidget {
  final Function(String)? onTagSelected; // ✅ NOVO: Callback para seleção de tag

  const TagFilterWidget({
    Key? key,
    this.onTagSelected, // ✅ NOVO: Parâmetro opcional
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(notesControllerProvider);
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 4,
        bottom: 8,
      ), // ✅ Top mínimo, bottom para respirar
      // ✅ REMOVIDO: Fundo cinza para interface mais limpa
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              controller.suggestedTags.map((tag) {
                final isSelected = controller.selectedFilterTags.contains(tag);
                final tagColor = controller.getTagColor(tag);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      controller.toggleFilterTag(tag);
                      // ✅ NOVO: Chama callback quando tag é selecionada
                      if (onTagSelected != null) {
                        onTagSelected!(tag);
                      }
                    },
                    backgroundColor: tagColor.withOpacity(0.1),
                    selectedColor: tagColor,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? tagColor : tagColor.withOpacity(0.3),
                      width: 1,
                    ),
                    // ✅ NOVO: Reduz padding interno dos chips
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
