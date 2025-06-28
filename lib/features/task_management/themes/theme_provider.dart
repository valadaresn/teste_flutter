import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'theme_config.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.classic;
  ThemeConfig _themeConfig = ThemeConfig.classic();
  ListPanelStyle _listPanelStyle = ListPanelStyle.compact; // Nova propriedade
  CardStyle _cardStyle =
      CardStyle.dynamic; // Nova propriedade para estilo de cards

  AppTheme get currentTheme => _currentTheme;
  ThemeConfig get themeConfig => _themeConfig;
  ListPanelStyle get listPanelStyle => _listPanelStyle; // Novo getter
  CardStyle get cardStyle => _cardStyle; // Novo getter para estilo de cards

  ThemeProvider() {
    _loadTheme();
  }
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('app_theme') ?? 0;
      final listStyleIndex = prefs.getInt(
        'list_panel_style',
      ); // Carregar estilo de lista
      final cardStyleIndex = prefs.getInt(
        'card_style',
      ); // Carregar estilo de cards

      final theme = AppTheme.values[themeIndex];
      await setTheme(theme, save: false);

      // Se há estilo de lista salvo, aplicá-lo
      if (listStyleIndex != null &&
          listStyleIndex < ListPanelStyle.values.length) {
        _listPanelStyle = ListPanelStyle.values[listStyleIndex];
      }

      // Se há estilo de cards salvo, aplicá-lo
      if (cardStyleIndex != null && cardStyleIndex < CardStyle.values.length) {
        _cardStyle = CardStyle.values[cardStyleIndex];
      }
    } catch (e) {
      // Se der erro, usar tema padrão
      _currentTheme = AppTheme.classic;
      _themeConfig = ThemeConfig.classic();
      _listPanelStyle = ListPanelStyle.compact; // Garantir padrão
      _cardStyle = CardStyle.dynamic; // Garantir padrão
    }
  }

  Future<void> setTheme(AppTheme theme, {bool save = true}) async {
    _currentTheme = theme;
    _themeConfig = ThemeConfig.getConfig(theme);

    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('app_theme', theme.index);
      } catch (e) {
        // Ignorar erro de salvamento
      }
    }

    notifyListeners();
  }

  // Método para mudar apenas o estilo da lista
  Future<void> setListPanelStyle(
    ListPanelStyle style, {
    bool save = true,
  }) async {
    _listPanelStyle = style;

    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('list_panel_style', style.index);
      } catch (e) {
        // Ignorar erro de salvamento
      }
    }

    notifyListeners();
  }

  // Método para mudar estilo de cards
  Future<void> setCardStyle(CardStyle style, {bool save = true}) async {
    _cardStyle = style;

    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('card_style', style.index);
      } catch (e) {
        // Ignorar erro de salvamento
      }
    }

    notifyListeners();
  }

  // Métodos helper para facilitar o uso
  Color getCardColor(bool isSelected) {
    if (isSelected) {
      return _themeConfig.selectedCardColor ??
          Colors.white.withOpacity(_themeConfig.selectedCardOpacity);
    }
    return _themeConfig.cardColor ??
        Colors.white.withOpacity(_themeConfig.cardOpacity);
  }

  Color getCardBorderColor(bool isSelected, Color listColor) {
    if (isSelected) {
      return _themeConfig.selectedCardBorderColor ??
          Colors.white.withOpacity(0.6);
    }
    return _themeConfig.cardBorderColor ?? Colors.grey.shade200;
  }

  double getCardBorderWidth(bool isSelected) {
    return isSelected
        ? _themeConfig.selectedCardBorderWidth
        : _themeConfig.cardBorderWidth;
  }

  List<BoxShadow>? getCardShadow(bool isSelected) {
    return isSelected
        ? _themeConfig.selectedCardShadow
        : _themeConfig.cardShadow;
  }

  double getCardElevation(bool isSelected) {
    return isSelected
        ? _themeConfig.selectedCardElevation
        : _themeConfig.cardElevation;
  }

  Gradient? getCardGradient(bool isSelected) {
    return isSelected
        ? _themeConfig.selectedCardGradient
        : _themeConfig.cardGradient;
  }

  double getBorderRadius() {
    return _themeConfig.borderRadius;
  }
}
