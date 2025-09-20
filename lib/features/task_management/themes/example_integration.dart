// ============================================================================
// EXEMPLO DE INTEGRAÇÃO - SMART DEFAULTS PROVIDER
// ============================================================================
// Como substituir o ThemeProvider atual pelo SmartDefaultsProvider
// para aplicar automaticamente as configurações das imagens na primeira instalação
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'smart_defaults_provider.dart';
import 'app_theme.dart';

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // 🎯 SUBSTITUA ThemeProvider() por SmartDefaultsProvider()
      create: (context) => SmartDefaultsProvider(),
      child: Consumer<SmartDefaultsProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Task Manager',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(brightness: Brightness.dark),
            // A detecção automática do tema do sistema funcionará
            // porque configuramos BackgroundColorStyle.systemTheme
            themeMode: ThemeMode.system,
            home: const ExampleSettingsScreen(),
          );
        },
      ),
    );
  }
}

class ExampleSettingsScreen extends StatelessWidget {
  const ExampleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações com Defaults Inteligentes'),
        actions: [
          // Botão para resetar para defaults
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Restaurar Defaults',
            onPressed: () async {
              final provider = Provider.of<SmartDefaultsProvider>(
                context,
                listen: false,
              );
              await provider.resetToSmartDefaults();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '✅ Configurações restauradas para os defaults inteligentes!',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<SmartDefaultsProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status da primeira instalação
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Status dos Defaults Inteligentes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<bool>(
                        future: provider.isFirstLaunch(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final isFirst = snapshot.data!;
                            return Text(
                              isFirst
                                  ? '🎯 Este é o primeiro uso! Defaults aplicados automaticamente.'
                                  : '♻️ Configurações personalizadas carregadas.',
                              style: const TextStyle(color: Colors.blue),
                            );
                          }
                          return const Text('Carregando...');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Configurações atuais aplicadas
              const Text(
                '🎨 Configurações Aplicadas:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _buildConfigCard(
                '📱 Estilo dos Cards',
                'Compacto em todas as visualizações',
                '${provider.todayViewCardStyle.name} • ${provider.allTasksViewCardStyle.name} • ${provider.listViewCardStyle.name}',
              ),

              _buildConfigCard(
                '🎨 Tema do Painel',
                provider.sidebarTheme.name,
                provider.sidebarTheme == SidebarTheme.samsungNotes
                    ? 'Clean e minimalista'
                    : 'Colorido com emojis',
              ),

              _buildConfigCard(
                '🌈 Cores de Fundo',
                provider.backgroundColorStyle.name,
                'Segue automaticamente o tema do sistema',
              ),

              _buildConfigCard(
                '📋 Cards da Guia Hoje',
                provider.todayCardStyle.name,
                provider.todayCardStyle.description,
              ),

              const SizedBox(height: 24),

              // Botão para acessar configurações completas
              ElevatedButton.icon(
                onPressed: () {
                  // Aqui você navegaria para a tela de configurações completa
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '🎛️ Aqui você abriria a tela de configurações completa',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('Personalizar Configurações'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConfigCard(String title, String value, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// INSTRUÇÕES DE USO:
// ============================================================================
/*

1. SUBSTITUIR O PROVIDER ATUAL:
   No seu main.dart ou onde você configura o Provider, substitua:
   
   DE:   ChangeNotifierProvider(create: (context) => ThemeProvider())
   PARA: ChangeNotifierProvider(create: (context) => SmartDefaultsProvider())

2. COMPATIBILIDADE:
   O SmartDefaultsProvider tem TODOS os métodos do ThemeProvider original,
   então não precisa mudar nada no resto do código.

3. RESULTADO:
   - Na primeira instalação: Defaults das imagens aplicados automaticamente
   - Instalações seguintes: Configurações salvas são carregadas normalmente
   - Usuário pode personalizar depois se quiser

4. DEFAULTS APLICADOS:
   ✅ Cards: Compactos em "Hoje", "Todas Tarefas", "Visualização de Lista"
   ✅ Painel: Samsung Notes (minimalista) 
   ✅ Cores: Tema do Sistema (detecta claro/escuro automaticamente)
   ✅ Guia Hoje: Cards com borda colorida

*/
