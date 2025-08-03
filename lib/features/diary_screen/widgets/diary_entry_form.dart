import 'package:flutter/material.dart';
import '../../../screens/diary_screen/diary_styles.dart';

/// **DiaryEntryForm** - Formulário expandido para tela dedicada de diário
///
/// Diferenças do TaskDiaryEntryForm:
/// - Campo de título opcional
/// - Área de texto maior e mais polida
/// - Visual mais destacado e profissional
/// - Melhor UX para criação de entradas
class DiaryEntryForm extends StatefulWidget {
  final Function(String content, String mood, {String? title}) onSubmit;

  const DiaryEntryForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<DiaryEntryForm> createState() => _DiaryEntryFormState();
}

class _DiaryEntryFormState extends State<DiaryEntryForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedMood = '😊';
  bool _showTitleField = false;

  // Lista de emojis disponíveis
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
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        // Sombra mais presente para destacar no fundo rosado
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com emoji e opção de título
          Row(
            children: [
              // Seletor de emoji melhorado
              _buildEmojiSelector(),

              const SizedBox(width: 12),

              // Botão para mostrar/ocultar campo de título
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showTitleField = !_showTitleField;
                    if (!_showTitleField) {
                      _titleController.clear();
                    }
                  });
                },
                icon: Icon(
                  _showTitleField ? Icons.title : Icons.add_box_outlined,
                  size: 16,
                ),
                label: Text(
                  _showTitleField ? 'Ocultar título' : 'Adicionar título',
                  style: const TextStyle(fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),

          // Campo de título (condicional)
          if (_showTitleField) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Título da entrada...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],

          const SizedBox(height: 12),

          // Campo de conteúdo principal
          TextField(
            controller: _contentController,
            maxLines: 4, // Mais linhas que o form básico
            decoration: InputDecoration(
              hintText: 'O que você quer registrar hoje?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 15),
          ),

          const SizedBox(height: 12),

          // Botões de ação
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Contador de caracteres
              Text(
                '${_contentController.text.length} caracteres',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),

              const Spacer(),

              // Botão Limpar
              TextButton(
                onPressed: _clearForm,
                child: const Text('Limpar'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
              ),

              const SizedBox(width: 8),

              // Botão Salvar
              ElevatedButton.icon(
                onPressed: _submitEntry,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói seletor de emoji melhorado
  Widget _buildEmojiSelector() {
    return GestureDetector(
      onTap: _showEmojiPopup,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: DiaryStyles.getMoodColor(_selectedMood),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedMood, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra popup de seleção de emoji
  void _showEmojiPopup() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy - 220,
        position.dx + renderBox.size.width,
        position.dy,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      elevation: 12,
      items:
          _availableMoods.map((mood) {
            final isSelected = mood == _selectedMood;
            return PopupMenuItem<String>(
              value: mood,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? DiaryStyles.getMoodColor(mood)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            isSelected
                                ? Border.all(
                                  color: Colors.blue.shade300,
                                  width: 2,
                                )
                                : null,
                      ),
                      child: Text(mood, style: const TextStyle(fontSize: 22)),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Text(
                        DiaryStyles.getMoodName(mood),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isSelected
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade800,
                        ),
                      ),
                    ),

                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.blue.shade600,
                      ),
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

  /// Limpa todos os campos
  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedMood = '😊';
      _showTitleField = false;
    });
  }

  /// Submete a nova entrada
  void _submitEntry() {
    final content = _contentController.text.trim();
    if (content.isNotEmpty) {
      final title = _titleController.text.trim();
      widget.onSubmit(
        content,
        _selectedMood,
        title: title.isEmpty ? null : title,
      );
      _clearForm();
    }
  }
}
