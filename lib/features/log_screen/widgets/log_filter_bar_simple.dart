import 'package:flutter/material.dart';
import '../log_model.dart';

class LogFilterBar extends StatelessWidget {
  final LogFilterPeriod selectedPeriod;
  final LogFilterStatus selectedStatus;
  final String searchQuery;
  final Function(LogFilterPeriod) onPeriodChanged;
  final Function(LogFilterStatus) onStatusChanged;
  final Function(String) onSearchChanged;
  final Function(DateTimeRange)? onDateRangeChanged;
  final VoidCallback? onClearFilters;

  const LogFilterBar({
    Key? key,
    required this.selectedPeriod,
    required this.selectedStatus,
    required this.searchQuery,
    required this.onPeriodChanged,
    required this.onStatusChanged,
    required this.onSearchChanged,
    this.onDateRangeChanged,
    this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          DropdownButton<LogFilterPeriod>(
            value: selectedPeriod,
            onChanged: (period) {
              if (period != null) onPeriodChanged(period);
            },
            items:
                LogFilterPeriod.values.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(period.toString()),
                  );
                }).toList(),
          ),
          SizedBox(width: 16),
          DropdownButton<LogFilterStatus>(
            value: selectedStatus,
            onChanged: (status) {
              if (status != null) onStatusChanged(status);
            },
            items:
                LogFilterStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString()),
                  );
                }).toList(),
          ),
          SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchChanged,
            ),
          ),
        ],
      ),
    );
  }
}
