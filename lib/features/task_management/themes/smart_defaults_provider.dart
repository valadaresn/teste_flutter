// ============================================================================
// SISTEMA DE DEFAULTS INTELIGENTES SIMPLES
// ============================================================================
// Aplica automaticamente as configurações ideais na primeira instalação
// baseado no que foi mostrado nas imagens das configurações.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class SmartDefaultsProvider extends ChangeNotifier {
  // Configurações atuais
  SidebarTheme _sidebarTheme = SidebarTheme.samsungNotes;
  BackgroundColorStyle _backgroundColorStyle = BackgroundColorStyle.systemTheme;
  TodayCardStyle _todayCardStyle = TodayCardStyle.withColorBorder;
  NavigationBarColorStyle _navigationBarColorStyle =
      NavigationBarColorStyle.systemTheme;
  SidebarColorStyle _sidebarColorStyle = SidebarColorStyle.systemTheme;

  // Cards compactos para todas as visualizações (conforme imagens)
  TaskCardStyle _todayViewCardStyle = TaskCardStyle.compact;
  TaskCardStyle _allTasksViewCardStyle = TaskCardStyle.compact;
  TaskCardStyle _listViewCardStyle = TaskCardStyle.compact;

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

  SmartDefaultsProvider() {
    _initializeWithSmartDefaults();
  }

  /// Inicializa com defaults inteligentes ou carrega configurações existentes
  Future<void> _initializeWithSmartDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasLaunchedBefore =
          prefs.getBool('app_configured_with_defaults') ?? false;

      if (!hasLaunchedBefore) {
        // ✨ PRIMEIRA INSTALAÇÃO - APLICAR DEFAULTS DAS IMAGENS
        await _applySmartDefaults(prefs);
        await prefs.setBool('app_configured_with_defaults', true);
        debugPrint(
          '🎯 Defaults inteligentes aplicados na primeira instalação!',
        );
      } else {
        // ♻️ CARREGA CONFIGURAÇÕES EXISTENTES
        await _loadExistingSettings(prefs);
        debugPrint('📱 Configurações existentes carregadas');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao inicializar defaults: $e');
    }
  }

  /// Aplica as configurações ideais baseadas nas imagens
  Future<void> _applySmartDefaults(SharedPreferences prefs) async {
    // 🎨 CONFIGURAÇÕES DAS IMAGENS:

    // 1. Cards COMPACTOS para todas as visualizações
    _todayViewCardStyle = TaskCardStyle.compact;
    _allTasksViewCardStyle = TaskCardStyle.compact;
    _listViewCardStyle = TaskCardStyle.compact;

    // 2. Painel Samsung Notes (minimalista)
    _sidebarTheme = SidebarTheme.samsungNotes;

    // 3. Tema do Sistema para cores (segue tema claro/escuro do dispositivo)
    _backgroundColorStyle = BackgroundColorStyle.systemTheme;
    _navigationBarColorStyle = NavigationBarColorStyle.systemTheme;
    _sidebarColorStyle = SidebarColorStyle.systemTheme;

    // 4. Cards na guia Hoje com borda colorida
    _todayCardStyle = TodayCardStyle.withColorBorder;

    // 💾 SALVA TODAS AS CONFIGURAÇÕES
    await _saveCurrentSettings(prefs);

    debugPrint('✅ Defaults aplicados:');
    debugPrint('   • Cards: Compactos em todas as telas');
    debugPrint('   • Painel: Samsung Notes (minimalista)');
    debugPrint('   • Cores: Seguem o tema do sistema');
    debugPrint('   • Guia Hoje: Borda colorida');
  }

  /// Carrega configurações salvas anteriormente
  Future<void> _loadExistingSettings(SharedPreferences prefs) async {
    _sidebarTheme =
        SidebarTheme.values[prefs.getInt('sidebar_theme') ??
            SidebarTheme.samsungNotes.index];

    _backgroundColorStyle =
        BackgroundColorStyle.values[prefs.getInt('background_color_style') ??
            BackgroundColorStyle.systemTheme.index];

    _todayCardStyle =
        TodayCardStyle.values[prefs.getInt('today_card_style') ??
            TodayCardStyle.withColorBorder.index];

    _navigationBarColorStyle =
        NavigationBarColorStyle.values[prefs.getInt(
              'navigation_bar_color_style',
            ) ??
            NavigationBarColorStyle.systemTheme.index];

    _sidebarColorStyle =
        SidebarColorStyle.values[prefs.getInt('sidebar_color_style') ??
            SidebarColorStyle.systemTheme.index];

    _todayViewCardStyle =
        TaskCardStyle.values[prefs.getInt('today_view_card_style') ??
            TaskCardStyle.compact.index];

    _allTasksViewCardStyle =
        TaskCardStyle.values[prefs.getInt('all_tasks_view_card_style') ??
            TaskCardStyle.compact.index];

    _listViewCardStyle =
        TaskCardStyle.values[prefs.getInt('list_view_card_style') ??
            TaskCardStyle.compact.index];
  }

  /// Salva todas as configurações no SharedPreferences
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

  // ============================================================================
  // MÉTODOS PARA MODIFICAR CONFIGURAÇÕES (mesma interface do ThemeProvider)
  // ============================================================================

  /// Atualiza tema do sidebar
  Future<void> updateSidebarTheme(SidebarTheme theme) async {
    if (_sidebarTheme != theme) {
      _sidebarTheme = theme;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('sidebar_theme', theme.index);
      notifyListeners();
    }
  }

  /// Atualiza estilo de cor de fundo
  Future<void> updateBackgroundColorStyle(BackgroundColorStyle style) async {
    if (_backgroundColorStyle != style) {
      _backgroundColorStyle = style;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('background_color_style', style.index);
      notifyListeners();
    }
  }

  /// Atualiza estilo dos cards da guia Hoje
  Future<void> updateTodayCardStyle(TodayCardStyle style) async {
    if (_todayCardStyle != style) {
      _todayCardStyle = style;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('today_card_style', style.index);
      notifyListeners();
    }
  }

  /// Atualiza cor da barra de navegação
  Future<void> updateNavigationBarColorStyle(
    NavigationBarColorStyle style,
  ) async {
    if (_navigationBarColorStyle != style) {
      _navigationBarColorStyle = style;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('navigation_bar_color_style', style.index);
      notifyListeners();
    }
  }

  /// Atualiza cor da sidebar
  Future<void> updateSidebarColorStyle(SidebarColorStyle style) async {
    if (_sidebarColorStyle != style) {
      _sidebarColorStyle = style;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('sidebar_color_style', style.index);
      notifyListeners();
    }
  }

  /// Atualiza estilo dos cards na visualização Hoje
  Future<void> updateTodayViewCardStyle(TaskCardStyle style) async {
    if (_todayViewCardStyle != style) {
      _todayViewCardStyle = style;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('today_view_card_style', style.index);
      notifyListeners();
    }
  }

  /// Atualiza estilo dos cards na visualização Todas as Tarefas
  Future<void> updateAllTasksViewCardStyle(TaskCardStyle style) async {
    if (_allTasksViewCardStyle != style) {
      _allTasksViewCardStyle = style;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('all_tasks_view_card_style', style.index);
      notifyListeners();
    }
  }

  /// Atualiza estilo dos cards na visualização de Lista
  Future<void> updateListViewCardStyle(TaskCardStyle style) async {
    if (_listViewCardStyle != style) {
      _listViewCardStyle = style;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('list_view_card_style', style.index);
      notifyListeners();
    }
  }

  // ============================================================================
  // MÉTODOS DE UTILIDADE
  // ============================================================================

  /// Reseta todas as configurações para os defaults inteligentes
  Future<void> resetToSmartDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await _applySmartDefaults(prefs);
    notifyListeners();
    debugPrint('🔄 Configurações resetadas para defaults inteligentes');
  }

  /// Verifica se é a primeira vez que o app foi aberto
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('app_configured_with_defaults') ?? false);
  }

  /// Marca que o tutorial foi visualizado (se necessário)
  Future<void> markTutorialAsViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_viewed', true);
  }
}
