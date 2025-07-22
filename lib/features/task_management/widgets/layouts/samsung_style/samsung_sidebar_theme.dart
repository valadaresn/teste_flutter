import 'package:flutter/material.dart';

/// Classe que define o tema visual para o sidebar no estilo Samsung Notes
class SamsungSidebarTheme {
  // Cores
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color selectedItemColor = Color(0xFFE8E8E8);
  static const Color textColor = Color(0xFF303030);
  static const Color counterColor = Color(0xFF8E8E8E);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color iconColor = Color(0xFF666666);

  // Espaçamentos
  static const double itemVerticalPadding = 10.0;
  static const double itemHorizontalPadding = 16.0;
  static const double sectionSpacing = 16.0;
  static const double nestedItemIndent = 16.0;
  static const double iconSize = 20.0;
  static const double borderRadius = 4.0;

  // Tipografia
  static const double itemFontSize = 14.0;
  static const double counterFontSize = 14.0;
  static const double headerFontSize = 14.0;
  static const FontWeight itemFontWeight = FontWeight.w400;
  static const FontWeight headerFontWeight = FontWeight.w500;

  // Estilos de texto pré-definidos
  static const TextStyle itemTextStyle = TextStyle(
    fontSize: itemFontSize,
    fontWeight: itemFontWeight,
    color: textColor,
  );

  static const TextStyle counterTextStyle = TextStyle(
    fontSize: counterFontSize,
    fontWeight: itemFontWeight,
    color: counterColor,
  );

  static const TextStyle headerTextStyle = TextStyle(
    fontSize: headerFontSize,
    fontWeight: headerFontWeight,
    color: textColor,
  );

  // Decorações pré-definidas
  static BoxDecoration get selectedItemDecoration => BoxDecoration(
    color: selectedItemColor,
    borderRadius: BorderRadius.circular(borderRadius),
  );

  static BoxDecoration get dividerDecoration => BoxDecoration(
    border: Border(bottom: BorderSide(color: dividerColor, width: 1.0)),
  );
}
