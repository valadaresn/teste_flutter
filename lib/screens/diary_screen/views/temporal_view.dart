import 'package:flutter/material.dart';
import '../../../models/diary_entry.dart';
import './diary_view_base.dart';
import '../widgets/diary_card.dart';
import '../diary_view_type.dart';

class TemporalView extends DiaryViewBase {
  final DiaryViewType viewType;
  final DiaryCardLayout cardLayout;
  final Function(String, bool)? onToggleFavorite;
  final Map<String, bool> favorites;

  const TemporalView({
    super.key,
    required super.entries,
    required super.onTap,
    required super.onDelete,
    required this.viewType,
    this.cardLayout = DiaryCardLayout.standard,
    this.onToggleFavorite,
    this.favorites = const {},
  });

  Map<String, List<DiaryEntry>> _groupEntries() {
    final groups = <String, List<DiaryEntry>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final entry in entries) {
      String key;
      final entryDate = DateTime(
        entry.dateTime.year,
        entry.dateTime.month,
        entry.dateTime.day,
      );

      if (viewType == DiaryViewType.daily) {
        // Visualização diária
        if (entryDate.isAtSameMomentAs(today)) {
          key = 'Hoje';
        } else if (entryDate.isAtSameMomentAs(yesterday)) {
          key = 'Ontem';
        } else {
          key =
              '${entry.dateTime.day.toString().padLeft(2, '0')}/${entry.dateTime.month.toString().padLeft(2, '0')}/${entry.dateTime.year}';
        }
      } else {
        // Visualização mensal
        if (entry.dateTime.year == now.year &&
            entry.dateTime.month == now.month) {
          key = 'Este Mês';
        } else {
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
          key = '${months[entry.dateTime.month - 1]} ${entry.dateTime.year}';
        }
      }

      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(entry);
    }

    // Ordenar entradas dentro de cada grupo
    for (var entries in groups.values) {
      entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedEntries = _groupEntries();

    if (groupedEntries.isEmpty) {
      return const Center(child: Text('Nenhuma entrada encontrada'));
    }

    final sortedKeys =
        groupedEntries.keys.toList()..sort((a, b) {
          // Função auxiliar para obter o valor numérico da data do grupo
          int getDateValue(String key) {
            if (key == 'Hoje') return 99999999;
            if (key == 'Ontem') return 99999998;
            if (key == 'Este Mês') return 99999997;

            // Para outros meses, extrai o mês e ano
            final months = {
              'Janeiro': 1,
              'Fevereiro': 2,
              'Março': 3,
              'Abril': 4,
              'Maio': 5,
              'Junho': 6,
              'Julho': 7,
              'Agosto': 8,
              'Setembro': 9,
              'Outubro': 10,
              'Novembro': 11,
              'Dezembro': 12,
            };

            for (var month in months.keys) {
              if (key.contains(month)) {
                final year = int.parse(key.split(' ').last);
                return year * 12 + months[month]!;
              }
            }

            // Para datas no formato dd/mm/yyyy
            if (key.contains('/')) {
              final parts = key.split('/');
              final year = int.parse(parts[2]);
              final month = int.parse(parts[1]);
              final day = int.parse(parts[0]);
              return year * 10000 + month * 100 + day;
            }

            return 0;
          }

          return getDateValue(b).compareTo(getDateValue(a));
        });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final period = sortedKeys[index];
        final periodEntries = groupedEntries[period]!;

        periodEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));

        return ExpansionTile(
          key: PageStorageKey(period),
          title: Row(
            children: [
              Text(period, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8),
              Text(
                '(${periodEntries.length})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          subtitle: null,
          initiallyExpanded:
              period.contains('Hoje') ||
              period.contains('Ontem') ||
              period == 'Este Mês',
          children:
              periodEntries
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
