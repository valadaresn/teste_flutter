import 'package:flutter/material.dart';
import '../../../models/diary_entry.dart';
import 'diary_card.dart';

class DiaryList extends StatelessWidget {
  final List<DiaryEntry> entries;
  final Function(String)? onDelete;
  final Function(DiaryEntry)? onTap;

  const DiaryList({
    super.key,
    required this.entries,
    this.onDelete,
    this.onTap,
  });

  List<DiaryEntry> get _sortedEntries {
    final sorted = List<DiaryEntry>.from(entries);
    sorted.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return sorted;
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) {
      return 'Hoje';
    } else if (entryDate == yesterday) {
      return 'Ontem';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedEntries;
    String? currentDateHeader;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final entry = sorted[index];
        final dateHeader = _getDateHeader(entry.dateTime);
        final showHeader = dateHeader != currentDateHeader;
        currentDateHeader = dateHeader;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              if (index > 0) const SizedBox(height: 16),
              Text(
                dateHeader,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Dismissible(
              key: Key(entry.id),
              background: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => onDelete?.call(entry.id),
              child: DiaryCard(
                entry: entry,
                onTap: onTap != null ? () => onTap!(entry) : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
