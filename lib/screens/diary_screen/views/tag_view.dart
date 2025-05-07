import 'package:flutter/material.dart';
import '../../../models/diary_entry.dart';
import './diary_view_base.dart';
import '../widgets/diary_card.dart';
import '../widgets/expandable_group.dart';

class TagView extends DiaryViewBase {
  final DiaryCardLayout cardLayout;
  final Function(String, bool)? onToggleFavorite;
  final Map<String, bool> favorites;

  const TagView({
    super.key,
    required super.entries,
    required super.onTap,
    required super.onDelete,
    required this.cardLayout,
    this.onToggleFavorite,
    this.favorites = const {},
  });

  Map<String, List<DiaryEntry>> _groupByTags() {
    final groups = <String, List<DiaryEntry>>{};

    for (final entry in entries) {
      for (final tag in entry.tags) {
        groups.putIfAbsent(tag, () => []).add(entry);
      }
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedEntries = _groupByTags();

    if (groupedEntries.isEmpty) {
      return const Center(child: Text('Nenhuma entrada com tags'));
    }

    final sortedTags =
        groupedEntries.keys.toList()..sort(
          (a, b) =>
              groupedEntries[b]!.length.compareTo(groupedEntries[a]!.length),
        );

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedTags.length,
      itemBuilder: (context, index) {
        final tag = sortedTags[index];
        final tagEntries = groupedEntries[tag]!;

        tagEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));

        return ExpandableGroup(
          title: '#$tag',
          count: '(${tagEntries.length})',
          initiallyExpanded: index == 0,
          children:
              tagEntries
                  .map(
                    (entry) => Dismissible(
                      key: Key(entry.id),
                      onDismissed: (_) => onDelete(entry.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: DiaryCard(
                        entry: entry,
                        onTap: () => onTap(entry),
                        layout: cardLayout,
                        isFavorite: favorites[entry.id] ?? false,
                        onToggleFavorite:
                            onToggleFavorite != null
                                ? () => onToggleFavorite!(
                                  entry.id,
                                  !(favorites[entry.id] ?? false),
                                )
                                : null,
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}
