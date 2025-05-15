class TaskList {
  final String id;
  final String name;
  final bool isExpanded;

  const TaskList({
    required this.id,
    required this.name,
    this.isExpanded = true,
  });
}
