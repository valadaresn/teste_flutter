import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../themes/theme_provider.dart';

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
            children: [
              _buildSectionHeader(context, 'Aparência'),
              _buildThemeSelector(context, themeProvider),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Estilo do Painel de Lista'),
              _buildListStyleSelector(context, themeProvider),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Estilo de Tarefas'),
              _buildCardStyleSelector(context, themeProvider),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Sobre'),
              _buildAboutSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        _buildThemeOption(
          context,
          themeProvider,
          AppTheme.classic,
          'Clássico',
          'Cartões sólidos com efeito glass na seleção',
          Icons.credit_card,
        ),
        _buildThemeOption(
          context,
          themeProvider,
          AppTheme.glass,
          'Glass',
          'Todos os cartões com efeito glass, seleção mais intensa',
          Icons.filter_none,
        ),
        _buildThemeOption(
          context,
          themeProvider,
          AppTheme.modern,
          'Moderno',
          'Cartões elevados com gradientes e sombras',
          Icons.gradient,
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    AppTheme theme,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = themeProvider.currentTheme == theme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          size: 28,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing:
            isSelected
                ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
                : const Icon(Icons.radio_button_unchecked),
        onTap: () => themeProvider.setTheme(theme),
      ),
    );
  }

  Widget _buildListStyleSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        _buildListStyleOption(
          context,
          themeProvider,
          ListPanelStyle.compact,
          'Compacto',
          'Layout minimalista com animações e borda lateral',
          Icons.view_headline,
        ),
        _buildListStyleOption(
          context,
          themeProvider,
          ListPanelStyle.decorated,
          'Decorado',
          'Visual moderno com ícones destacados estilo Monday.com',
          Icons.view_module,
        ),
      ],
    );
  }

  Widget _buildListStyleOption(
    BuildContext context,
    ThemeProvider themeProvider,
    ListPanelStyle style,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = themeProvider.listPanelStyle == style;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          size: 28,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing:
            isSelected
                ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
                : const Icon(Icons.radio_button_unchecked),
        onTap: () => themeProvider.setListPanelStyle(style),
      ),
    );
  }

  // Novo método para seletor de estilo de cards
  Widget _buildCardStyleSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        _buildCardStyleOption(
          context,
          themeProvider,
          CardStyle.dynamic,
          'Dinâmico',
          'Cards mudam de cor conforme a lista selecionada',
          Icons.palette,
        ),
        _buildCardStyleOption(
          context,
          themeProvider,
          CardStyle.clean,
          'Clean',
          'Design minimalista com cor de fundo constante',
          Icons.format_color_reset,
        ),
      ],
    );
  }

  Widget _buildCardStyleOption(
    BuildContext context,
    ThemeProvider themeProvider,
    CardStyle style,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = themeProvider.cardStyle == style;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          size: 28,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing:
            isSelected
                ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
                : const Icon(Icons.radio_button_unchecked),
        onTap: () => themeProvider.setCardStyle(style),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.task_alt,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Task Manager',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Uma aplicação de gerenciamento de tarefas inspirada no Microsoft To Do e TickTick.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Chip(
                        label: const Text('Flutter'),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: const Text('Provider'),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: const Text('Firebase'),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.tertiary.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
