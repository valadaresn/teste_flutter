import 'package:flutter/material.dart';

class DiaryStyles {
  static Color getMoodColor(String? mood) {
    switch (mood) {
      case '😊':
        return const Color(0xFFF5E6D3); // Tom quente e acolhedor
      case '😐':
        return const Color(0xFFE6EED6); // Tom neutro e calmo
      case '😢':
        return const Color(0xFFE6E6FA); // Tom suave e melancólico
      case '😡':
        return const Color(0xFFFFE4E1); // Tom rosado suave
      case '🤔':
        return const Color(0xFFF0F0F0); // Tom neutro pensativo
      case '😴':
        return const Color(0xFFE0F0FF); // Tom azulado relaxante
      default:
        return const Color(0xFFFAFAFA); // Tom padrão bem claro
    }
  }

  static const cardPadding = EdgeInsets.all(16.0);
  static const cardMargin = EdgeInsets.symmetric(vertical: 8.0);
  static const cardElevation = 0.0; // Flat design
  static final cardBorderRadius = BorderRadius.circular(12.0);

  // Estilo clean para cards
  static final cleanCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: cardBorderRadius,
    border: Border.all(color: Colors.grey.shade200, width: 1.0),
  );

  // Estilo padrão para cards
  static final standardCardDecoration = BoxDecoration(
    borderRadius: cardBorderRadius,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
