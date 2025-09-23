import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// 📦 **CheckboxModule** - Módulo de checkbox interativo para cards modulares
///
/// **FUNCIONALIDADE:**
/// - Checkbox com callback de mudança de estado
/// - Suporte a tristate (3 estados: true, false, null)
/// - Cor e tamanho customizáveis
/// - Posicionamento flexível (leading, trailing, header-trailing)
///
/// **USADO POR:**
/// - TaskCard (posição leading) - para marcar tarefas como completas
/// - CleanCardExamples (exemplos diversos)
///
/// **POSIÇÕES COMUNS:**
/// - `leading`: Lado esquerdo do card (padrão para tasks)
/// - `trailing`: Lado direito do card
/// - `header-trailing`: Direita do cabeçalho
///
/// **EXEMPLO DE USO:**
/// ```dart
/// CheckboxModuleFactory.leading(
///   value: task.isCompleted,
///   onChanged: (value) => updateTask(value),
///   activeColor: Colors.green,
/// )
/// ```

/// 📦 Módulo de Checkbox para cards
class CheckboxModule extends PositionableModule {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Color? activeColor;
  final Color? checkColor;
  final double? size;
  final bool tristate;

  CheckboxModule({
    required String position,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.checkColor,
    this.size,
    this.tristate = false,
  }) : super(position);

  @override
  String get moduleId => 'checkbox_${value ? 'checked' : 'unchecked'}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    return Transform.scale(
      scale: size != null ? size! / 24.0 : 1.0, // Default checkbox size is 24
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor ?? Theme.of(context).primaryColor,
        checkColor: checkColor,
        tristate: tristate,
      ),
    );
  }
}

/// 🎯 Factory para criar checkboxes em diferentes posições
class CheckboxModuleFactory {
  /// Checkbox na posição leading (esquerda)
  static CheckboxModule leading({
    required bool value,
    ValueChanged<bool?>? onChanged,
    Color? activeColor,
    Color? checkColor,
    double? size,
    bool tristate = false,
  }) {
    return CheckboxModule(
      position: 'leading',
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      checkColor: checkColor,
      size: size,
      tristate: tristate,
    );
  }

  /// Checkbox na posição trailing (direita)
  static CheckboxModule trailing({
    required bool value,
    ValueChanged<bool?>? onChanged,
    Color? activeColor,
    Color? checkColor,
    double? size,
    bool tristate = false,
  }) {
    return CheckboxModule(
      position: 'trailing',
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      checkColor: checkColor,
      size: size,
      tristate: tristate,
    );
  }

  /// Checkbox no header-trailing (direita do header)
  static CheckboxModule headerTrailing({
    required bool value,
    ValueChanged<bool?>? onChanged,
    Color? activeColor,
    Color? checkColor,
    double? size,
    bool tristate = false,
  }) {
    return CheckboxModule(
      position: 'header-trailing',
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      checkColor: checkColor,
      size: size,
      tristate: tristate,
    );
  }
}
