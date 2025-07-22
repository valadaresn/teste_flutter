import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_provider.dart';
import '../../themes/app_theme.dart';
import '../common/sidebar_theme_toggle.dart';

/// Exemplo de como integrar o sistema de temas do sidebar
///
/// Este widget demonstra todas as funcionalidades implementadas
class SidebarThemeDemo extends StatelessWidget {
  const SidebarThemeDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo - Temas do Sidebar'),
        actions: [
          // Widget de alternância rápida
          const SidebarThemeToggle(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return Column(
            children: [
              // Status atual
              _buildCurrentStatus(context, themeProvider),

              // Botões de teste
              _buildTestButtons(context, themeProvider),

              // Preview do sidebar
              Expanded(
                child: Row(
                  children: [
                    // Mostra o sidebar atual
                    _buildSidebarPreview(context, themeProvider),

                    // Área principal
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.background,
                        child: const Center(
                          child: Text(
                            'Área Principal\n\nAlterne os temas para ver a diferença no painel lateral',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentStatus(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tema Atual do Sidebar',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                themeProvider.sidebarTheme == SidebarTheme.samsungNotes
                    ? Icons.notes_outlined
                    : Icons.dashboard_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                themeProvider.sidebarTheme.name,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            themeProvider.sidebarTheme.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButtons(BuildContext context, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await themeProvider.setSidebarTheme(SidebarTheme.defaultTheme);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tema alterado para Padrão'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.dashboard_outlined),
              label: const Text('Tema Padrão'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    themeProvider.sidebarTheme == SidebarTheme.defaultTheme
                        ? Theme.of(context).colorScheme.primary
                        : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await themeProvider.setSidebarTheme(SidebarTheme.samsungNotes);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tema alterado para Samsung Notes'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notes_outlined),
              label: const Text('Samsung Notes'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    themeProvider.sidebarTheme == SidebarTheme.samsungNotes
                        ? Theme.of(context).colorScheme.primary
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarPreview(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Text(
              'Preview do Sidebar',
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              color:
                  themeProvider.sidebarTheme == SidebarTheme.samsungNotes
                      ? const Color(0xFFF5F5F5) // Samsung Notes background
                      : Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  _buildPreviewItem(
                    context,
                    'Hoje',
                    Icons.today_outlined,
                    3,
                    false,
                    themeProvider.sidebarTheme == SidebarTheme.samsungNotes,
                  ),
                  _buildPreviewItem(
                    context,
                    'Importantes',
                    Icons.star_border_outlined,
                    1,
                    true,
                    themeProvider.sidebarTheme == SidebarTheme.samsungNotes,
                  ),
                  _buildPreviewItem(
                    context,
                    'Projetos',
                    Icons.folder_outlined,
                    5,
                    false,
                    themeProvider.sidebarTheme == SidebarTheme.samsungNotes,
                  ),
                  if (themeProvider.sidebarTheme == SidebarTheme.samsungNotes)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: _buildPreviewItem(
                        context,
                        'Lista de Tarefas',
                        Icons.list_alt_outlined,
                        2,
                        false,
                        true,
                        isNested: true,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(
    BuildContext context,
    String title,
    IconData icon,
    int count,
    bool isSelected,
    bool isSamsungStyle, {
    bool isNested = false,
  }) {
    final backgroundColor =
        isSelected
            ? (isSamsungStyle
                ? const Color(0xFFE8E8E8)
                : Theme.of(context).colorScheme.primaryContainer)
            : null;

    final textColor =
        isSamsungStyle
            ? const Color(0xFF303030)
            : Theme.of(context).colorScheme.onSurface;

    final counterColor =
        isSamsungStyle
            ? const Color(0xFF8E8E8E)
            : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      margin: EdgeInsets.only(left: isNested ? 16 : 0, right: 4, bottom: 1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: isSamsungStyle ? BorderRadius.circular(4) : null,
      ),
      child: ListTile(
        dense: !isSamsungStyle,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSamsungStyle ? 16 : 12,
          vertical: isSamsungStyle ? 10 : 4,
        ),
        leading: Icon(
          icon,
          color: isSamsungStyle ? const Color(0xFF666666) : textColor,
          size: isSamsungStyle ? 20 : 18,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: isSamsungStyle ? 14 : null,
            fontWeight: isSamsungStyle ? FontWeight.w400 : null,
          ),
        ),
        trailing:
            count > 0
                ? Text(
                  count.toString(),
                  style: TextStyle(
                    color: counterColor,
                    fontSize: isSamsungStyle ? 14 : 12,
                  ),
                )
                : null,
      ),
    );
  }
}
