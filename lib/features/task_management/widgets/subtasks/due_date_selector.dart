import 'package:flutter/material.dart';
import '../../models/task_model.dart';

/// Seletor de data para o rodapé
class DueDateSelector extends StatefulWidget {
  final Task task;
  final Function(DateTime?) onDateChanged;

  const DueDateSelector({
    Key? key,
    required this.task,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  State<DueDateSelector> createState() => _DueDateSelectorState();
}

class _DueDateSelectorState extends State<DueDateSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dateText = TaskDateFormatter.formatTaskDate(widget.task);
    bool isOverdue =
        widget.task.dueDate != null &&
        !widget.task.isCompleted &&
        DateTime.now().isAfter(widget.task.dueDate!);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: () => _showDateContextMenu(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      _isHovered
                          ? (isOverdue
                              ? Colors.grey.shade100
                              : Colors.grey.shade100)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border:
                      _isHovered
                          ? Border.all(color: Colors.grey.shade300, width: 1)
                          : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color:
                          isOverdue
                              ? Colors.red.shade400
                              : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isOverdue
                                ? Colors.red.shade600
                                : Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDateContextMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

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
              Icon(Icons.today, size: 16, color: Colors.blue.shade500),
              const SizedBox(width: 8),
              const Text('Hoje'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'tomorrow',
          child: Row(
            children: [
              Icon(Icons.event, size: 16, color: Colors.green.shade500),
              const SizedBox(width: 8),
              const Text('Amanhã'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'next_week',
          child: Row(
            children: [
              Icon(Icons.date_range, size: 16, color: Colors.orange.shade500),
              const SizedBox(width: 8),
              const Text('Próxima semana'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'custom',
          child: Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 16,
                color: Colors.purple.shade500,
              ),
              const SizedBox(width: 8),
              const Text('Escolher data...'),
            ],
          ),
        ),
        if (widget.task.dueDate != null)
          PopupMenuItem<String>(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.clear, size: 16, color: Colors.red.shade500),
                const SizedBox(width: 8),
                Text(
                  'Remover prazo',
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ],
            ),
          ),
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

    widget.onDateChanged(newDate);
  }

  void _showCustomDatePicker(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.task.dueDate ?? DateTime.now(),
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
      widget.onDateChanged(selectedDate);
    }
  }
}

/// Classe utilitária para formatação de datas
class TaskDateFormatter {
  static String formatTaskDate(Task task) {
    if (task.dueDate == null) {
      return 'Sem prazo';
    }

    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = taskDate.difference(today).inDays;

    // Datas próximas com contexto
    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Amanhã';
    } else if (difference == -1) {
      return 'Ontem (atrasado)';
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
      return weekdays[dueDate.weekday];
    } else if (difference < -1) {
      // Tarefas atrasadas
      final daysDiff = difference.abs();
      if (daysDiff <= 7) {
        return '$daysDiff ${daysDiff == 1 ? 'dia' : 'dias'} atrasado';
      } else {
        return formatDateWithMonth(dueDate) + ' (atrasado)';
      }
    } else {
      // Datas futuras
      return formatDateWithMonth(dueDate);
    }
  }

  static String formatDateWithMonth(DateTime date) {
    final now = DateTime.now();
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
    if (date.year == now.year) {
      return '${date.day} de ${months[date.month]}';
    } else {
      return '${date.day} de ${months[date.month]}, ${date.year}';
    }
  }
}
