class Task {
  final String id;
  final String title;
  final String? description;
  bool isCompleted;
  final DateTime createdAt;
  bool isPomodoroActive;
  int pomodoroTime;
  String? selectedPomodoroLabel;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.isPomodoroActive = false,
    this.pomodoroTime = 25 * 60,
    this.selectedPomodoroLabel,
  });
}
