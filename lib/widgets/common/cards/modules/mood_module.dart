import 'package:flutter/material.dart';
import '../../../../tokens/module_pos.dart';
import '../modular_card_1.dart';

/// 😊 **MoodModule** - Módulo de emoji de humor para cards de diário
///
/// **FUNCIONALIDADE:**
/// - Display de emoji de humor com fundo colorido
/// - Cores automáticas baseadas no humor
/// - Tamanho e formato customizáveis
/// - Fallback para emoji padrão quando vazio
///
/// **USADO POR:**
/// - DiaryCard (posição leading) - para mostrar humor da entrada
///
/// **POSIÇÕES COMUNS:**
/// - `leading`: Lado esquerdo do card (padrão para diário)
/// - `trailing`: Lado direito do card
///
/// **EXEMPLO DE USO:**
/// ```dart
/// MoodModuleFactory.leading(
///   mood: '😊',
///   backgroundColor: getMoodColor('😊'),
///   size: 32,
/// )
/// ```
class MoodModule extends PositionableModule {
  final String mood;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final double fontSize;
  final BorderRadius? borderRadius;
  final String fallbackEmoji;
  final VoidCallback? onTap;

  MoodModule({
    required ModulePos position,
    required this.mood,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 32,
    this.fontSize = 18,
    this.borderRadius,
    this.fallbackEmoji = '📝',
    this.onTap,
  }) : super(position);

  @override
  String get moduleId => 'mood_${mood.isEmpty ? 'empty' : mood}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.primaryColor.withOpacity(0.15);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(6);
    final displayEmoji = mood.isEmpty ? fallbackEmoji : mood;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        // ✅ ALTURA DINÂMICA: Se for leading, sem altura fixa para expandir
        height: position == ModulePos.leading ? null : size,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: effectiveBorderRadius,
        ),
        child: Center(
          child: Text(
            displayEmoji,
            style: TextStyle(fontSize: fontSize, color: foregroundColor),
          ),
        ),
      ),
    );
  }
}

/// 🎯 Factory para criar módulos de mood
class MoodModuleFactory {
  /// Mood na posição leading (lado esquerdo)
  static MoodModule leading({
    required String mood,
    Color? backgroundColor,
    Color? foregroundColor,
    double size = 32,
    double fontSize = 18,
    BorderRadius? borderRadius,
    String fallbackEmoji = '📝',
    VoidCallback? onTap,
  }) {
    return MoodModule(
      position: ModulePos.leading,
      mood: mood,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      size: size,
      fontSize: fontSize,
      borderRadius: borderRadius,
      fallbackEmoji: fallbackEmoji,
      onTap: onTap,
    );
  }

  /// Mood na posição trailing (lado direito)
  static MoodModule trailing({
    required String mood,
    Color? backgroundColor,
    Color? foregroundColor,
    double size = 28,
    double fontSize = 16,
    BorderRadius? borderRadius,
    String fallbackEmoji = '📝',
    VoidCallback? onTap,
  }) {
    return MoodModule(
      position: ModulePos.headerTrailing,
      mood: mood,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      size: size,
      fontSize: fontSize,
      borderRadius: borderRadius,
      fallbackEmoji: fallbackEmoji,
      onTap: onTap,
    );
  }

  /// Mood com cor automática baseada no emoji
  static MoodModule withAutoColor({
    required String mood,
    ModulePos position = ModulePos.leading,
    double size = 32,
    double fontSize = 18,
    String fallbackEmoji = '📝',
    VoidCallback? onTap,
  }) {
    Color backgroundColor = _getMoodColor(mood);

    return MoodModule(
      position: position,
      mood: mood,
      backgroundColor: backgroundColor,
      size: size,
      fontSize: fontSize,
      borderRadius: BorderRadius.circular(6),
      fallbackEmoji: fallbackEmoji,
      onTap: onTap,
    );
  }

  /// Retorna cor baseada no emoji de humor
  static Color _getMoodColor(String mood) {
    switch (mood) {
      case '😊':
      case '😃':
      case '😄':
      case '😁':
        return Colors.green.withOpacity(0.15);
      case '😢':
      case '😭':
      case '😞':
        return Colors.blue.withOpacity(0.15);
      case '😡':
      case '😠':
      case '🤬':
        return Colors.red.withOpacity(0.15);
      case '😴':
      case '😪':
      case '🥱':
        return Colors.purple.withOpacity(0.15);
      case '🤔':
      case '😐':
      case '😑':
        return Colors.grey.withOpacity(0.15);
      case '❤️':
      case '😍':
      case '🥰':
        return Colors.pink.withOpacity(0.15);
      case '🤗':
      case '😇':
      case '😌':
        return Colors.amber.withOpacity(0.15);
      default:
        return Colors.grey.withOpacity(0.15);
    }
  }
}
