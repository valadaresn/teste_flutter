import 'package:flutter/material.dart';
import '../../../models/project.dart';
import '../../../models/task_list.dart';

class AddTaskModal extends StatefulWidget {
  final Project? project;
  final List<Project> projects;
  final Function(String, List<TaskList>) onUpdateProjectLists;

  const AddTaskModal({
    super.key,
    this.project,
    required this.projects,
    required this.onUpdateProjectLists,
  });

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final taskController = TextEditingController();
  final newListController = TextEditingController();
  late String selectedProjectId;
  late String selectedListId;
  bool isCreatingNewList = false;
  bool isUpdatingList = false;

  @override
  void initState() {
    super.initState();

    // Garantir valores padrão seguros
    if (widget.projects.isEmpty) {
      selectedProjectId = '';
      selectedListId = '';
      return;
    }

    // Usar o projeto atual ou o primeiro da lista
    final initialProject = widget.project ?? widget.projects.first;
    selectedProjectId = initialProject.id;

    // Garantir que há pelo menos uma lista
    if (initialProject.lists.isNotEmpty) {
      selectedListId = initialProject.lists.first.id;
    } else {
      selectedListId = '';
    }
  }

  Project? _getCurrentProject() {
    if (selectedProjectId.isEmpty || widget.projects.isEmpty) {
      return null;
    }

    try {
      return widget.projects.firstWhere((p) => p.id == selectedProjectId);
    } catch (e) {
      print('Erro ao buscar projeto atual: $e');
      return null;
    }
  }

  @override
  void dispose() {
    taskController.dispose();
    newListController.dispose();
    super.dispose();
  }

  void _createNewList() {
    final name = newListController.text.trim();
    if (name.isEmpty || selectedProjectId.isEmpty) return;

    setState(() => isUpdatingList = true);

    // Gerar ID único para a nova lista
    final id = '${selectedProjectId}_${DateTime.now().millisecondsSinceEpoch}';
    final currentProject = widget.projects.firstWhere(
      (p) => p.id == selectedProjectId,
      orElse:
          () =>
              widget.projects.isNotEmpty
                  ? widget.projects.first
                  : throw Exception('Nenhum projeto disponível'),
    );
    final updatedLists = [
      ...currentProject.lists,
      TaskList(id: id, name: name),
    ];
    widget.onUpdateProjectLists(selectedProjectId, updatedLists);

    // Aguarda o próximo frame para garantir que a lista foi atualizada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Busca o projeto atualizado
      try {
        final updatedProject = widget.projects.firstWhere(
          (p) => p.id == selectedProjectId,
        );
        final exists = updatedProject.lists.any((l) => l.id == id);
        setState(() {
          selectedListId =
              exists
                  ? id
                  : updatedProject.lists.isNotEmpty
                  ? updatedProject.lists.first.id
                  : '';
          isCreatingNewList = false;
          isUpdatingList = false;
          newListController.clear();
        });
      } catch (e) {
        // Caso não consiga encontrar o projeto, reseta o estado
        setState(() {
          isCreatingNewList = false;
          isUpdatingList = false;
          newListController.clear();
        });
      }
    });
  }

  void _submit() {
    final text = taskController.text.trim();
    if (text.isNotEmpty &&
        selectedProjectId.isNotEmpty &&
        selectedListId.isNotEmpty) {
      Navigator.of(context).pop((text, selectedProjectId, selectedListId));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Proteção para quando não há projetos
    if (widget.projects.isEmpty) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Não há projetos disponíveis para adicionar tarefas.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    final currentProject = _getCurrentProject();

    // Se não conseguir encontrar o projeto atual
    if (currentProject == null) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Erro ao carregar o projeto. Tente novamente.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.project == null) ...[
          DropdownButtonFormField<String>(
            value: selectedProjectId,
            decoration: const InputDecoration(
              labelText: 'Projeto',
              border: OutlineInputBorder(),
            ),
            items:
                widget.projects.map((project) {
                  return DropdownMenuItem(
                    value: project.id,
                    child: Row(
                      children: [
                        Icon(project.icon, color: project.color, size: 20),
                        const SizedBox(width: 8),
                        Text(project.name),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedProjectId = value;
                  try {
                    final project = widget.projects.firstWhere(
                      (p) => p.id == value,
                    );
                    selectedListId =
                        project.lists.isNotEmpty ? project.lists.first.id : '';
                  } catch (e) {
                    selectedListId = '';
                  }
                  isCreatingNewList = false;
                });
              }
            },
          ),
          const SizedBox(height: 16),
        ],

        if (!isCreatingNewList &&
            !isUpdatingList &&
            currentProject.lists.isNotEmpty)
          DropdownButtonFormField<String>(
            value:
                currentProject.lists.any((list) => list.id == selectedListId)
                    ? selectedListId
                    : (currentProject.lists.isNotEmpty
                        ? currentProject.lists.first.id
                        : null),
            decoration: const InputDecoration(
              labelText: 'Lista',
              border: OutlineInputBorder(),
            ),
            items: [
              ...currentProject.lists.map((list) {
                return DropdownMenuItem(value: list.id, child: Text(list.name));
              }),
              const DropdownMenuItem(
                value: 'new_list',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 8),
                    Text('Nova Lista...'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value == 'new_list') {
                setState(() {
                  isCreatingNewList = true;
                });
              } else if (value != null) {
                setState(() {
                  selectedListId = value;
                });
              }
            },
          )
        else if (currentProject.lists.isEmpty &&
            !isCreatingNewList &&
            !isUpdatingList)
          TextButton.icon(
            onPressed: () {
              setState(() {
                isCreatingNewList = true;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Criar uma lista'),
          )
        else if (isCreatingNewList)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: newListController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Nova Lista',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _createNewList(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _createNewList,
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          )
        else if (isUpdatingList)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ),
        const SizedBox(height: 16),

        TextField(
          controller: taskController,
          autofocus: !isCreatingNewList,
          decoration: InputDecoration(
            hintText: 'Adicionar uma tarefa',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submit,
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
      ],
    );
  }
}
