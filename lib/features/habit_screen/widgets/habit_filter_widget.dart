import 'package:flutter/material.dart';
import '../habit_controller.dart';

class HabitFilterWidget extends StatelessWidget {
  final HabitController controller;

  const HabitFilterWidget({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filtros:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip('active', 'Ativos', Icons.play_circle),
                    _buildFilterChip('today', 'Hoje', Icons.today),
                  ],
                ),
              ),
              if (controller.hasActiveFilters) ...[
                IconButton(
                  icon: const Icon(Icons.clear_all, size: 20),
                  onPressed: controller.clearAllFilters,
                  tooltip: 'Limpar filtros',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String tag, String label, IconData icon) {
    final isSelected = controller.selectedFilterTags.contains(tag);

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            const Icon(Icons.check, size: 16, color: Colors.white),
            const SizedBox(width: 4),
          ] else ...[
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[200],
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        controller.toggleFilterTag(tag);

        // ✅ FEEDBACK: Mostrar snackbar quando filtro muda categoria
        if (tag == 'active' && selected) {
          _showFilterFeedback(label);
        }
      },
    );
  }

  void _showFilterFeedback(String filterName) {
    // Implementar feedback se necessário
  }
}
