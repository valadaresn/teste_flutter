import 'package:flutter/material.dart';

/// **DetailPanelConstants** - Constantes para painéis de detalhes
///
/// Centraliza todas as constantes de cores, dimensões, animações
/// e configurações dos painéis de detalhes do diário.
class DetailPanelConstants {
  // 🎨 Cores
  static const Color backgroundColorMobile = Color(0xFFFCF0F0);
  static const Color backgroundColorDesktop = Color(0xFFFCF0F0);
  static const Color contentBackgroundColor = Color(0xFFFDF7F7);
  static const Color headerBorderColor = Color(0xFFE0E0E0);

  // 📏 Dimensões
  static const double desktopPanelWidth = 400.0;
  static const double mobileBreakpoint = 768.0;
  static const double headerPadding = 16.0;
  static const double contentPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double iconSize = 24.0;
  static const double emojiSize = 24.0;

  // ⏱️ Animações
  static const Duration slideAnimationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 2);

  // 😊 Lista de moods padrão
  static const List<String> defaultMoods = ['😊', '😐', '😢', '😡', '🤔', '😴'];

  // 📱 Breakpoints
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;

  // 🎭 Animação curves
  static const Curve slideAnimationCurve = Curves.easeInOut;

  // 🔧 TextField configurações
  static const double textFieldFontSize = 16.0;
  static const double textFieldLineHeight = 1.5;
  static const double hintTextSize = 16.0;

  // 📅 Data formatação
  static const List<String> monthsShort = [
    '',
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
}
