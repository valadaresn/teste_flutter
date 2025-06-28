import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeConfig {
  final AppTheme theme;
  final CardStyle cardStyle; // Nova propriedade
  final Color? cardColor;
  final Color? selectedCardColor;
  final Color? cardBorderColor;
  final Color? selectedCardBorderColor;
  final double cardBorderWidth;
  final double selectedCardBorderWidth;
  final double cardOpacity;
  final double selectedCardOpacity;
  final List<BoxShadow>? cardShadow;
  final List<BoxShadow>? selectedCardShadow;
  final double cardElevation;
  final double selectedCardElevation;
  final Gradient? cardGradient;
  final Gradient? selectedCardGradient;
  final double borderRadius;

  const ThemeConfig({
    required this.theme,
    required this.cardStyle, // Inicializa a nova propriedade
    this.cardColor,
    this.selectedCardColor,
    this.cardBorderColor,
    this.selectedCardBorderColor,
    this.cardBorderWidth = 1,
    this.selectedCardBorderWidth = 1,
    this.cardOpacity = 1.0,
    this.selectedCardOpacity = 1.0,
    this.cardShadow,
    this.selectedCardShadow,
    this.cardElevation = 0,
    this.selectedCardElevation = 0,
    this.cardGradient,
    this.selectedCardGradient,
    this.borderRadius = 8,
  });
  static ThemeConfig classic() {
    return const ThemeConfig(
      theme: AppTheme.classic,
      cardStyle: CardStyle.dynamic, // Estilo dinâmico (padrão atual)
      cardColor: Colors.white,
      selectedCardOpacity: 0.2,
      selectedCardBorderWidth: 1,
    );
  }

  static ThemeConfig glass() {
    return const ThemeConfig(
      theme: AppTheme.glass,
      cardStyle: CardStyle.dynamic, // Estilo dinâmico (padrão atual)
      cardOpacity: 0.15, // Todos os cards com glass
      selectedCardOpacity: 0.35, // Card selecionado mais intenso
      selectedCardBorderWidth: 2,
    );
  }

  static ThemeConfig modern() {
    return ThemeConfig(
      theme: AppTheme.modern,
      cardStyle: CardStyle.dynamic, // Estilo dinâmico (padrão atual)
      cardColor: Colors.white,
      selectedCardColor: Colors.white,
      cardElevation: 4,
      selectedCardElevation: 12,
      borderRadius: 12,
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.grey.shade50],
      ),
      selectedCardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.blue.shade50, Colors.indigo.shade50, Colors.white],
        stops: const [0.0, 0.3, 1.0],
      ),
      cardShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
      selectedCardShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      selectedCardBorderWidth: 2,
      selectedCardBorderColor: Colors.blue.shade200,
    );
  }

  // Novo factory method para tema clean
  static ThemeConfig clean() {
    return const ThemeConfig(
      theme: AppTheme.classic, // Usa base classic
      cardStyle: CardStyle.clean, // Estilo clean
      cardColor: null, // Usa background color do tema
      selectedCardColor: null, // Usa background color do tema
      cardBorderColor: null, // Usa dividerColor do tema
      selectedCardBorderColor: null, // Usa primary color do tema
      cardBorderWidth: 1,
      selectedCardBorderWidth: 2,
      cardOpacity: 1.0,
      selectedCardOpacity: 1.0,
      cardElevation: 0,
      selectedCardElevation: 0,
      cardGradient: null, // Sem gradientes no clean
      selectedCardGradient: null,
      borderRadius: 8,
    );
  }

  static ThemeConfig getConfig(AppTheme theme) {
    switch (theme) {
      case AppTheme.classic:
        return classic();
      case AppTheme.glass:
        return glass();
      case AppTheme.modern:
        return modern();
    }
  }
}
