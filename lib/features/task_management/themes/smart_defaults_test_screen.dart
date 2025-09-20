// ============================================================================
// WIDGET PARA TESTAR OS DEFAULTS INTELIGENTES
// ============================================================================
// Widget simples para demonstrar como o sistema de defaults funciona
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'smart_defaults_provider.dart';
import 'app_theme.dart';

class SmartDefaultsTestScreen extends StatelessWidget {
  const SmartDefaultsTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SmartDefaultsProvider(),
      child: Consumer<SmartDefaultsProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('🎯 Defaults Inteligentes'),
              backgroundColor: _getAppBarColor(provider),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Aplicar Defaults Novamente',
                  onPressed: () async {
                    await provider.resetToSmartDefaults();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Defaults aplicados!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            backgroundColor: _getBackgroundColor(provider, context),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Status dos defaults
                _buildStatusCard(provider),
                const SizedBox(height: 16),

                // Preview das configurações aplicadas
                _buildConfigPreview(provider),
                const SizedBox(height: 16),

                // Demo dos cards por visualização
                _buildCardsDemo(provider),
                const SizedBox(height: 16),

                // Comparação visual
                _buildComparisonCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getAppBarColor(SmartDefaultsProvider provider) {
    switch (provider.navigationBarColorStyle) {
      case NavigationBarColorStyle.systemTheme:
        return Colors.blue; // Tema do sistema
      case NavigationBarColorStyle.samsungLight:
        return Colors.grey[100]!;
      case NavigationBarColorStyle.white:
        return Colors.white;
      case NavigationBarColorStyle.dark:
        return Colors.grey[900]!;
      case NavigationBarColorStyle.listColor:
        return Colors.purple; // Simulando cor da lista
    }
  }

  Color _getBackgroundColor(
    SmartDefaultsProvider provider,
    BuildContext context,
  ) {
    switch (provider.backgroundColorStyle) {
      case BackgroundColorStyle.systemTheme:
        return Theme.of(context).scaffoldBackgroundColor;
      case BackgroundColorStyle.samsungLight:
        return Colors.grey[50]!;
      case BackgroundColorStyle.white:
        return Colors.white;
      case BackgroundColorStyle.listColor:
        return Colors.purple[50]!; // Simulando cor da lista
    }
  }

  Widget _buildStatusCard(SmartDefaultsProvider provider) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  '✅ Defaults Aplicados com Sucesso!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<bool>(
              future: provider.isFirstLaunch(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final isFirst = !snapshot.data!;
                  return Text(
                    isFirst
                        ? '🎯 Primeira instalação: Configurações das imagens aplicadas automaticamente!'
                        : '♻️ App já configurado anteriormente. Configurações carregadas.',
                    style: const TextStyle(color: Colors.green),
                  );
                }
                return const Text('Verificando status...');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigPreview(SmartDefaultsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎨 Configurações Aplicadas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildConfigItem(
              '📱 Cards por Visualização',
              'Hoje: ${_getCardStyleName(provider.todayViewCardStyle)}\n'
                  'Todas Tarefas: ${_getCardStyleName(provider.allTasksViewCardStyle)}\n'
                  'Lista: ${_getCardStyleName(provider.listViewCardStyle)}',
              Icons.view_module,
            ),

            _buildConfigItem(
              '🎨 Tema do Painel',
              _getSidebarThemeName(provider.sidebarTheme),
              Icons.menu,
            ),

            _buildConfigItem(
              '🌈 Cor de Fundo',
              _getBackgroundStyleName(provider.backgroundColorStyle),
              Icons.color_lens,
            ),

            _buildConfigItem(
              '📋 Cards da Guia Hoje',
              _getTodayCardStyleName(provider.todayCardStyle),
              Icons.today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(value, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsDemo(SmartDefaultsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎮 Preview dos Cards:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Demo card compacto (aplicado em todas as visualizações)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border:
                    provider.todayCardStyle == TodayCardStyle.withColorBorder
                        ? Border(left: BorderSide(color: Colors.blue, width: 4))
                        : null,
              ),
              child: Row(
                children: [
                  if (provider.todayCardStyle == TodayCardStyle.withEmoji)
                    const Text('📝 ', style: TextStyle(fontSize: 16)),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exemplo de Tarefa',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Card compacto aplicado em todas as visualizações',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_outline, color: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '✅ ${_getCardStyleName(provider.todayViewCardStyle)} aplicado em: Hoje, Todas Tarefas, Lista',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard() {
    return Card(
      color: Colors.blue[50],
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '📊 Comparação: Antes vs Depois',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '❌ ANTES: Usuário perde TODAS as configurações ao reinstalar\n'
              '✅ DEPOIS: App já vem configurado conforme as imagens\n\n'
              '• Cards compactos já aplicados\n'
              '• Tema Samsung Notes já ativo\n'
              '• Cores seguem o sistema automaticamente\n'
              '• Bordas coloridas na guia Hoje',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _getCardStyleName(TaskCardStyle style) {
    return style == TaskCardStyle.compact ? 'Compacto' : 'Padrão';
  }

  String _getSidebarThemeName(SidebarTheme theme) {
    return theme == SidebarTheme.samsungNotes ? 'Samsung Notes' : 'Padrão';
  }

  String _getBackgroundStyleName(BackgroundColorStyle style) {
    switch (style) {
      case BackgroundColorStyle.systemTheme:
        return 'Tema do Sistema';
      case BackgroundColorStyle.samsungLight:
        return 'Samsung Light';
      case BackgroundColorStyle.white:
        return 'Branco';
      case BackgroundColorStyle.listColor:
        return 'Cor da Lista';
    }
  }

  String _getTodayCardStyleName(TodayCardStyle style) {
    return style == TodayCardStyle.withColorBorder
        ? 'Com Borda Colorida'
        : 'Com Emoji';
  }
}
