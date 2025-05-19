import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/project.dart';
import '../../models/task_list.dart';
import '../../models/task_filters.dart';
import '../../services/pomodoro_service.dart';
import '../../data/sample_projects.dart';
import '../../data/sample_tasks.dart';
import '../project_screen/project_management_screen.dart';
import 'widgets/task_list.dart' as task_list_widget;
import 'widgets/empty_state.dart';
import 'widgets/add_task_modal.dart';
import 'widgets/project_selector.dart';
import 'widgets/filter_modal.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late List<Task> _tasks;
  late List<Project> _projects;
  Project? _selectedProject;
  late PomodoroService _pomodoroService;
  late TaskFilters _filters;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarregar dados de exemplo a cada rebuild para refletir mudanças nos arquivos
    _reloadSampleData();
  }

  void _reloadSampleData() {
    // Recarregar dados de exemplo dos arquivos
    setState(() {
      _tasks = [...sampleTasks];

      // Manter o projeto selecionado atual se possível
      final currentProjectId = _selectedProject?.id;
      _projects = [...sampleProjects];
      if (currentProjectId != null && _projects.isNotEmpty) {
        // Corrigir o problema de tipo retornando um valor não nulo ou usando um índice padrão
        final index = _projects.indexWhere((p) => p.id == currentProjectId);
        if (index != -1) {
          _selectedProject = _projects[index];
        } else if (_projects.isNotEmpty) {
          _selectedProject = _projects[0];
        }
      }
    });
  }

  Future<void> _initializeData() async {
    // Definir estado inicial de carregamento
    if (mounted) {
      setState(() {
        _isLoading = true;
        _tasks = [];
        _projects = [];
        _selectedProject = null;
      });
    }

    try {
      // Inicializar serviço do pomodoro
      _pomodoroService = PomodoroService(
        onPomodoroComplete: _handlePomodoroComplete,
        onTick: () {
          if (mounted) setState(() {});
        },
      );

      // Carregar dados de exemplo
      _tasks = [...sampleTasks];
      _projects = [...sampleProjects];

      // Garantir que há um projeto selecionado se houver projetos
      if (_projects.isNotEmpty) {
        _selectedProject = _projects[0];
      }

      // Inicializar filtros
      _filters = TaskFilters();
      await _loadSavedFilters();

      // Atualizar estado após carregar tudo
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _tasks = [];
          _projects = [];
          _selectedProject = null;
          _filters = TaskFilters();
        });
      }
    }
  }

  Future<void> _loadSavedFilters() async {
    try {
      final savedFilters = await TaskFilters.loadSavedFilters();
      if (mounted) {
        setState(() {
          _filters = savedFilters;
        });
      }
    } catch (e) {
      print('Erro ao carregar filtros: $e');
      if (mounted) {
        setState(() {
          _filters = TaskFilters();
        });
      }
    }
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
        final task = _tasks[taskIndex];
        final wasCompleted = task.isCompleted;
        task.isCompleted = !wasCompleted;

        // Update project pending tasks count
        final projectIndex = _projects.indexWhere(
          (p) => p.id == task.projectId,
        );
        if (projectIndex != -1) {
          _projects[projectIndex] = Project(
            id: _projects[projectIndex].id,
            name: _projects[projectIndex].name,
            color: _projects[projectIndex].color,
            icon: _projects[projectIndex].icon,
            lists: _projects[projectIndex].lists,
            pendingTasks:
                _projects[projectIndex].pendingTasks + (wasCompleted ? 1 : -1),
          );

          // Update selected project if needed
          if (_selectedProject?.id == task.projectId) {
            _selectedProject = _projects[projectIndex];
          }
        }
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      final task = _tasks.firstWhere((task) => task.id == id);
      _tasks.removeWhere((t) => t.id == id);

      // Update project pending tasks count if task was not completed
      if (!task.isCompleted) {
        final projectIndex = _projects.indexWhere(
          (p) => p.id == task.projectId,
        );
        if (projectIndex != -1) {
          _projects[projectIndex] = Project(
            id: _projects[projectIndex].id,
            name: _projects[projectIndex].name,
            color: _projects[projectIndex].color,
            icon: _projects[projectIndex].icon,
            lists: _projects[projectIndex].lists,
            pendingTasks: _projects[projectIndex].pendingTasks - 1,
          );

          // Update selected project if needed
          if (_selectedProject?.id == task.projectId) {
            _selectedProject = _projects[projectIndex];
          }
        }
      }
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

  void _selectProject(Project project) {
    if (!mounted) return;
    setState(() {
      _selectedProject = project;
    });
  }

  void _updateProjectLists(String projectId, List<TaskList> lists) {
    setState(() {
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        _projects[projectIndex] = Project(
          id: _projects[projectIndex].id,
          name: _projects[projectIndex].name,
          color: _projects[projectIndex].color,
          icon: _projects[projectIndex].icon,
          lists: lists,
          pendingTasks: _projects[projectIndex].pendingTasks,
        );

        // Update selected project if needed
        if (_selectedProject?.id == projectId) {
          _selectedProject = _projects[projectIndex];
        }
      }
    });
  }

  void _updateTask(Task updatedTask) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        // Verificar se o status de conclusão mudou para atualizar as contagens
        final oldTask = _tasks[index];
        final statusChanged = oldTask.isCompleted != updatedTask.isCompleted;
        final projectChanged = oldTask.projectId != updatedTask.projectId;

        // Atualizar a tarefa na lista
        _tasks[index] = updatedTask;

        // Se o status de conclusão mudou, atualizar contagem de tarefas pendentes
        if (statusChanged) {
          // Se a tarefa foi concluída, diminuir o contador; se foi reaberta, aumentar
          final countDelta = updatedTask.isCompleted ? -1 : 1;

          // Atualizar projeto antigo se o projeto mudou
          if (projectChanged && oldTask.projectId != null) {
            final oldProjectIndex = _projects.indexWhere(
              (p) => p.id == oldTask.projectId,
            );
            if (oldProjectIndex != -1) {
              _projects[oldProjectIndex] = Project(
                id: _projects[oldProjectIndex].id,
                name: _projects[oldProjectIndex].name,
                color: _projects[oldProjectIndex].color,
                icon: _projects[oldProjectIndex].icon,
                lists: _projects[oldProjectIndex].lists,
                pendingTasks:
                    _projects[oldProjectIndex].pendingTasks -
                    (oldTask.isCompleted ? 0 : 1),
              );
            }
          }

          // Atualizar projeto novo
          if (updatedTask.projectId != null) {
            final projectIndex = _projects.indexWhere(
              (p) => p.id == updatedTask.projectId,
            );
            if (projectIndex != -1) {
              _projects[projectIndex] = Project(
                id: _projects[projectIndex].id,
                name: _projects[projectIndex].name,
                color: _projects[projectIndex].color,
                icon: _projects[projectIndex].icon,
                lists: _projects[projectIndex].lists,
                pendingTasks:
                    _projects[projectIndex].pendingTasks +
                    (updatedTask.isCompleted ? 0 : countDelta),
              );

              // Atualizar o projeto selecionado se necessário
              if (_selectedProject?.id == updatedTask.projectId) {
                _selectedProject = _projects[projectIndex];
              }
            }
          }
        }
        // Se apenas o projeto mudou (sem mudança de status)
        else if (projectChanged) {
          // Remover do projeto antigo se existe
          if (oldTask.projectId != null) {
            final oldProjectIndex = _projects.indexWhere(
              (p) => p.id == oldTask.projectId,
            );
            if (oldProjectIndex != -1) {
              _projects[oldProjectIndex] = Project(
                id: _projects[oldProjectIndex].id,
                name: _projects[oldProjectIndex].name,
                color: _projects[oldProjectIndex].color,
                icon: _projects[oldProjectIndex].icon,
                lists: _projects[oldProjectIndex].lists,
                pendingTasks:
                    _projects[oldProjectIndex].pendingTasks -
                    (oldTask.isCompleted ? 0 : 1),
              );
            }
          }

          // Adicionar ao novo projeto
          if (updatedTask.projectId != null) {
            final projectIndex = _projects.indexWhere(
              (p) => p.id == updatedTask.projectId,
            );
            if (projectIndex != -1) {
              _projects[projectIndex] = Project(
                id: _projects[projectIndex].id,
                name: _projects[projectIndex].name,
                color: _projects[projectIndex].color,
                icon: _projects[projectIndex].icon,
                lists: _projects[projectIndex].lists,
                pendingTasks:
                    _projects[projectIndex].pendingTasks +
                    (updatedTask.isCompleted ? 0 : 1),
              );

              // Atualizar o projeto selecionado se necessário
              if (_selectedProject?.id == updatedTask.projectId) {
                _selectedProject = _projects[projectIndex];
              }
            }
          }
        }
      }
    });
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (modalContext) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilterModal(
              filters: _filters,
              onFiltersChanged: (newFilters) {
                setState(() {
                  _filters = newFilters;
                });
                Navigator.pop(modalContext);
              },
            ),
          ),
    );
  }

  List<Task> _getFilteredTasks() {
    // Primeiro filtra por projeto
    List<Task> filteredByProject =
        _selectedProject != null
            ? _tasks
                .where((task) => task.projectId == _selectedProject!.id)
                .toList()
            : _tasks;

    // Depois aplica os filtros de data e status
    return _filters.applyFilters(filteredByProject);
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar indicador de carregamento enquanto inicializa
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Mostrar mensagem se não houver projetos
    if (_projects.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tarefas')),
        body: const Center(child: Text('Nenhum projeto disponível')),
      );
    }

    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          children: [
            ProjectSelector(
              selectedProject: _selectedProject,
              projects: _projects,
              onProjectSelected: (project) {
                // Usar Future.microtask para evitar conflitos de estado
                Future.microtask(() {
                  if (mounted) {
                    setState(() {
                      _selectedProject = project;
                    });
                  }
                });
              },
              onManageProjects: () {
                // Navegar para a tela de gerenciamento de projetos
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProjectManagementScreen(
                          projects: _projects,
                          onAddProject: (project) {
                            setState(() {
                              _projects.add(project);
                            });
                          },
                          onUpdateProject: (project) {
                            setState(() {
                              final index = _projects.indexWhere(
                                (p) => p.id == project.id,
                              );
                              if (index != -1) {
                                _projects[index] = project;

                                // Atualizar projeto selecionado se necessário
                                if (_selectedProject?.id == project.id) {
                                  _selectedProject = project;
                                }
                              }
                            });
                          },
                          onDeleteProject: (projectId) {
                            setState(() {
                              // Remover tarefas associadas ao projeto
                              _tasks.removeWhere(
                                (task) => task.projectId == projectId,
                              );

                              // Se o projeto excluído for o selecionado, resetar
                              if (_selectedProject?.id == projectId) {
                                _selectedProject = null;
                              }

                              // Remover o projeto
                              _projects.removeWhere((p) => p.id == projectId);
                            });
                          },
                        ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          if (_filters.dateFilter == DateFilter.today ||
              _filters.dateFilter == DateFilter.tomorrow ||
              _filters.dateFilter == DateFilter.custom)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _filters.getSelectedDateDescription(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              _filters.isFilterActive()
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color:
                  _filters.isFilterActive()
                      ? Theme.of(context).colorScheme.primary
                      : null,
            ),
            onPressed: () => _showFilterModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskModal(context),
          ),
        ],
      ),
      body:
          _tasks.isEmpty
              ? EmptyState(onAddTask: () => _showAddTaskModal(context))
              : _selectedProject != null
              ? ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _selectedProject!.lists.length,
                itemBuilder: (context, index) {
                  final list = _selectedProject!.lists[index];
                  final tasksInList =
                      filteredTasks
                          .where((task) => task.taskListId == list.id)
                          .toList();

                  // Não exibir listas vazias (sem tarefas)
                  if (tasksInList.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return ExpansionTile(
                    key: Key(list.id),
                    title: Text(
                      list.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    initiallyExpanded: list.isExpanded,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${tasksInList.length}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(Icons.expand_more),
                      ],
                    ),
                    children: [
                      task_list_widget.TaskList(
                        tasks: tasksInList,
                        pomodoroService: _pomodoroService,
                        onToggleComplete: _toggleTaskCompletion,
                        onDelete: _deleteTask,
                        onTogglePomodoro: _togglePomodoro,
                        onTaskUpdated: _updateTask,
                        projects: _projects,
                        activeFilter:
                            _filters.dateFilter, // Passando o filtro ativo
                      ),
                    ],
                  );
                },
              )
              : task_list_widget.TaskList(
                tasks: filteredTasks,
                pomodoroService: _pomodoroService,
                onToggleComplete: _toggleTaskCompletion,
                onDelete: _deleteTask,
                onTogglePomodoro: _togglePomodoro,
                onTaskUpdated: _updateTask,
                projects: _projects,
                activeFilter: _filters.dateFilter, // Passando o filtro ativo
              ),
    );
  }

  void _showAddTaskModal(BuildContext context) async {
    if (!mounted || _projects.isEmpty) return;

    final result = await showModalBottomSheet<(String, String, String)?>(
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
            child: AddTaskModal(
              project: _selectedProject,
              projects: _projects,
              onUpdateProjectLists: _updateProjectLists,
            ),
          ),
    );

    if (result != null && result.$1.trim().isNotEmpty && mounted) {
      final projectId = result.$2;
      final taskListId = result.$3;

      // Verificar se o projeto e a lista ainda existem
      final projectExists = _projects.any((p) => p.id == projectId);
      final project = _projects.firstWhere((p) => p.id == projectId);
      final listExists = project.lists.any((l) => l.id == taskListId);

      if (!projectExists || !listExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro: Projeto ou lista não encontrada'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        // Criar a tarefa com data conforme filtro ativo
        DateTime? dueDate;
        if (_filters.dateFilter == DateFilter.today) {
          dueDate = DateTime.now();
        } else if (_filters.dateFilter == DateFilter.tomorrow) {
          dueDate = DateTime.now().add(const Duration(days: 1));
        } else if (_filters.dateFilter == DateFilter.custom &&
            _filters.customDate != null) {
          dueDate = _filters.customDate;
        }

        final task = Task(
          id: DateTime.now().toString(),
          title: result.$1.trim(),
          createdAt: DateTime.now(),
          dueDate: dueDate,
          projectId: projectId,
          taskListId: taskListId,
        );

        _tasks.add(task);

        // Atualizar contagem de tarefas pendentes do projeto
        final projectIndex = _projects.indexWhere((p) => p.id == projectId);
        if (projectIndex != -1) {
          _projects[projectIndex] = Project(
            id: _projects[projectIndex].id,
            name: _projects[projectIndex].name,
            color: _projects[projectIndex].color,
            icon: _projects[projectIndex].icon,
            lists: _projects[projectIndex].lists,
            pendingTasks: _projects[projectIndex].pendingTasks + 1,
          );

          // Atualizar projeto selecionado se necessário
          if (_selectedProject?.id == projectId) {
            _selectedProject = _projects[projectIndex];
          }
        }
      });
    }
  }
}
