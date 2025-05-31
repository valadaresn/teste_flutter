import 'package:flutter/material.dart';
import '../../../models/diary_entry.dart';
import '../diary_view_type.dart';

/// A widget to display diary entries or a message when no entries exist
class DiaryContentWidget extends StatelessWidget {
  final List<DiaryEntry> entries;
  final Widget Function(List<DiaryEntry>) contentBuilder;
  final VoidCallback onAddFirstEntry;

  const DiaryContentWidget({
    super.key,
    required this.entries,
    required this.contentBuilder,
    required this.onAddFirstEntry,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Seu diário está vazio',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onAddFirstEntry,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar primeira entrada'),
            ),
          ],
        ),
      );
    }

    return contentBuilder(entries);
  }
}
