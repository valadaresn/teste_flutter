// ============================================================================
// TELA PRINCIPAL DE CONFIGURAÇÕES - ORQUESTRADOR MODULAR
// ============================================================================
// Este arquivo é o orquestrador principal que combina todos os componentes
// modulares de configuração em uma única tela organizada. Cada seção é um
// componente independente importado dos arquivos separados.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_provider.dart';
import 'task_card_style_settings.dart'; // Configurações de estilo dos cards de tarefas
import 'sidebar_theme_settings.dart'; // Configurações de tema da sidebar
import 'background_color_settings.dart'; // Configurações de cor de fundo
import 'today_card_style_settings.dart'; // Configurações de estilo dos cards da view "hoje"
import 'navigation_bar_color_settings.dart'; // Configurações de cor da barra de navegação
import 'sidebar_color_settings.dart'; // Configurações de cor da sidebar
import 'about_settings.dart'; // Seção sobre o aplicativo
import 'settings_helper.dart'; // Utilitários compartilhados para UI

/// ============================================================================
/// SETTINGS SCREEN - Tela principal de configurações modular
/// ============================================================================
/// Esta classe é o orquestrador que combina todos os componentes modulares de
/// configuração. Reduzido de 1000+ linhas para apenas ~70 linhas através da
/// modularização em componentes especializados.
/// ============================================================================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Task Card Style
              SettingsHelper.buildSectionHeader(
                context,
                'Estilo dos Cards por Visualização',
              ),
              TaskCardStyleSettings(themeProvider: themeProvider),
              SettingsHelper.buildSectionSeparator(),

              // Sidebar Theme
              SettingsHelper.buildSectionHeader(
                context,
                'Tema do Painel Lateral',
              ),
              SidebarThemeSettings(themeProvider: themeProvider),
              SettingsHelper.buildSectionSeparator(),

              // Background Color
              SettingsHelper.buildSectionHeader(context, 'Cor de Fundo'),
              BackgroundColorSettings(themeProvider: themeProvider),
              SettingsHelper.buildSectionSeparator(),

              // Today Card Style
              SettingsHelper.buildSectionHeader(
                context,
                'Estilo dos Cards na Guia Hoje',
              ),
              TodayCardStyleSettings(themeProvider: themeProvider),
              SettingsHelper.buildSectionSeparator(),

              // Navigation Bar Color
              SettingsHelper.buildSectionHeader(
                context,
                'Cor da Barra de Navegação',
              ),
              NavigationBarColorSettings(themeProvider: themeProvider),
              SettingsHelper.buildSectionSeparator(),

              // Sidebar Color
              SettingsHelper.buildSectionHeader(
                context,
                'Cor do Painel Lateral',
              ),
              SidebarColorSettings(themeProvider: themeProvider),
              SettingsHelper.buildSectionSeparator(),

              // About
              SettingsHelper.buildSectionHeader(context, 'Sobre'),
              const AboutSettings(),
            ],
          );
        },
      ),
    );
  }
}
