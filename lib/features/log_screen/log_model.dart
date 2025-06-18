class Log {
  final String id;

  // Identificação da entidade principal
  final String entityId; // ID da tarefa ou hábito
  final String entityType; // "task" ou "habit"
  final String entityTitle; // Nome da tarefa ou hábito

  // Hierarquia completa (para tasks)
  final String? listId; // ID da lista/matéria
  final String? listTitle; // Nome da lista/matéria (ex: "Matemática")
  final String? parentTaskId; // ID da tarefa pai (se for subtarefa)
  final String? parentTaskTitle; // Nome da tarefa pai

  // Campos de tempo e métricas
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final Map<String, dynamic> metrics;
  final List<String> tags;

  const Log({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.entityTitle,
    this.listId,
    this.listTitle,
    this.parentTaskId,
    this.parentTaskTitle,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    this.metrics = const {},
    this.tags = const [],
  });
}
