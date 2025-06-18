import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HabitDialog extends StatefulWidget {
  final String title;
  final String? initialTitle;
  final String? initialEmoji;
  final List<String>? initialDaysOfWeek;
  final bool? initialHasQualityRating;
  final bool? initialHasTimer;
  final int? initialTargetTime;
  final Color? initialColor;
  final bool? initialIsActive;
  final List<String> emojiOptions;
  final List<Color> colorOptions;
  final List<String> dayNames;
  final List<String> dayLabels;

  const HabitDialog({
    Key? key,
    required this.title,
    this.initialTitle,
    this.initialEmoji,
    this.initialDaysOfWeek,
    this.initialHasQualityRating,
    this.initialHasTimer,
    this.initialTargetTime,
    this.initialColor,
    this.initialIsActive,
    required this.emojiOptions,
    required this.colorOptions,
    required this.dayNames,
    required this.dayLabels,
  }) : super(key: key);

  @override
  State<HabitDialog> createState() => _HabitDialogState();
}

class _HabitDialogState extends State<HabitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetTimeController = TextEditingController();

  String _selectedEmoji = '💪';
  List<String> _selectedDays = [];
  bool _hasQualityRating = false;
  bool _hasTimer = false;
  Color _selectedColor = Colors.blue;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _titleController.text = widget.initialTitle ?? '';
    _selectedEmoji = widget.initialEmoji ?? '💪';
    _selectedDays = List.from(
      widget.initialDaysOfWeek ??
          ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
    );
    _hasQualityRating = widget.initialHasQualityRating ?? false;
    _hasTimer = widget.initialHasTimer ?? false;
    _selectedColor = widget.initialColor ?? Colors.blue;
    _isActive = widget.initialIsActive ?? true;

    if (widget.initialTargetTime != null) {
      final seconds = widget.initialTargetTime!;

      // Se for exatamente 3 segundos, mostra 0.05
      if (seconds == 3) {
        _targetTimeController.text = '0.05';
      } else {
        // Para outros valores, converte segundos para minutos
        final minutes = seconds / 60.0;
        if (minutes == minutes.roundToDouble()) {
          _targetTimeController.text = minutes.round().toString();
        } else {
          _targetTimeController.text = minutes.toStringAsFixed(2);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetTimeController.dispose();
    super.dispose();
  }

  int? _parseTimeToSeconds(String text) {
    if (text.isEmpty) return null;

    final value = double.tryParse(text);
    if (value == null || value <= 0) return null;

    // Casos especiais para valores muito pequenos (tratamento especial para 3 segundos)
    if (value <= 0.1) {
      return 3; // RETORNA 3 SEGUNDOS DIRETAMENTE!
    }

    // Para valores normais, converte minutos para segundos
    final seconds = (value * 60).round();
    return seconds;
  }

  String _formatTimeForDisplay(String text) {
    final value = double.tryParse(text);
    if (value == null) return '';

    if (value <= 0.1) {
      return '⚡ 3 segundos (teste rápido)';
    } else if (value < 1) {
      final seconds = (value * 60).round();
      return '$seconds segundos';
    } else if (value == 1) {
      return '1 minuto';
    } else {
      final cleanValue = value.toString().replaceAll('.0', '');
      return '$cleanValue minutos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildEmojiSelector(),
                      const SizedBox(height: 16),
                      _buildColorSelector(),
                      const SizedBox(height: 16),
                      _buildDaysSelector(),
                      const SizedBox(height: 16),
                      _buildOptionsSection(),
                      const SizedBox(height: 16),
                      _buildActiveToggle(),
                    ],
                  ),
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Título do Hábito',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Título é obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildEmojiSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Emoji:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              widget.emojiOptions.map((emoji) {
                final isSelected = _selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cor:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              widget.colorOptions.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                            : null,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dias da Semana:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(widget.dayNames.length, (index) {
            final dayName = widget.dayNames[index];
            final dayLabel = widget.dayLabels[index];
            final isSelected = _selectedDays.contains(dayName);

            return FilterChip(
              label: Text(dayLabel),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(dayName);
                  } else {
                    _selectedDays.remove(dayName);
                  }
                });
              },
            );
          }),
        ),
        if (_selectedDays.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Selecione pelo menos um dia',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Opções:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Permite avaliação de qualidade'),
          subtitle: const Text('Permitir avaliar com estrelas'),
          value: _hasQualityRating,
          onChanged: (value) => setState(() => _hasQualityRating = value),
        ),
        SwitchListTile(
          title: const Text('Tem tempo alvo'),
          subtitle: const Text('Definir tempo alvo para o hábito'),
          value: _hasTimer,
          onChanged: (value) => setState(() => _hasTimer = value),
        ),
        if (_hasTimer) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _targetTimeController,
            decoration: InputDecoration(
              labelText: 'Tempo alvo',
              border: const OutlineInputBorder(),
              suffixText: 'min',
              helperText:
                  _targetTimeController.text.isNotEmpty
                      ? _formatTimeForDisplay(_targetTimeController.text)
                      : 'Ex: 25 = 25min | 0.05 = 3seg | 1.5 = 1min 30seg',
              helperMaxLines: 2,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            onChanged:
                (value) => setState(() {}), // Para atualizar o helper text
            validator: (value) {
              if (_hasTimer && (value?.isEmpty ?? true)) {
                return 'Tempo alvo é obrigatório';
              }
              if (_hasTimer) {
                final seconds = _parseTimeToSeconds(value!);
                if (seconds == null) {
                  return 'Digite um número válido';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Dicas de tempo:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  '• 0.05 = 3 segundos (para testes)',
                  style: TextStyle(fontSize: 12),
                ),
                Text('• 1 = 1 minuto', style: TextStyle(fontSize: 12)),
                Text(
                  '• 25 = 25 minutos (Pomodoro)',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '• 1.5 = 1 minuto e 30 segundos',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveToggle() {
    return SwitchListTile(
      title: const Text('Hábito ativo'),
      subtitle: const Text('Hábito aparecerá na lista principal'),
      value: _isActive,
      onChanged: (value) => setState(() => _isActive = value),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(onPressed: _saveHabit, child: const Text('Salvar')),
      ],
    );
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) return;

    final result = {
      'title': _titleController.text.trim(),
      'emoji': _selectedEmoji,
      'daysOfWeek': _selectedDays,
      'hasQualityRating': _hasQualityRating,
      'hasTimer': _hasTimer,
      'targetTime':
          _hasTimer && _targetTimeController.text.isNotEmpty
              ? _parseTimeToSeconds(_targetTimeController.text)
              : null,
      'colorValue': _selectedColor.value,
      'isActive': _isActive,
    };

    Navigator.pop(context, result);
  }
}
