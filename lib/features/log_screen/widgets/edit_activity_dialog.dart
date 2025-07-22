import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../log_model.dart';
import '../../task_management/controllers/task_controller.dart';
import '../../task_management/models/project_model.dart';
import '../../task_management/models/list_model.dart';
import '../../task_management/models/task_model.dart';

class EditActivityDialog extends StatefulWidget {
  final Log log;
  final Function(Log) onSave;

  const EditActivityDialog({Key? key, required this.log, required this.onSave})
    : super(key: key);

  @override
  State<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends State<EditActivityDialog> {
  // Controllers para os inputs
  late TextEditingController dateController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;

  // IDs selecionados
  String? selectedProjectId;
  String? selectedListId;
  String? selectedTaskId;
  String? selectedSubtaskId;

  // Teste: projeto simples sem lógica complexa
  String? testProjectId;
  String? testListId;
  String? testTaskId;
  String? testSubtaskId;

  // Listas de dados para os dropdowns - agora usando getters simples
  List<Project> projects = [];

  // Estados de carregamento - simplificados
  bool isLoadingProjects = true;
  bool initialProjectDetected = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeFromLog();
    _loadProjects();
  }

  @override
  void dispose() {
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    dateController = TextEditingController();
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();

    // Removido os listeners que causavam loop infinito para tarefas ativas
    // A duração é recalculada automaticamente a cada build quando necessário
  }

  void _initializeFromLog() {
    // Inicializar controllers com dados do log
    final date = widget.log.startTime;
    dateController.text =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';

    startTimeController.text =
        '${widget.log.startTime.hour.toString().padLeft(2, '0')}:${widget.log.startTime.minute.toString().padLeft(2, '0')}';

    if (widget.log.endTime != null) {
      endTimeController.text =
          '${widget.log.endTime!.hour.toString().padLeft(2, '0')}:${widget.log.endTime!.minute.toString().padLeft(2, '0')}';
    }

    // Pré-selecionar apenas listId e taskId - o projectId será detectado após carregar os projetos
    selectedListId = widget.log.listId;
    selectedTaskId = widget.log.entityId;
    // NÃO definir selectedProjectId aqui - será feito em _detectProjectFromList após carregar projetos
  }

  // TESTE: Função simples para detectar projeto no dropdown de teste
  void _detectProjectForTest() {
    if (selectedListId != null &&
        projects.isNotEmpty &&
        testProjectId == null) {
      final taskController = Provider.of<TaskController>(
        context,
        listen: false,
      );
      final allLists = taskController.lists;
      try {
        final currentList = allLists.firstWhere(
          (list) => list.id == selectedListId,
        );
        if (projects.any((project) => project.id == currentList.projectId)) {
          setState(() {
            testProjectId = currentList.projectId;
            testListId = selectedListId; // Pré-selecionar a lista também
            testTaskId = selectedTaskId; // Pré-selecionar a tarefa também

            // Pré-selecionar subtarefa se for o caso (entityType == 'subtask')
            if (widget.log.entityType == 'subtask') {
              testSubtaskId = selectedTaskId; // O entityId é da subtarefa
            }
          });
          print(
            'TESTE - Projeto detectado automaticamente: ${currentList.projectId}',
          );
          print('TESTE - Lista detectada automaticamente: $selectedListId');
          print('TESTE - Tarefa detectada automaticamente: $selectedTaskId');
          if (widget.log.entityType == 'subtask') {
            print(
              'TESTE - Subtarefa detectada automaticamente: $selectedTaskId',
            );
          }
        }
      } catch (e) {
        print('TESTE - Lista não encontrada: $selectedListId');
      }
    }
  }

  // TESTE: Função para quando mudar o projeto de teste
  void _onTestProjectChanged(String? projectId) {
    setState(() {
      testProjectId = projectId;
      testListId = null; // Limpar lista quando mudar projeto
    });
    print('TESTE - Projeto selecionado manualmente: $projectId');
  }

  // TESTE: Função para quando mudar a lista de teste
  void _onTestListChanged(String? listId) {
    setState(() {
      testListId = listId;
      testTaskId = null; // Limpar tarefa quando mudar lista
    });
    print('TESTE - Lista selecionada: $listId');
  }

  // TESTE: Função para quando mudar a tarefa de teste
  void _onTestTaskChanged(String? taskId) {
    setState(() {
      testTaskId = taskId;
      testSubtaskId = null; // Limpar subtarefa quando mudar tarefa
    });
    print('TESTE - Tarefa selecionada: $taskId');
  }

  // TESTE: Função para quando mudar a subtarefa de teste
  void _onTestSubtaskChanged(String? subtaskId) {
    setState(() {
      testSubtaskId = subtaskId;
    });
    print('TESTE - Subtarefa selecionada: $subtaskId');
  }

  // TESTE: Obter listas filtradas por projeto de teste
  List<TaskList> get testLists {
    if (testProjectId == null) return [];
    try {
      final taskController = Provider.of<TaskController>(
        context,
        listen: false,
      );
      return taskController.lists
          .where((list) => list.projectId == testProjectId)
          .toList();
    } catch (e) {
      print('Erro ao obter listas: $e');
      return [];
    }
  }

  // TESTE: Obter tarefas filtradas por lista de teste
  List<Task> get testTasks {
    if (testListId == null) return [];
    try {
      final taskController = Provider.of<TaskController>(
        context,
        listen: false,
      );
      return taskController.getTasksByList(testListId!);
    } catch (e) {
      print('Erro ao obter tarefas: $e');
      return [];
    }
  }

  // TESTE: Obter subtarefas filtradas por tarefa de teste
  List<Task> get testSubtasks {
    if (testTaskId == null) return [];
    try {
      final taskController = Provider.of<TaskController>(
        context,
        listen: false,
      );
      return taskController.getSubtasks(testTaskId!);
    } catch (e) {
      print('Erro ao obter subtarefas: $e');
      return [];
    }
  }

  void _detectProjectFromList() {
    if (!initialProjectDetected &&
        selectedListId != null &&
        projects.isNotEmpty) {
      final taskController = Provider.of<TaskController>(
        context,
        listen: false,
      );
      final allLists = taskController.lists;
      try {
        final currentList = allLists.firstWhere(
          (list) => list.id == selectedListId,
        );
        // Verificar se o projeto existe na lista de projetos carregados
        if (projects.any((project) => project.id == currentList.projectId)) {
          setState(() {
            selectedProjectId = currentList.projectId;
            initialProjectDetected =
                true; // Impede a detecção de rodar novamente
          });
          print('Projeto detectado e definido: ${currentList.projectId}');
        } else {
          print(
            'Projeto ${currentList.projectId} não encontrado na lista de projetos',
          );
        }
      } catch (e) {
        print('Lista não encontrada: $selectedListId');
      }
    }
  }

  Future<void> _loadProjects() async {
    setState(() => isLoadingProjects = true);
    try {
      final taskController = Provider.of<TaskController>(
        context,
        listen: false,
      );
      projects = taskController.projects;

      // TESTE: Detectar projeto para o dropdown de teste (simples)
      _detectProjectForTest();

      // Detectar projeto baseado na lista já selecionada - APÓS carregar projetos
      _detectProjectFromList();

      // Se já temos um projeto selecionado, não precisamos mais carregar listas complexas
      // Os dropdowns de teste usam getters simples que funcionam
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar projetos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingProjects = false);
      }
    }
  }

  DateTime? _parseDate(String text) {
    try {
      final parts = text.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse('20${parts[2]}'); // Assumindo 20XX
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  TimeOfDay? _parseTime(String text) {
    try {
      final parts = text.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  bool _isValidForm() {
    if (testListId == null || testTaskId == null) {
      return false;
    }

    // Verificar se a lista ainda existe
    if (!testLists.any((list) => list.id == testListId)) {
      return false;
    }

    // Verificar se a tarefa ainda existe
    if (!testTasks.any((task) => task.id == testTaskId)) {
      return false;
    }

    // Verificar se a subtarefa ainda existe (se selecionada)
    if (testSubtaskId != null &&
        !testSubtasks.any((subtask) => subtask.id == testSubtaskId)) {
      return false;
    }

    // Validar data
    final date = _parseDate(dateController.text);
    if (date == null) {
      return false;
    }

    // Validar horário de início
    final startTime = _parseTime(startTimeController.text);
    if (startTime == null) {
      return false;
    }

    // Validar horário de fim (se preenchido)
    if (endTimeController.text.isNotEmpty) {
      final endTime = _parseTime(endTimeController.text);
      if (endTime == null) {
        return false;
      }

      // Verificar se o fim é após o início (permitindo atividades overnight)
      final startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );
      var endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      );

      // Se fim < início, assumir que passou da meia-noite (dia seguinte)
      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(Duration(days: 1));
      }

      // Validar limite máximo de 24 horas para uma atividade
      final duration = endDateTime.difference(startDateTime);
      if (duration.inHours > 24) {
        return false; // Atividade muito longa
      }
    }

    return true;
  }

  void _saveChanges() {
    if (!_isValidForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifique os dados inseridos')),
      );
      return;
    }

    final date = _parseDate(dateController.text)!;
    final startTime = _parseTime(startTimeController.text)!;

    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    DateTime? endDateTime;
    if (endTimeController.text.isNotEmpty) {
      final endTime = _parseTime(endTimeController.text)!;
      endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      );

      // Se fim < início, assumir que passou da meia-noite (dia seguinte)
      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(Duration(days: 1));
      }
    }

    // Encontrar as entidades selecionadas para obter os títulos usando os getters de teste
    // Com tratamento de erro para casos onde a entidade foi deletada
    TaskList? selectedList;
    Task? selectedTask;
    Task? selectedSubtask;

    try {
      selectedList = testLists.firstWhere((l) => l.id == testListId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista selecionada não encontrada')),
      );
      return;
    }

    try {
      selectedTask = testTasks.firstWhere((t) => t.id == testTaskId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa selecionada não encontrada')),
      );
      return;
    }

    if (testSubtaskId != null) {
      try {
        selectedSubtask = testSubtasks.firstWhere(
          (st) => st.id == testSubtaskId,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subtarefa selecionada não encontrada')),
        );
        return;
      }
    }

    final updatedLog = widget.log.copyWith(
      startTime: startDateTime,
      endTime: endDateTime,
      listId: testListId,
      entityId: testSubtaskId ?? testTaskId,
      entityType: testSubtaskId != null ? 'subtask' : 'task',
      entityTitle: selectedSubtask?.title ?? selectedTask.title,
      listTitle: selectedList.name,
    );

    widget.onSave(updatedLog);
  }

  String _calculateDuration() {
    final date = _parseDate(dateController.text);
    final startTime = _parseTime(startTimeController.text);
    final endTime = _parseTime(endTimeController.text);

    if (date == null ||
        startTime == null ||
        endTime == null ||
        endTimeController.text.isEmpty) {
      return '--';
    }

    // Criar um Log temporário para usar o getter calculado da model
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    var endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    // Criar Log temporário para usar a lógica centralizada da model
    final tempLog = Log(
      id: 'temp',
      entityId: 'temp',
      entityType: 'temp',
      entityTitle: 'temp',
      startTime: startDateTime,
      endTime: endDateTime,
    );

    return tempLog.durationFormatted;
  }

  @override
  Widget build(BuildContext context) {
    print(
      'Build: selectedProjectId = $selectedProjectId, projects.length = ${projects.length}',
    );
    print('Projects IDs: ${projects.map((p) => p.id).toList()}');

    return AlertDialog(
      title: const Text('Editar Atividade'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primeira linha: Data e horários
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Data',
                      hintText: 'dd/mm/aa',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: startTimeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Início',
                      hintText: 'hh:mm',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: Icon(Icons.access_time, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: endTimeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Fim',
                      hintText: 'hh:mm',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: Icon(Icons.access_time, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: _calculateDuration(),
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Duração',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: Icon(Icons.schedule, size: 18),
                    ),
                    readOnly: true,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // TESTE: Dropdown de projeto simples
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.folder_outlined),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      labelText: 'Projeto',
                    ),
                    value: testProjectId,
                    hint: const Text('Selecione projeto'),
                    items:
                        projects.map((project) {
                          return DropdownMenuItem(
                            value: project.id,
                            child: Text('${project.emoji} ${project.name}'),
                          );
                        }).toList(),
                    onChanged: _onTestProjectChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.list_outlined),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      labelText: 'Lista',
                    ),
                    value: testListId,
                    hint: const Text('Selecione lista'),
                    items:
                        testLists.map((list) {
                          return DropdownMenuItem(
                            value: list.id,
                            child: Text('${list.emoji} ${list.name}'),
                          );
                        }).toList(),
                    onChanged:
                        testProjectId == null ? null : _onTestListChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.task_outlined),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      labelText: 'Tarefa',
                    ),
                    value: testTaskId,
                    hint: const Text('Selecione tarefa'),
                    items:
                        testTasks.map((task) {
                          return DropdownMenuItem(
                            value: task.id,
                            child: Text(task.title),
                          );
                        }).toList(),
                    onChanged: testListId == null ? null : _onTestTaskChanged,
                  ),
                ),
                // TESTE: Subtarefa só aparece se a tarefa tiver subtarefas
                if (testSubtasks.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.subdirectory_arrow_right),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        labelText: 'Subtarefa',
                      ),
                      value: testSubtaskId,
                      hint: const Text('Subtarefa'),
                      items:
                          testSubtasks.map((subtask) {
                            return DropdownMenuItem(
                              value: subtask.id,
                              child: Text(subtask.title),
                            );
                          }).toList(),
                      onChanged:
                          testTaskId == null ? null : _onTestSubtaskChanged,
                    ),
                  ),
                ] else if (testTaskId != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(),
                  ), // Espaço vazio para manter alinhamento
                ],
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isValidForm() ? _saveChanges : null,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
