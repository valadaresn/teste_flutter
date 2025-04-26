import 'package:flutter/material.dart';
import '../../../models/diary_entry.dart';
import './diary_view_base.dart';
import '../widgets/diary_card.dart';
import '../widgets/expandable_group.dart';

class MoodView extends DiaryViewBase {
  const MoodView({
    super.key,
    required super.entries,
    required super.onTap,
    required super.onDelete,
  });

  Map<String, List<DiaryEntry>> _groupByMood() {
    final groups = <String, List<DiaryEntry>>{};
    
    for (final entry in entries) {
      if (entry.mood != null) {
        groups.putIfAbsent(entry.mood!, () => []).add(entry);
      }
    }
    
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedEntries = _groupByMood();
    
    if (groupedEntries.isEmpty) {
      return const Center(
        child: Text('Nenhuma entrada com humor definido'),
      );
    }

    // Ordena os humores por quantidade de entradas
    final sortedMoods = groupedEntries.keys.toList()
      ..sort((a, b) => groupedEntries[b]!.length.compareTo(groupedEntries[a]!.length));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedMoods.length,
      itemBuilder: (context, index) {
        final mood = sortedMoods[index];
        final moodEntries = groupedEntries[mood]!;
        
        // Ordena as entradas por data mais recente
        moodEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));

        return ExpandableGroup(
          title: mood,
          count: '(${moodEntries.length})',
          // O humor com mais entradas começa expandido
          initiallyExpanded: index == 0,
          children: moodEntries.map((entry) => 
            Dismissible(
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
              ),
            ),
          ).toList(),
        );
      },
    );
  }
}
