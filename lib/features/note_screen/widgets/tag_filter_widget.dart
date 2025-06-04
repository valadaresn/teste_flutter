import 'package:flutter/material.dart';
import '../notes_controller.dart';

class TagFilterWidget extends StatelessWidget {
  final NotesController controller;

  const TagFilterWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Filtrar por tags:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              if (controller
                  .selectedFilterTags
                  .isNotEmpty) // ✅ MUDANÇA: Só tags, não busca
                TextButton.icon(
                  onPressed:
                      controller
                          .clearTagFilters, // ✅ MUDANÇA: Método específico
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Limpar'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  controller.suggestedTags.map((tag) {
                    final isSelected = controller.selectedFilterTags.contains(
                      tag,
                    );
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
                        onSelected: (_) => controller.toggleFilterTag(tag),
                        backgroundColor: tagColor.withOpacity(0.1),
                        selectedColor: tagColor,
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color:
                              isSelected ? tagColor : tagColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          if (controller.hasActiveFilters) ...[
            const SizedBox(height: 4),
            Text(
              '${controller.notes.length} nota(s) encontrada(s)', // ✅ Inclui resultados de busca + filtros
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
