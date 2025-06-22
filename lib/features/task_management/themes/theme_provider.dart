import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'theme_config.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.classic;
  ThemeConfig _themeConfig = ThemeConfig.classic();

  AppTheme get currentTheme => _currentTheme;
  ThemeConfig get themeConfig => _themeConfig;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('app_theme') ?? 0;
      final theme = AppTheme.values[themeIndex];
      await setTheme(theme, save: false);
    } catch (e) {
      // Se der erro, usar tema padrão
      _currentTheme = AppTheme.classic;
      _themeConfig = ThemeConfig.classic();
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
