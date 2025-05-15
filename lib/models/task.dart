class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? projectId;
  final String? taskListId;
  bool isCompleted;
  bool isPomodoroActive;
  int pomodoroTime;
  String? selectedPomodoroLabel;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.dueDate,
    this.projectId,
    this.taskListId,
    this.isCompleted = false,
    this.isPomodoroActive = false,
    this.pomodoroTime = 25 * 60,
    this.selectedPomodoroLabel,
  });
}
