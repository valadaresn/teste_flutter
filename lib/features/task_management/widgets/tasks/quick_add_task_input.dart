import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../themes/theme_provider.dart';
import 'quick_date_selector.dart';
import 'quick_pomodoro_selector.dart';
import 'quick_list_selector.dart';

class QuickAddTaskInput extends StatefulWidget {
  final TaskController controller;

  const QuickAddTaskInput({super.key, required this.controller});

  @override
  State<QuickAddTaskInput> createState() => _QuickAddTaskInputState();
}

class _QuickAddTaskInputState extends State<QuickAddTaskInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  // Variáveis para os seletores discretos
  String? _selectedListId;
  DateTime? _selectedDate;
  int _pomodoroTime = 25; // padrão

  @override
  void initState() {
    super.initState();
    // Inicializar lista selecionada
    _selectedListId = widget.controller.selectedListId;

    // Escutar mudanças no texto para atualizar o estado do botão
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _createQuickTask() async {
    final title = _textController.text.trim();

    if (title.isEmpty) {
      return;
    }

    final selectedListId = _selectedListId ?? widget.controller.selectedListId;
    if (selectedListId == null) {
      _showError('Selecione uma lista primeiro');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newTask = Task.create(
        id: '', // Será gerado pelo controller
        title: title,
        description: '',
        listId: selectedListId,
        priority: TaskPriority.medium, // Prioridade padrão
        isImportant: false, // Não importante por padrão
        dueDate: _selectedDate, // Data selecionada
        tags: [], // Sem tags por padrão
        pomodoroTimeMinutes: _pomodoroTime, // Tempo do pomodoro selecionado
      );

      await widget.controller.createTask(newTask);

      // Aguardar um frame para a tarefa estar disponível e então selecioná-la
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Encontrar a tarefa recém-criada (a última da lista selecionada)
          final tasks = widget.controller.getTasksByList(selectedListId);
          if (tasks.isNotEmpty) {
            // Selecionar a última tarefa criada (mais recente)
            final latestTask = tasks.last;
            widget.controller.selectTask(latestTask.id);
          }
        });
      }

      // Limpar o campo e resetar seletores após sucesso
      _textController.clear();
      setState(() {
        // Não resetar _selectedDate - manter como padrão para próxima tarefa
        _pomodoroTime = 25;
        // Manter lista selecionada para próxima tarefa
      });

      // Retornar o foco para o campo de texto para próxima tarefa
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _focusNode.canRequestFocus) {
            _focusNode.requestFocus();
          }
        });
      }
    } catch (e) {
      _showError('Erro ao criar tarefa: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color:
            themeProvider.getCardGradient(false) == null
                ? themeProvider.getCardColor(false)
                : null,
        gradient: themeProvider.getCardGradient(false),
        borderRadius: BorderRadius.circular(themeProvider.getBorderRadius()),
        border: Border.all(
          color: themeProvider.getCardBorderColor(
            false,
            Theme.of(context).primaryColor,
          ),
          width: themeProvider.getCardBorderWidth(false),
        ),
        boxShadow: themeProvider.getCardShadow(false),
      ),
      child: Row(
        children: [
          // Ícone de adicionar à esquerda
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.add_circle_outline,
              color: Colors.grey.shade600,
              size: 22,
            ),
          ),

          // Campo de texto
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'Nova tarefa',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 18,
                ),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              onSubmitted: (_) => _createQuickTask(),
              enabled: !_isLoading,
            ),
          ),

          // Botões de seleção discretos
          QuickListSelector(
            selectedListId: _selectedListId,
            controller: widget.controller,
            onListChanged: (listId) {
              setState(() {
                _selectedListId = listId;
              });
            },
          ),

          const SizedBox(width: 4),

          QuickDateSelector(
            selectedDate: _selectedDate,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),

          const SizedBox(width: 4),

          QuickPomodoroSelector(
            pomodoroTime: _pomodoroTime,
            onTimeChanged: (time) {
              setState(() {
                _pomodoroTime = time;
              });
            },
          ),

          const SizedBox(width: 8),

          // Botão de envio ou loading
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child:
                _isLoading
                    ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                    : IconButton(
                      onPressed:
                          _textController.text.trim().isNotEmpty
                              ? _createQuickTask
                              : null,
                      icon: Icon(
                        Icons.send,
                        color:
                            _textController.text.trim().isNotEmpty
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade400,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
