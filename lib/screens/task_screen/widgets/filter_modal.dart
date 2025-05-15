import 'package:flutter/material.dart';
import '../../../models/task_filters.dart';

class FilterModal extends StatelessWidget {
  final TaskFilters filters;
  final Function(TaskFilters) onFiltersChanged;

  const FilterModal({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
  });

  void _selectCustomDate(BuildContext context) async {
    // Obtém a data atual ou a data personalizada já definida
    final initialDate = filters.customDate ?? DateTime.now();
    final firstDate = DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final updatedFilters = TaskFilters(
        dateFilter: DateFilter.custom,
        showCompleted: filters.showCompleted,
        showPending: filters.showPending,
        customDate: selectedDate,
      );
      onFiltersChanged(updatedFilters);
    }
  }

  String _getCustomDateText() {
    if (filters.customDate != null) {
      // Formatação manual da data no formato dd/MM/yyyy
      final day = filters.customDate!.day.toString().padLeft(2, '0');
      final month = filters.customDate!.month.toString().padLeft(2, '0');
      final year = filters.customDate!.year.toString();

      return 'Data específica: $day/$month/$year';
    }
    return 'Data específica';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtrar Tarefas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Filtros de Data
          Text(
            'Data',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Opção: Todas
          RadioListTile<DateFilter>(
            title: const Text('Todas'),
            value: DateFilter.all,
            groupValue: filters.dateFilter,
            onChanged: (value) {
              if (value != null) {
                final updatedFilters = TaskFilters(
                  dateFilter: value,
                  showCompleted: filters.showCompleted,
                  showPending: filters.showPending,
                );
                onFiltersChanged(updatedFilters);
              }
            },
          ),

          // Opção: Hoje
          RadioListTile<DateFilter>(
            title: const Text('Hoje'),
            value: DateFilter.today,
            groupValue: filters.dateFilter,
            onChanged: (value) {
              if (value != null) {
                final updatedFilters = TaskFilters(
                  dateFilter: value,
                  showCompleted: filters.showCompleted,
                  showPending: filters.showPending,
                );
                onFiltersChanged(updatedFilters);
              }
            },
          ),

          // Opção: Amanhã
          RadioListTile<DateFilter>(
            title: const Text('Amanhã'),
            value: DateFilter.tomorrow,
            groupValue: filters.dateFilter,
            onChanged: (value) {
              if (value != null) {
                final updatedFilters = TaskFilters(
                  dateFilter: value,
                  showCompleted: filters.showCompleted,
                  showPending: filters.showPending,
                );
                onFiltersChanged(updatedFilters);
              }
            },
          ),

          // Opção: Data específica
          RadioListTile<DateFilter>(
            title: Row(
              children: [
                Text(_getCustomDateText()),
                const SizedBox(width: 8),
                Icon(
                  Icons.calendar_month,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            value: DateFilter.custom,
            groupValue: filters.dateFilter,
            onChanged: (value) {
              if (value != null) {
                _selectCustomDate(context);
              }
            },
          ),

          const Divider(),
          const SizedBox(height: 8),

          // Filtros de Status
          Text(
            'Status',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Opção: Concluídas
          CheckboxListTile(
            title: const Text('Concluídas'),
            value: filters.showCompleted,
            onChanged: (value) {
              if (value != null) {
                final updatedFilters = TaskFilters(
                  dateFilter: filters.dateFilter,
                  customDate: filters.customDate,
                  showCompleted: value,
                  showPending: filters.showPending,
                );
                onFiltersChanged(updatedFilters);
              }
            },
          ),

          // Opção: Pendentes
          CheckboxListTile(
            title: const Text('Pendentes'),
            value: filters.showPending,
            onChanged: (value) {
              if (value != null) {
                final updatedFilters = TaskFilters(
                  dateFilter: filters.dateFilter,
                  customDate: filters.customDate,
                  showCompleted: filters.showCompleted,
                  showPending: value,
                );
                onFiltersChanged(updatedFilters);
              }
            },
          ),

          const SizedBox(height: 16),

          // Botão de resetar filtros
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Resetar Filtros'),
              onPressed: () {
                final resetFilters = TaskFilters();
                onFiltersChanged(resetFilters);
              },
            ),
          ),
        ],
      ),
    );
  }
}
