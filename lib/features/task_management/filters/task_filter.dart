import '../models/task_model.dart';
import '../controllers/task_controller.dart';

/// Interface simples para filtros de tarefa
abstract class TaskFilter {
  /// Nome do filtro para UI
  String get name;

  /// Determina se uma tarefa passa no filtro
  bool matches(Task task, TaskController controller);
}
