import 'package:flutter/material.dart';

/// **TaskDiaryEntryForm** - Formulário para nova entrada de diário
///
/// Componente que permite ao usuário criar uma nova entrada de diário
/// com campo de texto e seletor de emoji/humor via popup
class TaskDiaryEntryForm extends StatefulWidget {
  final Function(String content, String mood) onSubmit;

  const TaskDiaryEntryForm({Key? key, required this.onSubmit})
    : super(key: key);

  @override
  State<TaskDiaryEntryForm> createState() => _TaskDiaryEntryFormState();
}

class _TaskDiaryEntryFormState extends State<TaskDiaryEntryForm> {
  final TextEditingController _controller = TextEditingController();
  String _selectedMood = '😊';

  final List<String> _moods = ['😊', '😢', '😡', '😴', '🤔', '😍', '🤯', '🥳'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSubmit(_controller.text.trim(), _selectedMood);
      _controller.clear();
      setState(() {
        _selectedMood = '😊';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Campo de texto
          TextField(
            controller: _controller,
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Como você se sente sobre essa tarefa?',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),

          const SizedBox(height: 8),

          // Barra inferior com mood e botão
          Row(
            children: [
              // Seletor de mood
              GestureDetector(
                onTap: _showMoodSelector,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedMood, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Botão adicionar
              TextButton(onPressed: _submit, child: const Text('Adicionar')),
            ],
          ),
        ],
      ),
    );
  }

  void _showMoodSelector() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Como você se sente?'),
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _moods
                      .map(
                        (mood) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMood = mood;
                            });
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  _selectedMood == mood
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              mood,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }
}
