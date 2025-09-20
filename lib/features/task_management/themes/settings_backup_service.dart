// ============================================================================
// SISTEMA DE BACKUP/RESTORE DAS CONFIGURAÇÕES (VERSÃO SIMPLES)
// ============================================================================
// Permite ao usuário fazer backup das configurações usando apenas Flutter
// básico, sem dependências extras. Resolve problema de reinstalação.
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBackupService {
  static const String _backupFileName = 'task_manager_settings.json';
  static const int _currentBackupVersion = 1;

  /// Cria backup das configurações atuais
  static Future<Map<String, dynamic>> createBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final backup = {
        'backup_version': _currentBackupVersion,
        'backup_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0', // Você pode pegar da package_info
        'settings': {
          'sidebar_theme': prefs.getInt('sidebar_theme'),
          'background_color_style': prefs.getInt('background_color_style'),
          'today_card_style': prefs.getInt('today_card_style'),
          'navigation_bar_color_style': prefs.getInt(
            'navigation_bar_color_style',
          ),
          'sidebar_color_style': prefs.getInt('sidebar_color_style'),
          'today_view_card_style': prefs.getInt('today_view_card_style'),
          'all_tasks_view_card_style': prefs.getInt(
            'all_tasks_view_card_style',
          ),
          'list_view_card_style': prefs.getInt('list_view_card_style'),
        },
      };

      return backup;
    } catch (e) {
      throw Exception('Erro ao criar backup: $e');
    }
  }

  /// Salva backup em arquivo e permite compartilhar
  static Future<String> exportBackupToFile() async {
    try {
      final backup = await createBackup();
      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);

      // Salvar em arquivo temporário
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_backupFileName');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw Exception('Erro ao exportar backup: $e');
    }
  }

  /// Copia backup para clipboard (funciona sem dependências extras)
  static Future<void> copyBackupToClipboard() async {
    try {
      final quickBackup = await createQuickBackupString();

      await Clipboard.setData(
        ClipboardData(text: 'TaskManager_Config:$quickBackup'),
      );
    } catch (e) {
      throw Exception('Erro ao copiar backup: $e');
    }
  }

  /// Restaura backup a partir do clipboard
  static Future<bool> restoreFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      final text = clipboardData?.text;

      if (text == null || !text.startsWith('TaskManager_Config:')) {
        throw Exception('Backup não encontrado no clipboard');
      }

      final quickBackup = text.substring('TaskManager_Config:'.length);
      return await restoreFromQuickString(quickBackup);
    } catch (e) {
      throw Exception('Erro ao restaurar do clipboard: $e');
    }
  }

  /// Restaura configurações a partir de um backup
  static Future<bool> restoreFromBackup(Map<String, dynamic> backup) async {
    try {
      // Validar formato do backup
      if (!_isValidBackup(backup)) {
        throw Exception('Formato de backup inválido');
      }

      final prefs = await SharedPreferences.getInstance();
      final settings = backup['settings'] as Map<String, dynamic>;

      // Restaurar cada configuração
      for (final entry in settings.entries) {
        final value = entry.value;
        if (value != null && value is int) {
          await prefs.setInt(entry.key, value);
        }
      }

      // Marcar data da restauração
      await prefs.setString(
        'last_restore_date',
        DateTime.now().toIso8601String(),
      );

      return true;
    } catch (e) {
      throw Exception('Erro ao restaurar backup: $e');
    }
  }

  /// Valida se o backup tem formato correto
  static bool _isValidBackup(Map<String, dynamic> backup) {
    try {
      // Verificar estrutura básica
      if (!backup.containsKey('backup_version') ||
          !backup.containsKey('settings')) {
        return false;
      }

      final settings = backup['settings'] as Map<String, dynamic>?;
      if (settings == null) return false;

      // Verificar se tem pelo menos algumas configurações essenciais
      final requiredKeys = [
        'sidebar_theme',
        'background_color_style',
        'today_card_style',
      ];

      for (final key in requiredKeys) {
        if (!settings.containsKey(key)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cria backup rápido em string (para QR Code, etc)
  static Future<String> createQuickBackupString() async {
    try {
      final backup = await createBackup();
      final settings = backup['settings'] as Map<String, dynamic>;

      // Formato compacto: "v1|0|1|2|0|1|1|0|0" (versão|config1|config2|etc)
      final values = [
        _currentBackupVersion,
        settings['sidebar_theme'] ?? 0,
        settings['background_color_style'] ?? 0,
        settings['today_card_style'] ?? 0,
        settings['navigation_bar_color_style'] ?? 0,
        settings['sidebar_color_style'] ?? 0,
        settings['today_view_card_style'] ?? 0,
        settings['all_tasks_view_card_style'] ?? 0,
        settings['list_view_card_style'] ?? 0,
      ];

      return values.join('|');
    } catch (e) {
      throw Exception('Erro ao criar backup rápido: $e');
    }
  }

  /// Restaura a partir de string rápida
  static Future<bool> restoreFromQuickString(String quickBackup) async {
    try {
      final parts = quickBackup.split('|');

      if (parts.length != 9) {
        throw Exception('Formato de backup inválido');
      }

      final version = int.parse(parts[0]);
      if (version > _currentBackupVersion) {
        throw Exception('Versão de backup não suportada');
      }

      final prefs = await SharedPreferences.getInstance();

      // Mapear posições para chaves
      final keyMap = [
        'sidebar_theme',
        'background_color_style',
        'today_card_style',
        'navigation_bar_color_style',
        'sidebar_color_style',
        'today_view_card_style',
        'all_tasks_view_card_style',
        'list_view_card_style',
      ];

      // Restaurar configurações
      for (int i = 0; i < keyMap.length; i++) {
        final value = int.parse(parts[i + 1]); // +1 porque parts[0] é a versão
        await prefs.setInt(keyMap[i], value);
      }

      await prefs.setString(
        'last_restore_date',
        DateTime.now().toIso8601String(),
      );

      return true;
    } catch (e) {
      throw Exception('Erro ao restaurar backup rápido: $e');
    }
  }

  /// Verifica se existe backup automatico local
  static Future<bool> hasLocalBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_backupFileName');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Cria backup automático local (diário/semanal)
  static Future<void> createAutoBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastBackup = prefs.getString('last_auto_backup');
      final now = DateTime.now();

      // Verificar se já fez backup hoje
      if (lastBackup != null) {
        final lastBackupDate = DateTime.parse(lastBackup);
        final difference = now.difference(lastBackupDate).inDays;

        if (difference < 7) {
          // Backup automático semanal
          return;
        }
      }

      // Criar backup automático
      await exportBackupToFile();
      await prefs.setString('last_auto_backup', now.toIso8601String());
    } catch (e) {
      // Ignore erros de backup automático
    }
  }
}
