import 'package:flutter/material.dart';

/// **DateSelector** - Widget para seleção e navegação entre datas
///
/// Permite navegar entre dias com botões anterior/próximo e
/// seletor de data personalizado
class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateSelector({
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
    final isYesterday = _isSameDay(
      selectedDate,
      today.subtract(const Duration(days: 1)),
    );

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
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Dia anterior',
          ),

          // Data atual
          Expanded(
            child: InkWell(
              onTap: () => _showDatePicker(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        Text(
                          _getDateTitle(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getDateSubtitle(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botão próximo
          IconButton(
            onPressed: () => _navigateToDate(1),
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próximo dia',
          ),

          // Botão "Hoje" (se não estiver no dia atual)
          if (!isToday) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => onDateChanged(today),
              icon: const Icon(Icons.today, size: 18),
              label: const Text('Hoje'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Navega para uma data relativa (dias)
  void _navigateToDate(int dayOffset) {
    final newDate = selectedDate.add(Duration(days: dayOffset));
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

    if (picked != null && !_isSameDay(picked, selectedDate)) {
      onDateChanged(picked);
    }
  }

  /// Obtém o título da data
  String _getDateTitle() {
    final today = DateTime.now();

    if (_isSameDay(selectedDate, today)) {
      return 'Hoje';
    } else if (_isSameDay(
      selectedDate,
      today.subtract(const Duration(days: 1)),
    )) {
      return 'Ontem';
    } else if (_isSameDay(selectedDate, today.add(const Duration(days: 1)))) {
      return 'Amanhã';
    } else {
      return _formatDate(selectedDate);
    }
  }

  /// Obtém o subtítulo da data
  String _getDateSubtitle() {
    final today = DateTime.now();

    if (_isSameDay(selectedDate, today)) {
      return _formatDate(selectedDate);
    } else {
      return _formatWeekday(selectedDate);
    }
  }

  /// Formata a data para exibição
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _getMonthName(date.month);
    final year = date.year;

    return '$day de $month, $year';
  }

  /// Formata o dia da semana
  String _formatWeekday(DateTime date) {
    final weekdays = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];

    return weekdays[date.weekday - 1];
  }

  /// Obtém o nome do mês
  String _getMonthName(int month) {
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    return months[month - 1];
  }

  /// Verifica se duas datas são do mesmo dia
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
