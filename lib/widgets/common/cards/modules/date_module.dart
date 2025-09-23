import 'package:flutter/material.dart';
import '../../../../tokens/module_pos.dart';
import '../modular_card_1.dart';

/// 📅 Módulo de data para cards
class DateModule extends PositionableModule {
  final DateTime date;
  final String?
  format; // 'short' = d/M/y, 'medium' = d MMM y, 'long' = d MMMM yyyy
  final TextStyle? textStyle;
  final Color? textColor;
  final DateDisplayMode displayMode;

  DateModule({
    required ModulePos position,
    required this.date,
    this.format,
    this.textStyle,
    this.textColor,
    this.displayMode = DateDisplayMode.short,
  }) : super(position);

  @override
  String get moduleId => 'date_${date.millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    final formattedDate = _formatDate();
    final effectiveColor = textColor ?? Colors.grey;
    final effectiveStyle =
        textStyle ?? TextStyle(fontSize: 12, color: effectiveColor);

    return Text(formattedDate, style: effectiveStyle);
  }

  String _formatDate() {
    switch (displayMode) {
      case DateDisplayMode.short:
        return '${date.day}/${date.month}/${date.year}';
      case DateDisplayMode.medium:
        return '${date.day} ${_getMonthAbbr(date.month)} ${date.year}';
      case DateDisplayMode.long:
        return '${date.day} de ${_getMonthName(date.month)} de ${date.year}';
      case DateDisplayMode.relative:
        return _getRelativeDate();
      case DateDisplayMode.time:
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      case DateDisplayMode.dateTime:
        return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return months[month - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    return months[month - 1];
  }

  String _getRelativeDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = dateOnly.difference(today).inDays;

    if (difference == 0) {
      return 'hoje';
    } else if (difference == 1) {
      return 'amanhã';
    } else if (difference == -1) {
      return 'ontem';
    } else if (difference > 0 && difference <= 7) {
      return 'em $difference dias';
    } else if (difference < 0 && difference >= -7) {
      return '${difference.abs()} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// 📅 Modos de exibição da data
enum DateDisplayMode {
  short, // 15/3/2024
  medium, // 15 Mar 2024
  long, // 15 de março de 2024
  relative, // hoje, ontem, amanhã, etc.
  time, // 14:30
  dateTime, // 15/3 14:30
}

/// 🎯 Factory para criar módulos de data
class DateModuleFactory {
  /// Data no header-trailing (direita do header)
  static DateModule headerTrailing({
    required DateTime date,
    DateDisplayMode displayMode = DateDisplayMode.short,
    Color? textColor,
    TextStyle? textStyle,
  }) {
    return DateModule(
      position: ModulePos.headerTrailing,
      date: date,
      displayMode: displayMode,
      textColor: textColor,
      textStyle: textStyle,
    );
  }

  /// Data no footer
  static DateModule footer({
    required DateTime date,
    DateDisplayMode displayMode = DateDisplayMode.medium,
    Color? textColor,
    TextStyle? textStyle,
  }) {
    return DateModule(
      position: ModulePos.footer,
      date: date,
      displayMode: displayMode,
      textColor: textColor,
      textStyle: textStyle,
    );
  }

  /// Data relativa (hoje, ontem, etc.)
  static DateModule relative({
    required DateTime date,
    ModulePos position = ModulePos.headerTrailing,
    Color? textColor,
    TextStyle? textStyle,
  }) {
    return DateModule(
      position: position,
      date: date,
      displayMode: DateDisplayMode.relative,
      textColor: textColor,
      textStyle: textStyle,
    );
  }

  /// Data e hora
  static DateModule dateTime({
    required DateTime date,
    ModulePos position = ModulePos.footer,
    Color? textColor,
    TextStyle? textStyle,
  }) {
    return DateModule(
      position: position,
      date: date,
      displayMode: DateDisplayMode.dateTime,
      textColor: textColor,
      textStyle: textStyle,
    );
  }
}
