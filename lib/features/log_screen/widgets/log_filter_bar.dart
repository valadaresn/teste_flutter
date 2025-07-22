import 'package:flutter/material.dart';
import '../log_model.dart';

/// Widget para filtrar logs por período, status e busca
class LogFilterBar extends StatelessWidget {
  final LogFilterPeriod selectedPeriod;
  final LogFilterStatus selectedStatus;
  final String searchQuery;
  final ValueChanged<LogFilterPeriod> onPeriodChanged;
  final ValueChanged<LogFilterStatus> onStatusChanged;
  final ValueChanged<String> onSearchChanged;

  const LogFilterBar({
    Key? key,
    required this.selectedPeriod,
    required this.selectedStatus,
    required this.searchQuery,
    required this.onPeriodChanged,
    required this.onStatusChanged,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Barra de busca
          TextField(
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Buscar logs...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Filtros de período e status
          Row(
            children: [
              // Filtro de período
              Expanded(
                child: DropdownButtonFormField<LogFilterPeriod>(
                  value: selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Período',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      LogFilterPeriod.values.map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(_getPeriodLabel(period)),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onPeriodChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Filtro de status
              Expanded(
                child: DropdownButtonFormField<LogFilterStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      LogFilterStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(_getStatusLabel(status)),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onStatusChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(LogFilterPeriod period) {
    switch (period) {
      case LogFilterPeriod.today:
        return 'Hoje';
      case LogFilterPeriod.yesterday:
        return 'Ontem';
      case LogFilterPeriod.week:
        return 'Esta semana';
      case LogFilterPeriod.month:
        return 'Este mês';
      case LogFilterPeriod.custom:
        return 'Personalizado';
    }
  }

  String _getStatusLabel(LogFilterStatus status) {
    switch (status) {
      case LogFilterStatus.all:
        return 'Todos';
      case LogFilterStatus.active:
        return 'Ativo';
      case LogFilterStatus.completed:
        return 'Concluído';
    }
  }
}
