import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/pomodoro_service.dart';
import 'widgets/task_list.dart';
import 'widgets/empty_state.dart';
import 'widgets/add_task_modal.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final List<Task> _tasks = [];
  late final PomodoroService _pomodoroService;

  @override
  void initState() {
    super.initState();
    _pomodoroService = PomodoroService(
      onPomodoroComplete: _handlePomodoroComplete,
      onTick: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    _pomodoroService.dispose();
    super.dispose();
  }

  void _handlePomodoroComplete(String taskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex].isPomodoroActive = false;
      }
    });
  }

  void _toggleTaskCompletion(String id) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == id);
      if (taskIndex != -1) {
        _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
  }

  void _togglePomodoro(String taskId, bool start) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final task = _tasks[taskIndex];
        if (start) {
          task.isPomodoroActive = true;
          _pomodoroService.startPomodoro(
            task.id,
            task.title,
            task.pomodoroTime,
          );
        } else {
          task.isPomodoroActive = false;
          _pomodoroService.stopPomodoro(task.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body:
          _tasks.isEmpty
              ? EmptyState(onAddTask: () => _showAddTaskModal(context))
              : TaskList(
                tasks: _tasks,
                pomodoroService: _pomodoroService,
                onToggleComplete: _toggleTaskCompletion,
                onDelete: _deleteTask,
                onTogglePomodoro: _togglePomodoro, // Adicionando o novo método
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskModal(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder:
          (modalContext) => Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(modalContext).viewInsets.bottom + 8,
            ),
            child: const AddTaskModal(),
          ),
    );
    if (result != null && result.trim().isNotEmpty && mounted) {
      setState(() {
        _tasks.add(
          Task(
            id: DateTime.now().toString(),
            title: result.trim(),
            createdAt: DateTime.now(),
          ),
        );
      });
    }
  }
}
