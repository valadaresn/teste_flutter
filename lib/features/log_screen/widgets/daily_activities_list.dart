import 'package:flutter/material.dart';
import '../../../components/generic_selector_list.dart';
import '../controllers/log_controller.dart';
import '../log_model.dart';
import 'daily_activity_item.dart';

class DailyActivitiesList extends StatelessWidget {
  final LogController controller;
  final List<Log> logs;
  final Function(Log) onLogTap;
  final Function(Log) onEdit;
  final Function(Log) onDelete;

  const DailyActivitiesList({
    Key? key,
    required this.controller,
    required this.logs,
    required this.onLogTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Nenhuma atividade encontrada.')),
      );
    }

    return Expanded(
      child: GenericSelectorList<LogController, Log>(
        listSelector:
            (ctrl) => logs, // Usar a lista filtrada passada como parâmetro
        itemById: (ctrl, id) => ctrl.getLogById(id),
        idExtractor: (log) => log.id,
        itemBuilder: (context, log) {
          return DailyActivityItem(
            log: log,
            onTap: () => onLogTap(log),
            onEdit: () => onEdit(log),
            onDelete: () => onDelete(log),
          );
        },
        padding: const EdgeInsets.all(16),
        spacing: 8.0,
      ),
    );
  }
}
