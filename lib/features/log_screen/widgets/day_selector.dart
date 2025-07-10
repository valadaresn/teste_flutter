import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// **DaySelector** - Widget para seleção e navegação entre dias
///
/// Interface: [←] Hoje - 07 Jul 2025 [→] [📅]
class DaySelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DaySelector({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final today = DateTime.now();
    final isToday = _isSameDay(selectedDate, today);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Botão anterior
          IconButton(
            onPressed: () => _navigateToDate(-1),
            icon: Icon(Icons.chevron_left, color: colorScheme.primary),
            tooltip: 'Dia anterior',
          ),

          // Espaçador
          const SizedBox(width: 16),

          // Texto da data
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDateText(selectedDate, isToday),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Espaçador
          const SizedBox(width: 16),

          // Botão próximo
          IconButton(
            onPressed: () => _navigateToDate(1),
            icon: Icon(Icons.chevron_right, color: colorScheme.primary),
            tooltip: 'Próximo dia',
          ),

          // Botão "Hoje" (se não estiver no dia atual)
          if (!isToday) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => onDateChanged(today),
              child: Text(
                'Hoje',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Navega para o dia anterior/próximo
  void _navigateToDate(int dayOffset) {
    final newDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day + dayOffset,
    );
    onDateChanged(newDate);
  }

  /// Mostra o seletor de data
  void _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }

  /// Formata o texto da data
  String _formatDateText(DateTime date, bool isToday) {
    if (isToday) {
      return 'Hoje - ${DateFormat('dd MMM yyyy', 'pt_BR').format(date)}';
    }

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    if (_isSameDay(date, yesterday)) {
      return 'Ontem - ${DateFormat('dd MMM yyyy', 'pt_BR').format(date)}';
    } else if (_isSameDay(date, tomorrow)) {
      return 'Amanhã - ${DateFormat('dd MMM yyyy', 'pt_BR').format(date)}';
    } else {
      return DateFormat('dd MMM yyyy', 'pt_BR').format(date);
    }
  }

  /// Verifica se duas datas são do mesmo dia
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
