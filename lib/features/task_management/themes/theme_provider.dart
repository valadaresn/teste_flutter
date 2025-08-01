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
  SidebarTheme _sidebarTheme =
      SidebarTheme.defaultTheme; // Nova propriedade para tema do sidebar
  BackgroundColorStyle _backgroundColorStyle =
      BackgroundColorStyle.listColor; // Nova propriedade para cor de fundo
  TodayCardStyle _todayCardStyle =
      TodayCardStyle.withEmoji; // Nova propriedade para estilo dos cards Hoje
  NavigationBarColorStyle _navigationBarColorStyle =
      NavigationBarColorStyle
          .systemTheme; // Nova propriedade para cor da barra de navegação
  SidebarColorStyle _sidebarColorStyle =
      SidebarColorStyle.samsungLight; // Nova propriedade para cor da sidebar

  // Novas propriedades para estilos de cards por visualização
  TaskCardStyle _todayViewCardStyle = TaskCardStyle.compact;
  TaskCardStyle _allTasksViewCardStyle = TaskCardStyle.standard;
  TaskCardStyle _listViewCardStyle = TaskCardStyle.standard;

  AppTheme get currentTheme => _currentTheme;
  ThemeConfig get themeConfig => _themeConfig;
  ListPanelStyle get listPanelStyle => _listPanelStyle; // Novo getter
  CardStyle get cardStyle => _cardStyle; // Novo getter para estilo de cards
  SidebarTheme get sidebarTheme =>
      _sidebarTheme; // Novo getter para tema do sidebar
  BackgroundColorStyle get backgroundColorStyle =>
      _backgroundColorStyle; // Novo getter para cor de fundo
  TodayCardStyle get todayCardStyle =>
      _todayCardStyle; // Novo getter para estilo dos cards Hoje
  NavigationBarColorStyle get navigationBarColorStyle =>
      _navigationBarColorStyle; // Novo getter para cor da barra de navegação
  SidebarColorStyle get sidebarColorStyle =>
      _sidebarColorStyle; // Novo getter para cor da sidebar

  // Novos getters para estilos de cards por visualização
  TaskCardStyle get todayViewCardStyle => _todayViewCardStyle;
  TaskCardStyle get allTasksViewCardStyle => _allTasksViewCardStyle;
  TaskCardStyle get listViewCardStyle => _listViewCardStyle;

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
      final sidebarThemeIndex = prefs.getInt(
        'sidebar_theme',
      ); // Carregar tema do sidebar
      final backgroundColorStyleIndex = prefs.getInt(
        'background_color_style',
      ); // Carregar preferência de cor de fundo
      final todayCardStyleIndex = prefs.getInt(
        'today_card_style',
      ); // Carregar preferência de estilo dos cards Hoje
      final navigationBarColorStyleIndex = prefs.getInt(
        'navigation_bar_color_style',
      ); // Carregar preferência de cor da barra de navegação
      final sidebarColorStyleIndex = prefs.getInt(
        'sidebar_color_style',
      ); // Carregar preferência de cor da sidebar

      // Carregar preferências dos novos estilos de cards por visualização
      final todayViewCardStyleIndex = prefs.getInt('today_view_card_style');
      final allTasksViewCardStyleIndex = prefs.getInt(
        'all_tasks_view_card_style',
      );
      final listViewCardStyleIndex = prefs.getInt('list_view_card_style');

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

      // Se há tema do sidebar salvo, aplicá-lo
      if (sidebarThemeIndex != null &&
          sidebarThemeIndex < SidebarTheme.values.length) {
        _sidebarTheme = SidebarTheme.values[sidebarThemeIndex];
      }

      // Se há preferência de cor de fundo salva, aplicá-la
      if (backgroundColorStyleIndex != null &&
          backgroundColorStyleIndex < BackgroundColorStyle.values.length) {
        _backgroundColorStyle =
            BackgroundColorStyle.values[backgroundColorStyleIndex];
      }

      // Se há preferência de estilo dos cards Hoje salva, aplicá-la
      if (todayCardStyleIndex != null &&
          todayCardStyleIndex < TodayCardStyle.values.length) {
        _todayCardStyle = TodayCardStyle.values[todayCardStyleIndex];
      }

      // Se há preferência de cor da barra de navegação salva, aplicá-la
      if (navigationBarColorStyleIndex != null &&
          navigationBarColorStyleIndex <
              NavigationBarColorStyle.values.length) {
        _navigationBarColorStyle =
            NavigationBarColorStyle.values[navigationBarColorStyleIndex];
      }

      // Se há preferência de cor da sidebar salva, aplicá-la
      if (sidebarColorStyleIndex != null &&
          sidebarColorStyleIndex < SidebarColorStyle.values.length) {
        _sidebarColorStyle = SidebarColorStyle.values[sidebarColorStyleIndex];
      }

      // Carregar preferências dos novos estilos de cards por visualização
      if (todayViewCardStyleIndex != null &&
          todayViewCardStyleIndex < TaskCardStyle.values.length) {
        _todayViewCardStyle = TaskCardStyle.values[todayViewCardStyleIndex];
      }

      if (allTasksViewCardStyleIndex != null &&
          allTasksViewCardStyleIndex < TaskCardStyle.values.length) {
        _allTasksViewCardStyle =
            TaskCardStyle.values[allTasksViewCardStyleIndex];
      }

      if (listViewCardStyleIndex != null &&
          listViewCardStyleIndex < TaskCardStyle.values.length) {
        _listViewCardStyle = TaskCardStyle.values[listViewCardStyleIndex];
      }

      notifyListeners(); // Notificar mudanças após carregar
    } catch (e) {
      // Se der erro, usar tema padrão
      _currentTheme = AppTheme.classic;
      _themeConfig = ThemeConfig.classic();
      _listPanelStyle = ListPanelStyle.compact; // Garantir padrão
      _cardStyle = CardStyle.dynamic; // Garantir padrão
      _sidebarTheme = SidebarTheme.defaultTheme; // Garantir padrão
      _backgroundColorStyle = BackgroundColorStyle.listColor; // Garantir padrão
      _todayCardStyle = TodayCardStyle.withEmoji; // Garantir padrão
      _navigationBarColorStyle =
          NavigationBarColorStyle.systemTheme; // Garantir padrão
      _sidebarColorStyle = SidebarColorStyle.samsungLight; // Garantir padrão
      // Garantir padrões para os novos estilos de cards
      _todayViewCardStyle = TaskCardStyle.compact;
      _allTasksViewCardStyle = TaskCardStyle.standard;
      _listViewCardStyle = TaskCardStyle.standard;
      notifyListeners(); // Notificar mudanças mesmo em caso de erro
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

  // Método para mudar tema do sidebar
  Future<void> setSidebarTheme(SidebarTheme theme, {bool save = true}) async {
    _sidebarTheme = theme;

    // AUTOMATICAMENTE mudar cor de fundo quando Samsung Notes for selecionado
    if (theme == SidebarTheme.samsungNotes) {
      _backgroundColorStyle = BackgroundColorStyle.samsungLight;
    } else if (theme == SidebarTheme.defaultTheme) {
      _backgroundColorStyle =
          BackgroundColorStyle.listColor; // Voltar ao padrão
    }

    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('sidebar_theme', theme.index);
        // Salvar também a cor de fundo que foi alterada automaticamente
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

  // Método para mudar cor de fundo
  Future<void> setBackgroundColorStyle(
    BackgroundColorStyle style, {
    bool save = true,
  }) async {
    _backgroundColorStyle = style;

    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('background_color_style', style.index);
      } catch (e) {
        // Ignorar erro de salvamento
      }
    }

    notifyListeners();
  }

  // Método para mudar estilo dos cards Hoje
  Future<void> setTodayCardStyle(
    TodayCardStyle style, {
    bool save = true,
  }) async {
    _todayCardStyle = style;

    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('today_card_style', style.index);
      } catch (e) {
        // Ignorar erro de salvamento
      }
    }

    notifyListeners();
  }

  // Método para mudar cor da barra de navegação
  Future<void> setNavigationBarColorStyle(
    NavigationBarColorStyle style, {
    bool save = true,
  }) async {
    _navigationBarColorStyle = style;

    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('navigation_bar_color_style', style.index);
      } catch (e) {
        // Ignorar erro de salvamento
      }
    }

    notifyListeners();
  }

  // Método para mudar cor da sidebar
  Future<void> setSidebarColorStyle(
    SidebarColorStyle style, {
    bool save = true,
  }) async {
    _sidebarColorStyle = style;

    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('sidebar_color_style', style.index);
      } catch (e) {
        // Ignorar erro de salvamento
      }
    }

    notifyListeners();
  }

  // Novos setters para estilos de cards por visualização
  Future<void> setTodayViewCardStyle(TaskCardStyle style) async {
    _todayViewCardStyle = style;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('today_view_card_style', style.index);
    } catch (e) {
      // Ignorar erro de salvamento
    }

    notifyListeners();
  }

  Future<void> setAllTasksViewCardStyle(TaskCardStyle style) async {
    _allTasksViewCardStyle = style;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('all_tasks_view_card_style', style.index);
    } catch (e) {
      // Ignorar erro de salvamento
    }

    notifyListeners();
  }

  Future<void> setListViewCardStyle(TaskCardStyle style) async {
    _listViewCardStyle = style;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('list_view_card_style', style.index);
    } catch (e) {
      // Ignorar erro de salvamento
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

  // Método para obter a cor de fundo com base na configuração
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

  // Método helper para obter cor da barra de navegação
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

  // Método helper para obter a cor da sidebar
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
