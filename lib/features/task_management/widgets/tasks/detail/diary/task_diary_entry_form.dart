import 'package:flutter/material.dart';
import '../../../../../../screens/diary_screen/diary_styles.dart';

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
  final TextEditingController _contentController = TextEditingController();
  String _selectedMood = '😊'; // Emoji padrão
  bool _isExpanded = false; // Para expandir o campo quando focado

  // Lista de emojis de humor disponíveis
  final List<String> _availableMoods = [
    '😊', // Feliz
    '😐', // Neutro
    '😢', // Triste
    '😡', // Raiva
    '🤔', // Pensativo
    '😴', // Cansado/Relaxado
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        children: [
          // Campo de texto principal com seletor de emoji
          Row(
            children: [
              // Botão seletor de emoji
              _buildEmojiSelector(),

              const SizedBox(width: 12),

              // Campo de texto expansível
              Expanded(
                child: TextField(
                  controller: _contentController,
                  onTap: () => setState(() => _isExpanded = true),
                  onEditingComplete: () => setState(() => _isExpanded = false),
                  maxLines: _isExpanded ? 3 : 1,
                  decoration: const InputDecoration(
                    hintText: 'Adicionar anotação...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 15),
                ),
              ),

              // Botão enviar
              IconButton(
                onPressed: _submitEntry,
                icon: const Icon(Icons.send, size: 20),
                color: Colors.blue,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói o seletor de emoji como botão que abre popup
  Widget _buildEmojiSelector() {
    return GestureDetector(
      onTap: _showEmojiPopup,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedMood, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra popup posicionado para seleção de emoji
  void _showEmojiPopup() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy - 200, // Posicionar acima do botão
        position.dx + renderBox.size.width,
        position.dy,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      elevation: 8,
      items:
          _availableMoods.map((mood) {
            final isSelected = mood == _selectedMood;
            return PopupMenuItem<String>(
              value: mood,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // Emoji com fundo colorido
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.blue.shade50
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border:
                            isSelected
                                ? Border.all(
                                  color: Colors.blue.shade300,
                                  width: 1,
                                )
                                : null,
                      ),
                      child: Text(mood, style: const TextStyle(fontSize: 20)),
                    ),

                    const SizedBox(width: 12),

                    // Nome do humor
                    Expanded(
                      child: Text(
                        DiaryStyles.getMoodName(mood),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                          color:
                              isSelected
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade800,
                        ),
                      ),
                    ),

                    // Ícone de selecionado
                    if (isSelected)
                      Icon(Icons.check, size: 16, color: Colors.blue.shade600),
                  ],
                ),
              ),
            );
          }).toList(),
    ).then((selectedMood) {
      if (selectedMood != null) {
        setState(() => _selectedMood = selectedMood);
      }
    });
  }

  /// Submete a nova entrada se o conteúdo não estiver vazio
  void _submitEntry() {
    final content = _contentController.text.trim();
    if (content.isNotEmpty) {
      widget.onSubmit(content, _selectedMood);
      _contentController.clear();
      setState(() => _isExpanded = false);
    }
  }
}
