import 'package:flutter/material.dart';

/// Seletor de data simplificado para QuickAddTaskInput
class QuickDateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateChanged;

  const QuickDateSelector({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dateText = _formatSelectedDate();

    return GestureDetector(
      onTap: () => _showDateContextMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Colors.grey.shade500,
            ),
            if (selectedDate != null) ...[
              const SizedBox(width: 6),
              Text(
                dateText,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatSelectedDate() {
    if (selectedDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );
    final difference = taskDate.difference(today).inDays;

    // Datas próximas com contexto
    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Amanhã';
    } else if (difference > 1 && difference <= 7) {
      // Dias da semana para próximos 7 dias
      final weekdays = [
        '',
        'Segunda',
        'Terça',
        'Quarta',
        'Quinta',
        'Sexta',
        'Sábado',
        'Domingo',
      ];
      return weekdays[selectedDate!.weekday];
    } else {
      // Datas futuras/outras
      final months = [
        '',
        'jan',
        'fev',
        'mar',
        'abr',
        'mai',
        'jun',
        'jul',
        'ago',
        'set',
        'out',
        'nov',
        'dez',
      ];

      // Se for do mesmo ano, não mostrar o ano
      if (selectedDate!.year == now.year) {
        return '${selectedDate!.day} ${months[selectedDate!.month]}';
      } else {
        return '${selectedDate!.day} ${months[selectedDate!.month]} ${selectedDate!.year}';
      }
    }
  }

  void _showDateContextMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    final nextWeek = now.add(Duration(days: 7));

    // Função para obter abreviação do dia da semana
    String getDayAbbreviation(DateTime date) {
      const days = ['dom', 'seg', 'ter', 'qua', 'qui', 'sex', 'sáb'];
      return days[date.weekday % 7];
    }

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy - 200,
        position.dx + renderBox.size.width,
        position.dy,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      elevation: 8,
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'today',
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '${now.day}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hoje',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Text(
                getDayAbbreviation(now),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'tomorrow',
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '${tomorrow.day}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Amanhã',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Text(
                getDayAbbreviation(tomorrow),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'next_week',
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.keyboard_arrow_right,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Próxima semana',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Text(
                getDayAbbreviation(nextWeek),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'custom',
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.calendar_month,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Escolher uma data',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (selectedDate != null) ...[
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'remove',
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 12,
                    color: Colors.red.shade500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Remover data de conclusão',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ).then((value) => _handleDateSelection(context, value));
  }

  void _handleDateSelection(BuildContext context, String? value) {
    if (value == null) return;

    final now = DateTime.now();
    DateTime? newDate;

    switch (value) {
      case 'today':
        newDate = DateTime(now.year, now.month, now.day);
        break;
      case 'tomorrow':
        final tomorrow = now.add(const Duration(days: 1));
        newDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
        break;
      case 'next_week':
        final nextWeek = now.add(const Duration(days: 7));
        newDate = DateTime(nextWeek.year, nextWeek.month, nextWeek.day);
        break;
      case 'custom':
        _showCustomDatePicker(context);
        return;
      case 'remove':
        newDate = null;
        break;
    }

    onDateChanged(newDate);
  }

  void _showCustomDatePicker(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: this.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('pt', 'BR'),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (selectedDate != null) {
      onDateChanged(selectedDate);
    }
  }
}
