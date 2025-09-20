// ============================================================================
// VERSÃO OTIMIZADA DO THEME PROVIDER (OPCIONAL)
// ============================================================================
// Esta versão usa o SettingsPersistenceService para centralizar a persistência
// e oferece melhor performance e organização. Você pode usar esta versão ou
// manter a atual - ambas funcionam perfeitamente!
// ============================================================================

import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'settings_persistence.dart';

class ThemeProviderOptimized extends ChangeNotifier {
  // Estados das configurações
  SidebarTheme _sidebarTheme = SidebarTheme.defaultTheme;
  BackgroundColorStyle _backgroundColorStyle = BackgroundColorStyle.listColor;
  TodayCardStyle _todayCardStyle = TodayCardStyle.withEmoji;
  NavigationBarColorStyle _navigationBarColorStyle =
      NavigationBarColorStyle.systemTheme;
  SidebarColorStyle _sidebarColorStyle = SidebarColorStyle.samsungLight;
  TaskCardStyle _todayViewCardStyle = TaskCardStyle.compact;
  TaskCardStyle _allTasksViewCardStyle = TaskCardStyle.standard;
  TaskCardStyle _listViewCardStyle = TaskCardStyle.standard;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Getters
  SidebarTheme get sidebarTheme => _sidebarTheme;
  BackgroundColorStyle get backgroundColorStyle => _backgroundColorStyle;
  TodayCardStyle get todayCardStyle => _todayCardStyle;
  NavigationBarColorStyle get navigationBarColorStyle =>
      _navigationBarColorStyle;
  SidebarColorStyle get sidebarColorStyle => _sidebarColorStyle;
  TaskCardStyle get todayViewCardStyle => _todayViewCardStyle;
  TaskCardStyle get allTasksViewCardStyle => _allTasksViewCardStyle;
  TaskCardStyle get listViewCardStyle => _listViewCardStyle;

  ThemeProviderOptimized() {
    _loadSettings();
  }

  /// Carrega todas as configurações de uma vez
  Future<void> _loadSettings() async {
    try {
      final settings = await SettingsPersistenceService.loadAllSettings();

      _sidebarTheme = settings['sidebarTheme'];
      _backgroundColorStyle = settings['backgroundColorStyle'];
      _todayCardStyle = settings['todayCardStyle'];
      _navigationBarColorStyle = settings['navigationBarColorStyle'];
      _sidebarColorStyle = settings['sidebarColorStyle'];
      _todayViewCardStyle = settings['todayViewCardStyle'];
      _allTasksViewCardStyle = settings['allTasksViewCardStyle'];
      _listViewCardStyle = settings['listViewCardStyle'];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Usar configurações padrão em caso de erro
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reseta todas as configurações
  Future<void> resetSettings() async {
    final success = await SettingsPersistenceService.resetToDefaults();
    if (success) {
      _loadSettings(); // Recarrega para aplicar padrões
    }
  }

  // ============================================================================
  // SETTERS COM PERSISTÊNCIA OTIMIZADA
  // ============================================================================

  Future<void> setSidebarTheme(SidebarTheme theme, {bool save = true}) async {
    _sidebarTheme = theme;

    // Auto-ajuste da cor de fundo baseado no tema
    if (theme == SidebarTheme.samsungNotes) {
      _backgroundColorStyle = BackgroundColorStyle.samsungLight;
    } else if (theme == SidebarTheme.defaultTheme) {
      _backgroundColorStyle = BackgroundColorStyle.listColor;
    }

    if (save) {
      // Salva ambos os valores de uma vez (batch save)
      await SettingsPersistenceService.saveMultipleSettings({
        'sidebarTheme': theme,
        'backgroundColorStyle': _backgroundColorStyle,
      });
    }

    notifyListeners();
  }

  Future<void> setBackgroundColorStyle(
    BackgroundColorStyle style, {
    bool save = true,
  }) async {
    _backgroundColorStyle = style;

    if (save) {
      await SettingsPersistenceService.saveBackgroundColorStyle(style);
    }

    notifyListeners();
  }

  Future<void> setTodayCardStyle(
    TodayCardStyle style, {
    bool save = true,
  }) async {
    _todayCardStyle = style;

    if (save) {
      await SettingsPersistenceService.saveTodayCardStyle(style);
    }

    notifyListeners();
  }

  Future<void> setNavigationBarColorStyle(
    NavigationBarColorStyle style, {
    bool save = true,
  }) async {
    _navigationBarColorStyle = style;

    if (save) {
      await SettingsPersistenceService.saveNavigationBarColorStyle(style);
    }

    notifyListeners();
  }

  Future<void> setSidebarColorStyle(
    SidebarColorStyle style, {
    bool save = true,
  }) async {
    _sidebarColorStyle = style;

    if (save) {
      await SettingsPersistenceService.saveSidebarColorStyle(style);
    }

    notifyListeners();
  }

  Future<void> setTodayViewCardStyle(TaskCardStyle style) async {
    _todayViewCardStyle = style;
    await SettingsPersistenceService.saveTodayViewCardStyle(style);
    notifyListeners();
  }

  Future<void> setAllTasksViewCardStyle(TaskCardStyle style) async {
    _allTasksViewCardStyle = style;
    await SettingsPersistenceService.saveAllTasksViewCardStyle(style);
    notifyListeners();
  }

  Future<void> setListViewCardStyle(TaskCardStyle style) async {
    _listViewCardStyle = style;
    await SettingsPersistenceService.saveListViewCardStyle(style);
    notifyListeners();
  }

  // ============================================================================
  // MÉTODOS HELPER PARA CORES (MANTIDOS IGUAIS)
  // ============================================================================

  Color getBackgroundColor(BuildContext context, {Color? listColor}) {
    switch (_backgroundColorStyle) {
      case BackgroundColorStyle.listColor:
        return listColor?.withOpacity(0.1) ??
            Theme.of(context).scaffoldBackgroundColor;
      case BackgroundColorStyle.samsungLight:
        return SamsungNotesColors.backgroundColor;
      case BackgroundColorStyle.white:
        return Colors.white;
      case BackgroundColorStyle.systemTheme:
        return Theme.of(context).scaffoldBackgroundColor;
    }
  }

  Color getNavigationBarColor(BuildContext context, {Color? listColor}) {
    switch (_navigationBarColorStyle) {
      case NavigationBarColorStyle.systemTheme:
        return Theme.of(context).colorScheme.surface;
      case NavigationBarColorStyle.samsungLight:
        return const Color(0xFFF5F5F5);
      case NavigationBarColorStyle.white:
        return Colors.white;
      case NavigationBarColorStyle.listColor:
        return listColor?.withOpacity(0.15) ??
            Theme.of(context).colorScheme.surface;
      case NavigationBarColorStyle.dark:
        return const Color(0xFF2B2B2B);
    }
  }

  Color getSidebarColor(BuildContext context, {Color? listColor}) {
    switch (_sidebarColorStyle) {
      case SidebarColorStyle.systemTheme:
        return Theme.of(context).colorScheme.surface;
      case SidebarColorStyle.samsungLight:
        return const Color(0xFFF5F5F5);
      case SidebarColorStyle.white:
        return Colors.white;
      case SidebarColorStyle.listColor:
        return listColor?.withOpacity(0.15) ??
            Theme.of(context).colorScheme.surface;
      case SidebarColorStyle.dark:
        return const Color(0xFF2B2B2B);
    }
  }
}
