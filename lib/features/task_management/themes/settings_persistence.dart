// ============================================================================
// SERVIÇO DE PERSISTÊNCIA DAS CONFIGURAÇÕES - CENTRALIZADOR
// ============================================================================
// Este serviço centraliza toda a lógica de persistência das configurações,
// oferecendo uma interface limpa para salvar/carregar configurações e
// permitindo futuras expansões (como backup na nuvem).
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Serviço responsável por persistir e carregar configurações do app
class SettingsPersistenceService {
  static const String _kSidebarTheme = 'sidebar_theme';
  static const String _kBackgroundColorStyle = 'background_color_style';
  static const String _kTodayCardStyle = 'today_card_style';
  static const String _kNavigationBarColorStyle = 'navigation_bar_color_style';
  static const String _kSidebarColorStyle = 'sidebar_color_style';
  static const String _kTodayViewCardStyle = 'today_view_card_style';
  static const String _kAllTasksViewCardStyle = 'all_tasks_view_card_style';
  static const String _kListViewCardStyle = 'list_view_card_style';

  /// Modelo para todas as configurações do app
  static const String _kLastSavedVersion = 'settings_version';
  static const int _currentVersion = 1;

  /// Carrega todas as configurações salvas
  static Future<Map<String, dynamic>> loadAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'sidebarTheme': _loadEnum<SidebarTheme>(
          prefs,
          _kSidebarTheme,
          SidebarTheme.values,
          SidebarTheme.defaultTheme,
        ),
        'backgroundColorStyle': _loadEnum<BackgroundColorStyle>(
          prefs,
          _kBackgroundColorStyle,
          BackgroundColorStyle.values,
          BackgroundColorStyle.listColor,
        ),
        'todayCardStyle': _loadEnum<TodayCardStyle>(
          prefs,
          _kTodayCardStyle,
          TodayCardStyle.values,
          TodayCardStyle.withEmoji,
        ),
        'navigationBarColorStyle': _loadEnum<NavigationBarColorStyle>(
          prefs,
          _kNavigationBarColorStyle,
          NavigationBarColorStyle.values,
          NavigationBarColorStyle.systemTheme,
        ),
        'sidebarColorStyle': _loadEnum<SidebarColorStyle>(
          prefs,
          _kSidebarColorStyle,
          SidebarColorStyle.values,
          SidebarColorStyle.samsungLight,
        ),
        'todayViewCardStyle': _loadEnum<TaskCardStyle>(
          prefs,
          _kTodayViewCardStyle,
          TaskCardStyle.values,
          TaskCardStyle.compact,
        ),
        'allTasksViewCardStyle': _loadEnum<TaskCardStyle>(
          prefs,
          _kAllTasksViewCardStyle,
          TaskCardStyle.values,
          TaskCardStyle.standard,
        ),
        'listViewCardStyle': _loadEnum<TaskCardStyle>(
          prefs,
          _kListViewCardStyle,
          TaskCardStyle.values,
          TaskCardStyle.standard,
        ),
      };
    } catch (e) {
      // Retorna configurações padrão em caso de erro
      return _getDefaultSettings();
    }
  }

  /// Salva uma configuração específica
  static Future<bool> saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is Enum) {
        await prefs.setInt(key, value.index);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else {
        return false; // Tipo não suportado
      }

      // Atualiza versão das configurações
      await prefs.setInt(_kLastSavedVersion, _currentVersion);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Salva múltiplas configurações de uma vez (batch save)
  static Future<bool> saveMultipleSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (final entry in settings.entries) {
        final key = _getKeyForSetting(entry.key);
        if (key != null) {
          if (entry.value is Enum) {
            await prefs.setInt(key, entry.value.index);
          } else if (entry.value is int) {
            await prefs.setInt(key, entry.value);
          } else if (entry.value is String) {
            await prefs.setString(key, entry.value);
          } else if (entry.value is bool) {
            await prefs.setBool(key, entry.value);
          }
        }
      }

      await prefs.setInt(_kLastSavedVersion, _currentVersion);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reseta todas as configurações para os valores padrão
  static Future<bool> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove todas as chaves de configuração
      final keys = [
        _kSidebarTheme,
        _kBackgroundColorStyle,
        _kTodayCardStyle,
        _kNavigationBarColorStyle,
        _kSidebarColorStyle,
        _kTodayViewCardStyle,
        _kAllTasksViewCardStyle,
        _kListViewCardStyle,
      ];

      for (final key in keys) {
        await prefs.remove(key);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se as configurações foram migradas para a versão atual
  static Future<bool> needsMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVersion = prefs.getInt(_kLastSavedVersion) ?? 0;
      return savedVersion < _currentVersion;
    } catch (e) {
      return true; // Assume que precisa de migração se der erro
    }
  }

  // ============================================================================
  // MÉTODOS HELPER PRIVADOS
  // ============================================================================

  /// Carrega um enum de forma segura
  static T _loadEnum<T extends Enum>(
    SharedPreferences prefs,
    String key,
    List<T> values,
    T defaultValue,
  ) {
    final index = prefs.getInt(key);
    if (index != null && index >= 0 && index < values.length) {
      return values[index];
    }
    return defaultValue;
  }

  /// Retorna configurações padrão
  static Map<String, dynamic> _getDefaultSettings() {
    return {
      'sidebarTheme': SidebarTheme.defaultTheme,
      'backgroundColorStyle': BackgroundColorStyle.listColor,
      'todayCardStyle': TodayCardStyle.withEmoji,
      'navigationBarColorStyle': NavigationBarColorStyle.systemTheme,
      'sidebarColorStyle': SidebarColorStyle.samsungLight,
      'todayViewCardStyle': TaskCardStyle.compact,
      'allTasksViewCardStyle': TaskCardStyle.standard,
      'listViewCardStyle': TaskCardStyle.standard,
    };
  }

  /// Mapeia nomes de configuração para chaves do SharedPreferences
  static String? _getKeyForSetting(String settingName) {
    switch (settingName) {
      case 'sidebarTheme':
        return _kSidebarTheme;
      case 'backgroundColorStyle':
        return _kBackgroundColorStyle;
      case 'todayCardStyle':
        return _kTodayCardStyle;
      case 'navigationBarColorStyle':
        return _kNavigationBarColorStyle;
      case 'sidebarColorStyle':
        return _kSidebarColorStyle;
      case 'todayViewCardStyle':
        return _kTodayViewCardStyle;
      case 'allTasksViewCardStyle':
        return _kAllTasksViewCardStyle;
      case 'listViewCardStyle':
        return _kListViewCardStyle;
      default:
        return null;
    }
  }

  // ============================================================================
  // MÉTODOS DE CONVENIÊNCIA PARA CONFIGURAÇÕES ESPECÍFICAS
  // ============================================================================

  static Future<bool> saveSidebarTheme(SidebarTheme theme) =>
      saveSetting(_kSidebarTheme, theme);

  static Future<bool> saveBackgroundColorStyle(BackgroundColorStyle style) =>
      saveSetting(_kBackgroundColorStyle, style);

  static Future<bool> saveTodayCardStyle(TodayCardStyle style) =>
      saveSetting(_kTodayCardStyle, style);

  static Future<bool> saveNavigationBarColorStyle(
    NavigationBarColorStyle style,
  ) => saveSetting(_kNavigationBarColorStyle, style);

  static Future<bool> saveSidebarColorStyle(SidebarColorStyle style) =>
      saveSetting(_kSidebarColorStyle, style);

  static Future<bool> saveTodayViewCardStyle(TaskCardStyle style) =>
      saveSetting(_kTodayViewCardStyle, style);

  static Future<bool> saveAllTasksViewCardStyle(TaskCardStyle style) =>
      saveSetting(_kAllTasksViewCardStyle, style);

  static Future<bool> saveListViewCardStyle(TaskCardStyle style) =>
      saveSetting(_kListViewCardStyle, style);
}
