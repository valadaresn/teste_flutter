import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../habit_model.dart';

class HabitEditForm extends StatefulWidget {
  final Habit? habit;
  final List<String> emojiOptions;
  final List<Color> colorOptions;
  final List<String> dayNames;
  final List<String> dayLabels;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const HabitEditForm({
    Key? key,
    this.habit,
    required this.emojiOptions,
    required this.colorOptions,
    required this.dayNames,
    required this.dayLabels,
    required this.onSave,
  }) : super(key: key);

  @override
  State<HabitEditForm> createState() => _HabitEditFormState();
}

class _HabitEditFormState extends State<HabitEditForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetTimeController = TextEditingController();

  String _selectedEmoji = '💪';
  List<String> _selectedDays = [];
  Color _selectedColor = Colors.blue;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void didUpdateWidget(HabitEditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habit?.id != widget.habit?.id) {
      _initializeFields();
    }
  }

  void _initializeFields() {
    if (widget.habit != null) {
      _titleController.text = widget.habit!.title;
      _selectedEmoji = widget.habit!.emoji;
      _selectedDays = List.from(widget.habit!.daysOfWeek);
      _isActive = widget.habit!.isActive;

      // ✅ CORREÇÃO: Buscar cor compatível na lista disponível
      final habitColor = widget.habit!.color;
      _selectedColor = widget.colorOptions.firstWhere(
        (color) => color.value == habitColor.value,
        orElse:
            () =>
                widget.colorOptions.isNotEmpty
                    ? widget.colorOptions.first
                    : Colors.blue,
      );

      if (widget.habit!.targetTime != null) {
        final seconds = widget.habit!.targetTime!;
        if (seconds == 3) {
          _targetTimeController.text = '0.05';
        } else {
          final minutes = seconds / 60.0;
          _targetTimeController.text =
              (minutes == minutes.roundToDouble())
                  ? minutes.round().toString()
                  : minutes.toStringAsFixed(2);
        }
      } else {
        _targetTimeController.clear();
      }
    } else {
      _titleController.clear();
      _targetTimeController.clear();
      _selectedEmoji =
          widget.emojiOptions.isNotEmpty ? widget.emojiOptions.first : '💪';
      _selectedDays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
      _selectedColor =
          widget.colorOptions.isNotEmpty
              ? widget.colorOptions.first
              : Colors.blue;
      _isActive = true;
    }
  }

  Future<void> _saveToFirebase() async {
    if (_isSaving || !_isValidForm()) return;

    setState(() => _isSaving = true);

    try {
      await widget.onSave(_buildFormData());
      _showSuccess();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  bool _isValidForm() {
    return _titleController.text.trim().isNotEmpty && _selectedDays.isNotEmpty;
  }

  Map<String, dynamic> _buildFormData() {
    final targetTime =
        _targetTimeController.text.isNotEmpty
            ? _parseTimeToSeconds(_targetTimeController.text)
            : null;

    return {
      'title': _titleController.text.trim(),
      'emoji': _selectedEmoji,
      'daysOfWeek': _selectedDays,
      'hasQualityRating': false,
      'hasTimer': targetTime != null,
      'targetTime': targetTime,
      'colorValue': _selectedColor.value,
      'isActive': _isActive,
    };
  }

  void _showSuccess() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Salvo!'),
        duration: Duration(milliseconds: 800),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro: $error'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int? _parseTimeToSeconds(String text) {
    final value = double.tryParse(text);
    if (value == null || value <= 0) return null;
    if (value <= 0.1) return 3;
    return (value * 60).round();
  }

  String _formatTimeForDisplay(String text) {
    final value = double.tryParse(text);
    if (value == null) return '';
    if (value <= 0.1) return '⚡ 3 segundos (rápido)';
    if (value < 1) return '${(value * 60).round()} segundos';
    if (value == 1) return '1 minuto';
    final clean = value.toString().replaceAll('.0', '');
    return '$clean minutos';
  }

  // ✅ NOVO: Modal para escolher emoji (como Notion)
  void _showEmojiPicker() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Escolher Emoji'),
            content: SizedBox(
              width: 300,
              height: 400,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: widget.emojiOptions.length,
                itemBuilder: (context, index) {
                  final emoji = widget.emojiOptions[index];
                  final isSelected = _selectedEmoji == emoji;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedEmoji = emoji);
                      _saveToFirebase();
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected ? Colors.blue[50] : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
    );
  }

  // ✅ MELHORADO: Mapeamento mais robusto de cores
  String _getColorName(Color color) {
    const colorNames = {
      0xFF2196F3: 'Azul', // Colors.blue
      0xFF4CAF50: 'Verde', // Colors.green
      0xFFFF9800: 'Laranja', // Colors.orange
      0xFFF44336: 'Vermelho', // Colors.red
      0xFF9C27B0: 'Roxo', // Colors.purple
      0xFFE91E63: 'Rosa', // Colors.pink
      0xFF009688: 'Verde-azul', // Colors.teal
      0xFFFFC107: 'Âmbar', // Colors.amber
      0xFF3F51B5: 'Índigo', // Colors.indigo
      0xFF00BCD4: 'Ciano', // Colors.cyan
      0xFFCDDC39: 'Lima', // Colors.lime
      0xFF795548: 'Marrom', // Colors.brown
      0xFF607D8B: 'Azul-acinzentado', // Colors.blueGrey
      0xFF9E9E9E: 'Cinza', // Colors.grey
    };

    final colorName = colorNames[color.value];
    if (colorName != null) {
      return colorName;
    }

    // Fallback: mostrar valor hex
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com título do hábito atual
            if (widget.habit != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.habit!.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Editando: ${widget.habit!.title}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Status de salvamento
            if (_isSaving)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Salvando...'),
                  ],
                ),
              ),

            // Campo título
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título do Hábito',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator:
                  (v) => (v?.isEmpty ?? true) ? 'Título obrigatório' : null,
              onTapOutside: (_) => _saveToFirebase(),
            ),
            const SizedBox(height: 16),

            // Campo tempo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _targetTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Tempo alvo (opcional)',
                    border: OutlineInputBorder(),
                    suffixText: 'min',
                    prefixIcon: Icon(Icons.timer),
                    helperText: 'Ex: 25 = 25min | 0.05 = 3seg | 1.5 = 1m30s',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onTapOutside: (_) => _saveToFirebase(),
                ),
                if (_targetTimeController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _formatTimeForDisplay(_targetTimeController.text),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Toggle ativo
            SwitchListTile(
              title: const Text('Hábito ativo'),
              subtitle: const Text('Aparece na lista principal'),
              value: _isActive,
              secondary: const Icon(Icons.visibility),
              onChanged: (value) {
                setState(() => _isActive = value);
                _saveToFirebase();
              },
            ),
            const SizedBox(height: 16),

            // ✅ SELETOR DE EMOJI MODERNO (como Notion)
            Row(
              children: [
                const Text(
                  'Emoji:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _showEmojiPicker,
                  icon: Text(
                    _selectedEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  label: const Text('Alterar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ SELETOR DE COR MODERNO (como Todoist) - COM CORREÇÃO
            Row(
              children: [
                const Text(
                  'Cor:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                DropdownButton<Color>(
                  // ✅ CORREÇÃO: Buscar cor por valor ao invés de referência
                  value: widget.colorOptions.firstWhere(
                    (color) => color.value == _selectedColor.value,
                    orElse:
                        () =>
                            widget.colorOptions.isNotEmpty
                                ? widget.colorOptions.first
                                : Colors.blue,
                  ),
                  icon: const Icon(Icons.arrow_drop_down),
                  borderRadius: BorderRadius.circular(8),
                  onChanged: (color) {
                    if (color != null) {
                      setState(() => _selectedColor = color);
                      _saveToFirebase();
                    }
                  },
                  items:
                      widget.colorOptions.map((color) {
                        return DropdownMenuItem<Color>(
                          value: color,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[400]!),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_getColorName(color)),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Seletor de Dias (mantido como FilterChip por ser mais eficiente)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dias da Semana:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < widget.dayNames.length; i++)
                      FilterChip(
                        label: Text(widget.dayLabels[i]),
                        selected: _selectedDays.contains(widget.dayNames[i]),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(widget.dayNames[i]);
                            } else {
                              _selectedDays.remove(widget.dayNames[i]);
                            }
                          });
                          _saveToFirebase();
                        },
                      ),
                  ],
                ),
                if (_selectedDays.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Selecione ao menos um dia',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
