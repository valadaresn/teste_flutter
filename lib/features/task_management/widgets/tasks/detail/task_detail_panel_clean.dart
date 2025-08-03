import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/task_controller.dart';
import '../../../themes/theme_provider.dart';
import '../../../../../screens/diary_screen/diary_controller.dart';
import 'task_header.dart';
import 'task_subtasks_section.dart';
import 'task_notes_section.dart';
import 'diary/task_diary_section.dart';
import 'task_footer.dart';
import 'services/task_panel_logic.dart';

/// **TaskDetailPanel** - Painel clean de edição de tarefas
///
/// Painel inspirado no TickTick/MS Todo com design minimalista,
/// salvamento automático e sem botões de confirmação
class TaskDetailPanel extends StatefulWidget {
  final TaskController controller;

  const TaskDetailPanel({Key? key, required this.controller}) : super(key: key);

  @override
  State<TaskDetailPanel> createState() => _TaskDetailPanelState();
}

class _TaskDetailPanelState extends State<TaskDetailPanel> {
  late TaskPanelLogic _logic;
  late DiaryController _diaryController;

  @override
  void initState() {
    super.initState();
    _diaryController = DiaryController();
    _logic = TaskPanelLogic(
      taskController: widget.controller,
      diaryController: _diaryController,
    );
    // Configurar callback para atualizações de dados
    _logic.setOnDataChangedCallback(() => setState(() {}));
    _logic.initialize();
  }

  @override
  void didUpdateWidget(TaskDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_logic.hasTaskChanged()) {
      _logic.updateForNewTask(_logic.selectedTask, () => setState(() {}));
    }
  }

  @override
  void dispose() {
    _logic.dispose();
    _diaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final task = _logic.selectedTask;

        if (task == null) {
          return const SizedBox.shrink();
        }

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              width: 400,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: themeProvider.getBackgroundColor(
                  context,
                  listColor:
                      widget.controller.selectedListId != null
                          ? widget.controller
                              .getListById(widget.controller.selectedListId!)
                              ?.color
                          : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(-2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Conteúdo principal
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header: Seta + Título
                          TaskHeader(
                            titleController: _logic.titleController,
                            taskController: widget.controller,
                          ),

                          const SizedBox(height: 32),

                          // 2. Subtarefas
                          TaskSubtasksSection(
                            subtasks: _logic.subtasks,
                            subtaskControllers: _logic.subtaskControllers,
                            taskController: widget.controller,
                            onToggleComplete: _logic.toggleSubtaskCompleted,
                            onDelete: _logic.deleteSubtask,
                            onSubtaskChanged:
                                (_) => {}, // Já gerenciado internamente
                            newSubtaskController: _logic.newSubtaskController,
                            onAddSubtask: _logic.addSubtask,
                          ),

                          const SizedBox(height: 32),

                          // 3. Anotações
                          TaskNotesSection(controller: _logic.notesController),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // 4. Seção de Diário (Bottom, acima do footer)
                  TaskDiarySection(
                    task: task,
                    diaryEntries: _logic.diaryEntries,
                    isExpanded: _logic.isDiaryExpanded,
                    onAddEntry: (content, mood) async {
                      await _logic.addDiaryEntry(content, mood);
                      setState(() {}); // Atualizar UI
                    },
                    onEditEntry: (entry) async {
                      await _logic.editDiaryEntry(entry);
                      setState(() {}); // Atualizar UI
                    },
                    onDeleteEntry: (entryId) async {
                      await _logic.deleteDiaryEntry(entryId);
                      setState(() {}); // Atualizar UI
                    },
                  ),

                  // 5. Rodapé: Data + Pomodoro + Lista + Diário + Delete
                  TaskFooter(
                    task: task,
                    taskController: widget.controller,
                    onDateChanged:
                        (newDate) => _logic.updateTaskDate(
                          task,
                          newDate,
                          () => setState(() {}),
                        ),
                    onPomodoroTimeChanged:
                        (newTime) =>
                            newTime != null
                                ? _logic.updatePomodoroTime(task, newTime)
                                : null,
                    onListChanged:
                        (newListId) =>
                            newListId != null
                                ? _logic.updateTaskList(task, newListId)
                                : null,
                    onDeleteTask: () => _logic.deleteTask(context),
                    onToggleDiary: () => _logic.toggleDiarySection(),
                    isDiaryExpanded: _logic.isDiaryExpanded,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
