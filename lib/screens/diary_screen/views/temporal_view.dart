import 'package:flutter/material.dart';
import '../../../models/diary_entry.dart';
import './diary_view_base.dart';
import '../widgets/diary_card.dart';
import '../diary_view_type.dart';
import '../widgets/expandable_group.dart';

class TemporalView extends DiaryViewBase {
  final DiaryViewType viewType;

  const TemporalView({
    super.key,
    required super.entries,
    required super.onTap,
    required super.onDelete,
    required this.viewType,
  });

  Map<String, List<DiaryEntry>> _groupEntriesByMonth() {
    final groups = <String, List<DiaryEntry>>{};
    final now = DateTime.now();

    for (final entry in entries) {
      if (entry.dateTime.year == now.year &&
          entry.dateTime.month == now.month) {
        // Para o mês atual, agrupa por dia
        final dayKey =
            '${entry.dateTime.day.toString().padLeft(2, '0')}/${entry.dateTime.month.toString().padLeft(2, '0')}';
        groups.putIfAbsent(dayKey, () => []).add(entry);
      } else {
        // Para outros meses, agrupa por mês
        final months = [
          'Janeiro',
          'Fevereiro',
          'Março',
          'Abril',
          'Maio',
          'Junho',
          'Julho',
          'Agosto',
          'Setembro',
          'Outubro',
          'Novembro',
          'Dezembro',
        ];
        final monthKey =
            '${months[entry.dateTime.month - 1]} ${entry.dateTime.year}';
        groups.putIfAbsent(monthKey, () => []).add(entry);
      }
    }
    return groups;
  }

  Map<String, List<DiaryEntry>> _groupEntries() {
    final groups = <String, List<DiaryEntry>>{};
    final now = DateTime.now();

    for (final entry in entries) {
      String key;
      switch (viewType) {
        case DiaryViewType.daily:
          if (entry.dateTime.year == now.year &&
              entry.dateTime.month == now.month &&
              entry.dateTime.day == now.day) {
            key = 'Hoje';
          } else if (entry.dateTime.year == now.year &&
              entry.dateTime.month == now.month &&
              entry.dateTime.day == now.day - 1) {
            key = 'Ontem';
          } else {
            key =
                '${entry.dateTime.day.toString().padLeft(2, '0')}/'
                '${entry.dateTime.month.toString().padLeft(2, '0')}/'
                '${entry.dateTime.year}';
          }
          break;

        case DiaryViewType.weekly:
          // Calcula o início da semana (domingo)
          final firstDayOfWeek = now.subtract(Duration(days: now.weekday));
          final entryWeekStart = entry.dateTime.subtract(
            Duration(days: entry.dateTime.weekday),
          );

          if (entryWeekStart.isAtSameMomentAs(firstDayOfWeek)) {
            key = 'Esta Semana';
          } else if (entryWeekStart.isAtSameMomentAs(
            firstDayOfWeek.subtract(const Duration(days: 7)),
          )) {
            key = 'Semana Passada';
          } else {
            final weekNumber =
                (firstDayOfWeek.difference(entryWeekStart).inDays / 7).ceil();
            key = 'Há $weekNumber semanas';
          }
          break;

        case DiaryViewType.monthly:
          return _groupEntriesByMonth();

        case DiaryViewType.yearly:
          if (entry.dateTime.year == now.year) {
            key = 'Este Ano';
          } else {
            key = entry.dateTime.year.toString();
          }
          break;

        default:
          key = 'Sem Data';
      }

      groups.putIfAbsent(key, () => []).add(entry);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedEntries = _groupEntries();
    
    if (groupedEntries.isEmpty) {
      return const Center(
        child: Text('Nenhuma entrada encontrada'),
      );
    }

    // Ordena as chaves de acordo com a data mais recente
    final sortedKeys = groupedEntries.keys.toList()
      ..sort((a, b) {
        if (a.contains('Hoje')) return -1;
        if (b.contains('Hoje')) return 1;
        if (a.contains('Ontem')) return -1;
        if (b.contains('Ontem')) return 1;
        if (a.contains('Esta')) return -1;
        if (b.contains('Esta')) return 1;
        if (viewType == DiaryViewType.monthly && 
            a.contains('/') && b.contains('/')) {
          // Para dias do mês atual, ordena por dia
          return int.parse(b.split('/')[0]).compareTo(int.parse(a.split('/')[0]));
        }
        return b.compareTo(a); // ordem decrescente para outros casos
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final period = sortedKeys[index];
        final periodEntries = groupedEntries[period]!;
        
        // Ordena as entradas do período por data mais recente
        periodEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));

        return ExpandableGroup(
          title: period,
          count: '(${periodEntries.length})',
          // Períodos recentes começam expandidos
          initiallyExpanded: period.contains('Hoje') || 
                           period.contains('Ontem') || 
                           period.contains('Esta'),
          children: periodEntries.map((entry) => 
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
