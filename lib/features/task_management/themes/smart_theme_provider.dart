// ============================================================================
// CONFIGURAÇÕES INTELIGENTES POR PADRÃO - SOLUÇÃO PARA REINSTALAÇÃO
// ============================================================================
// Esta abordagem configura defaults inteligentes baseados no contexto do
// usuário, reduzindo a necessidade de reconfiguração após reinstalação.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class SmartThemeProvider extends ChangeNotifier {
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

  bool _isFirstLaunch = true;
  bool get isFirstLaunch => _isFirstLaunch;

  // Getters existentes...
  SidebarTheme get sidebarTheme => _sidebarTheme;
  BackgroundColorStyle get backgroundColorStyle => _backgroundColorStyle;
  TodayCardStyle get todayCardStyle => _todayCardStyle;
  NavigationBarColorStyle get navigationBarColorStyle =>
      _navigationBarColorStyle;
  SidebarColorStyle get sidebarColorStyle => _sidebarColorStyle;
  TaskCardStyle get todayViewCardStyle => _todayViewCardStyle;
  TaskCardStyle get allTasksViewCardStyle => _allTasksViewCardStyle;
  TaskCardStyle get listViewCardStyle => _listViewCardStyle;

  SmartThemeProvider() {
    _initializeSmartDefaults();
  }

  /// Inicializa com configurações inteligentes baseadas no contexto
  Future<void> _initializeSmartDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Verifica se é primeira vez usando o app
      _isFirstLaunch = !prefs.containsKey('has_launched_before');

      if (_isFirstLaunch) {
        // PRIMEIRA INSTALAÇÃO - Configurar defaults inteligentes
        await _setupSmartDefaults(prefs);
      } else {
        // JÁ TEVE CONFIGURAÇÕES - Carregar normalmente
        await _loadExistingSettings(prefs);
      }

      notifyListeners();
    } catch (e) {
      // Em caso de erro, usar defaults seguros
      await _useFailsafeDefaults();
    }
  }

  /// Configura defaults inteligentes na primeira instalação
  Future<void> _setupSmartDefaults(SharedPreferences prefs) async {
    // 🎯 DEFAULTS INTELIGENTES BASEADOS NO CONTEXTO

    // 1. Detectar preferência do usuário baseado no sistema
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isSystemDark = brightness == Brightness.dark;

    // 2. Configurar tema baseado no sistema
    if (isSystemDark) {
      _sidebarTheme = SidebarTheme.samsungNotes; // Mais clean para modo escuro
      _backgroundColorStyle = BackgroundColorStyle.systemTheme;
      _navigationBarColorStyle = NavigationBarColorStyle.dark;
      _sidebarColorStyle = SidebarColorStyle.dark;
    } else {
      _sidebarTheme = SidebarTheme.defaultTheme; // Colorido para modo claro
      _backgroundColorStyle = BackgroundColorStyle.listColor;
      _navigationBarColorStyle = NavigationBarColorStyle.systemTheme;
      _sidebarColorStyle = SidebarColorStyle.samsungLight;
    }

    // 3. Cards compactos por padrão (melhor para mobile)
    _todayViewCardStyle = TaskCardStyle.compact;
    _allTasksViewCardStyle = TaskCardStyle.compact;
    _listViewCardStyle = TaskCardStyle.compact;

    // 4. Estilo dos cards hoje com emoji (mais visual)
    _todayCardStyle = TodayCardStyle.withEmoji;

    // 5. Salvar configurações inteligentes
    await _saveCurrentSettings(prefs);

    // 6. Marcar que não é mais primeira vez
    await prefs.setBool('has_launched_before', true);
    await prefs.setString('smart_setup_date', DateTime.now().toIso8601String());

    _isFirstLaunch = false;
  }

  /// Carrega configurações existentes (comportamento normal)
  Future<void> _loadExistingSettings(SharedPreferences prefs) async {
    // Carregar normalmente como fazia antes
    final sidebarThemeIndex = prefs.getInt('sidebar_theme');
    final backgroundColorStyleIndex = prefs.getInt('background_color_style');
    final todayCardStyleIndex = prefs.getInt('today_card_style');
    final navigationBarColorStyleIndex = prefs.getInt(
      'navigation_bar_color_style',
    );
    final sidebarColorStyleIndex = prefs.getInt('sidebar_color_style');
    final todayViewCardStyleIndex = prefs.getInt('today_view_card_style');
    final allTasksViewCardStyleIndex = prefs.getInt(
      'all_tasks_view_card_style',
    );
    final listViewCardStyleIndex = prefs.getInt('list_view_card_style');

    // Aplicar configurações salvas
    if (sidebarThemeIndex != null &&
        sidebarThemeIndex < SidebarTheme.values.length) {
      _sidebarTheme = SidebarTheme.values[sidebarThemeIndex];
    }

    if (backgroundColorStyleIndex != null &&
        backgroundColorStyleIndex < BackgroundColorStyle.values.length) {
      _backgroundColorStyle =
          BackgroundColorStyle.values[backgroundColorStyleIndex];
    }

    if (todayCardStyleIndex != null &&
        todayCardStyleIndex < TodayCardStyle.values.length) {
      _todayCardStyle = TodayCardStyle.values[todayCardStyleIndex];
    }

    if (navigationBarColorStyleIndex != null &&
        navigationBarColorStyleIndex < NavigationBarColorStyle.values.length) {
      _navigationBarColorStyle =
          NavigationBarColorStyle.values[navigationBarColorStyleIndex];
    }

    if (sidebarColorStyleIndex != null &&
        sidebarColorStyleIndex < SidebarColorStyle.values.length) {
      _sidebarColorStyle = SidebarColorStyle.values[sidebarColorStyleIndex];
    }

    if (todayViewCardStyleIndex != null &&
        todayViewCardStyleIndex < TaskCardStyle.values.length) {
      _todayViewCardStyle = TaskCardStyle.values[todayViewCardStyleIndex];
    }

    if (allTasksViewCardStyleIndex != null &&
        allTasksViewCardStyleIndex < TaskCardStyle.values.length) {
      _allTasksViewCardStyle = TaskCardStyle.values[allTasksViewCardStyleIndex];
    }

    if (listViewCardStyleIndex != null &&
        listViewCardStyleIndex < TaskCardStyle.values.length) {
      _listViewCardStyle = TaskCardStyle.values[listViewCardStyleIndex];
    }
  }

  /// Salva todas as configurações atuais
  Future<void> _saveCurrentSettings(SharedPreferences prefs) async {
    await prefs.setInt('sidebar_theme', _sidebarTheme.index);
    await prefs.setInt('background_color_style', _backgroundColorStyle.index);
    await prefs.setInt('today_card_style', _todayCardStyle.index);
    await prefs.setInt(
      'navigation_bar_color_style',
      _navigationBarColorStyle.index,
    );
    await prefs.setInt('sidebar_color_style', _sidebarColorStyle.index);
    await prefs.setInt('today_view_card_style', _todayViewCardStyle.index);
    await prefs.setInt(
      'all_tasks_view_card_style',
      _allTasksViewCardStyle.index,
    );
    await prefs.setInt('list_view_card_style', _listViewCardStyle.index);
  }

  /// Defaults seguros em caso de erro
  Future<void> _useFailsafeDefaults() async {
    _sidebarTheme = SidebarTheme.defaultTheme;
    _backgroundColorStyle = BackgroundColorStyle.listColor;
    _todayCardStyle = TodayCardStyle.withEmoji;
    _navigationBarColorStyle = NavigationBarColorStyle.systemTheme;
    _sidebarColorStyle = SidebarColorStyle.samsungLight;
    _todayViewCardStyle = TaskCardStyle.compact;
    _allTasksViewCardStyle = TaskCardStyle.standard;
    _listViewCardStyle = TaskCardStyle.standard;
    _isFirstLaunch = false;
  }

  // ============================================================================
  // MÉTODOS PARA MOSTRAR TUTORIAL/ONBOARDING BASEADO EM PRIMEIRA INSTALAÇÃO
  // ============================================================================

  /// Verifica se deve mostrar tutorial de configurações
  bool shouldShowConfigurationTutorial() {
    return _isFirstLaunch;
  }

  /// Marca tutorial como visualizado
  Future<void> markTutorialAsViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tutorial_viewed', true);
    } catch (e) {
      // Ignore error
    }
  }

  // ============================================================================
  // SEUS SETTERS EXISTENTES (mantidos iguais)
  // ============================================================================

  Future<void> setSidebarTheme(SidebarTheme theme, {bool save = true}) async {
    _sidebarTheme = theme;

    if (theme == SidebarTheme.samsungNotes) {
      _backgroundColorStyle = BackgroundColorStyle.samsungLight;
    } else if (theme == SidebarTheme.defaultTheme) {
      _backgroundColorStyle = BackgroundColorStyle.listColor;
    }

    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('sidebar_theme', theme.index);
        await prefs.setInt(
          'background_color_style',
          _backgroundColorStyle.index,
        );
      } catch (e) {
        // Ignorar erro de salvamento
      }
    }

    notifyListeners();
  }

  // ... (resto dos seus setters mantidos iguais)

  // Métodos helper para cores mantidos iguais...
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
