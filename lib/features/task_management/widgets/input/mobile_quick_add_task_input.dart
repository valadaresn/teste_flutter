import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import 'quick_date_selector.dart';
import 'quick_list_selector.dart';
import 'quick_pomodoro_selector.dart';

/// **MobileQuickAddTaskInput** - Campo de adicionar tarefa otimizado para mobile
///
/// Layout em duas linhas que aparece acima do teclado como modal bottom sheet
class MobileQuickAddTaskInput extends StatefulWidget {
  final TaskController controller;

  const MobileQuickAddTaskInput({super.key, required this.controller});

  @override
  State<MobileQuickAddTaskInput> createState() =>
      _MobileQuickAddTaskInputState();
}

class _MobileQuickAddTaskInputState extends State<MobileQuickAddTaskInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  // Variáveis para os seletores
  String? _selectedListId;
  DateTime? _selectedDate;
  int _pomodoroTime = 25;

  @override
  void initState() {
    super.initState();
    // Inicializar lista selecionada
    _selectedListId = widget.controller.selectedListId;

    // Escutar mudanças no texto para atualizar o estado do botão
    _textController.addListener(() {
      setState(() {});
    });

    // Auto-focus no campo de texto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
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
        priority: TaskPriority.medium,
        isImportant: false,
        dueDate: _selectedDate,
        tags: [],
        pomodoroTimeMinutes: _pomodoroTime,
      );

      await widget.controller.createTask(newTask);

      // Fechar o modal após sucesso
      if (mounted) {
        Navigator.of(context).pop();
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
    debugPrint('🚀 MobileQuickAddTaskInput.build() sendo executado');
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle visual para indicar que é um modal
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Linha 1: Campo de texto + botão enviar
          Row(
            children: [
              // Campo de texto
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Adicionar uma tarefa',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  onSubmitted: (_) => _createQuickTask(),
                  enabled: !_isLoading,
                ),
              ),

              const SizedBox(width: 12),

              // Botão de envio
              Container(
                width: 48,
                height: 48,
                child:
                    _isLoading
                        ? Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                        : Material(
                          color:
                              _textController.text.trim().isNotEmpty
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap:
                                _textController.text.trim().isNotEmpty
                                    ? _createQuickTask
                                    : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Icon(
                              Icons.send,
                              color:
                                  _textController.text.trim().isNotEmpty
                                      ? Colors.white
                                      : Colors.grey.shade500,
                              size: 20,
                            ),
                          ),
                        ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Linha 2: Seletores de lista e data
          Row(
            children: [
              // Seletor de lista
              QuickListSelector(
                selectedListId: _selectedListId,
                controller: widget.controller,
                onListChanged: (listId) {
                  setState(() {
                    _selectedListId = listId;
                  });
                },
              ),

              const SizedBox(width: 16),

              // Seletor de data
              QuickDateSelector(
                selectedDate: _selectedDate,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),

              const SizedBox(width: 16),

              // Seletor de pomodoro
              QuickPomodoroSelector(
                pomodoroTime: _pomodoroTime,
                onTimeChanged: (time) {
                  setState(() {
                    _pomodoroTime = time;
                  });
                },
              ),

              const Spacer(),

              // Botão de fechar
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Espaçamento final
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
