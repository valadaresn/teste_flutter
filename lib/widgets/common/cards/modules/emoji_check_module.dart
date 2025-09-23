import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// 😊 Módulo de checkbox com emoji para hábitos
class EmojiCheckModule extends PositionableModule {
  final String emoji;
  final bool isChecked;
  final VoidCallback? onToggle;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final Duration animationDuration;

  EmojiCheckModule({
    required String position,
    required this.emoji,
    required this.isChecked,
    this.onToggle,
    this.activeColor,
    this.inactiveColor,
    this.size = 48,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(position);

  @override
  String get moduleId =>
      'emoji_check_${emoji}_${isChecked ? 'checked' : 'unchecked'}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    final theme = Theme.of(context);
    final effectiveActiveColor = activeColor ?? theme.primaryColor;
    final effectiveInactiveColor =
        inactiveColor ?? effectiveActiveColor.withOpacity(0.15);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: animationDuration,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isChecked ? effectiveActiveColor : effectiveInactiveColor,
          borderRadius: BorderRadius.circular(size * 0.25),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: animationDuration,
            child:
                isChecked
                    ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: size * 0.5,
                      key: const ValueKey('check'),
                    )
                    : Text(
                      emoji,
                      style: TextStyle(fontSize: size * 0.42),
                      key: const ValueKey('emoji'),
                    ),
          ),
        ),
      ),
    );
  }
}

/// 🎯 Factory para criar módulos de emoji check
class EmojiCheckModuleFactory {
  /// Emoji check na posição leading
  static EmojiCheckModule leading({
    required String emoji,
    required bool isChecked,
    VoidCallback? onToggle,
    Color? activeColor,
    Color? inactiveColor,
    double size = 48,
  }) {
    return EmojiCheckModule(
      position: 'leading',
      emoji: emoji,
      isChecked: isChecked,
      onToggle: onToggle,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      size: size,
    );
  }

  /// Emoji check na posição trailing
  static EmojiCheckModule trailing({
    required String emoji,
    required bool isChecked,
    VoidCallback? onToggle,
    Color? activeColor,
    Color? inactiveColor,
    double size = 40,
  }) {
    return EmojiCheckModule(
      position: 'trailing',
      emoji: emoji,
      isChecked: isChecked,
      onToggle: onToggle,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      size: size,
    );
  }
}
