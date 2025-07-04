import 'package:flutter/material.dart';
import '../habit_controller.dart';

class HabitSearchWidget extends StatefulWidget {
  final HabitController controller;

  const HabitSearchWidget({Key? key, required this.controller})
    : super(key: key);

  @override
  State<HabitSearchWidget> createState() => _HabitSearchWidgetState();
}

class _HabitSearchWidgetState extends State<HabitSearchWidget> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.controller.searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar hábitos...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon:
                    widget.controller.searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            widget.controller.clearSearch();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[400]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => widget.controller.updateSearchQuery(value),
            ),
          ),
          if (widget.controller.hasActiveFilters) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                _searchController.clear();
                widget.controller.clearAllFilters();
              },
              icon: const Icon(Icons.filter_list_off, color: Colors.red),
              tooltip: 'Limpar todos os filtros',
            ),
          ],
        ],
      ),
    );
  }
}
