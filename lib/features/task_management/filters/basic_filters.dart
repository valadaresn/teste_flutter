import '../models/task_model.dart';
import '../controllers/task_controller.dart';
import 'task_filter.dart';

/// Filtro que mostra todas as tarefas
class AllTasksFilter extends TaskFilter {
  @override
  String get name => 'Todas as Tarefas';

  @override
  bool matches(Task task, TaskController controller) => true;
}

/// Filtro para tarefas de hoje + atrasadas
class TodayFilter extends TaskFilter {
  @override
  String get name => 'Hoje';

  @override
  bool matches(Task task, TaskController controller) {
    // Usar a mesma lógica do controller: tarefas de hoje + atrasadas
    final todayTasks = controller.getTodayTasks();
    final overdueTasks = controller.getOverdueTasks();

    return todayTasks.contains(task) || overdueTasks.contains(task);
  }
}

/// Filtro para lista específica
class ListFilter extends TaskFilter {
  final String listId;
  final String listName;

  ListFilter(this.listId, this.listName);

  @override
  String get name => listName;

  @override
  bool matches(Task task, TaskController controller) {
    return task.listId == listId;
  }
}
