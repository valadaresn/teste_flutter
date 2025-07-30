import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../../themes/theme_provider.dart';

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
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Tema do Painel Lateral'),
              _buildSidebarThemeSelector(context, themeProvider),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Cor de Fundo'),
              _buildBackgroundColorSelector(context, themeProvider),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Estilo dos Cards na Guia Hoje'),
              _buildTodayCardStyleSelector(context, themeProvider),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Cor da Barra de Navegação'),
              _buildNavigationBarColorSelector(context, themeProvider),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Cor do Painel Lateral'),
              _buildSidebarColorSelector(context, themeProvider),
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

  /// Constrói o seletor de tema do painel lateral
  Widget _buildSidebarThemeSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        _buildSidebarThemeOption(
          context,
          themeProvider,
          SidebarTheme.defaultTheme,
          'Padrão',
          'Painel colorido com emojis e elementos visuais',
          Icons.dashboard_outlined,
        ),
        _buildSidebarThemeOption(
          context,
          themeProvider,
          SidebarTheme.samsungNotes,
          'Samsung Notes',
          'Painel minimalista e clean estilo Samsung Notes',
          Icons.notes_outlined,
        ),
      ],
    );
  }

  /// Constrói uma opção de tema do sidebar
  Widget _buildSidebarThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    SidebarTheme sidebarTheme,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = themeProvider.sidebarTheme == sidebarTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color:
                isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing:
            isSelected
                ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
                : null,
        onTap: () async {
          await themeProvider.setSidebarTheme(sidebarTheme);

          // Mostrar feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tema do painel alterado para ${sidebarTheme.name}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  // ============================================================================
  // SELETOR DE COR DE FUNDO
  // ============================================================================

  Widget _buildBackgroundColorSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        // Opções de cor de fundo
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final style in BackgroundColorStyle.values)
              _buildBackgroundColorOption(context, themeProvider, style),
          ],
        ),
        const SizedBox(height: 16),
        // Visualização da cor atual
        _buildBackgroundColorPreview(context, themeProvider),
      ],
    );
  }

  Widget _buildBackgroundColorOption(
    BuildContext context,
    ThemeProvider themeProvider,
    BackgroundColorStyle colorStyle,
  ) {
    final isSelected = themeProvider.backgroundColorStyle == colorStyle;

    return InkWell(
      onTap: () async {
        try {
          await themeProvider.setBackgroundColorStyle(colorStyle);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cor de fundo alterada para ${colorStyle.name}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao alterar cor de fundo'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Preview da cor
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getPreviewColor(colorStyle),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            const SizedBox(height: 8),
            // Nome da opção
            Text(
              colorStyle.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            // Descrição
            Text(
              colorStyle.description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundColorPreview(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: themeProvider.getBackgroundColor(
          context,
          listColor: Colors.blue, // Exemplo para demonstração
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Visualização da cor de fundo',
              style: TextStyle(
                color:
                    themeProvider.backgroundColorStyle ==
                            BackgroundColorStyle.white
                        ? Colors.black87
                        : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              themeProvider.backgroundColorStyle.name,
              style: TextStyle(
                color:
                    themeProvider.backgroundColorStyle ==
                            BackgroundColorStyle.white
                        ? Colors.black54
                        : Colors.black38,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // SELETOR DE ESTILO DOS CARDS HOJE
  // ============================================================================

  Widget _buildTodayCardStyleSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        // Opções de estilo dos cards Hoje
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final style in TodayCardStyle.values)
              _buildTodayCardStyleOption(context, themeProvider, style),
          ],
        ),
        const SizedBox(height: 16),
        // Visualização do estilo atual
        _buildTodayCardStylePreview(context, themeProvider),
      ],
    );
  }

  Widget _buildTodayCardStyleOption(
    BuildContext context,
    ThemeProvider themeProvider,
    TodayCardStyle cardStyle,
  ) {
    final isSelected = themeProvider.todayCardStyle == cardStyle;

    return InkWell(
      onTap: () async {
        try {
          await themeProvider.setTodayCardStyle(cardStyle);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Estilo dos cards Hoje alterado para ${cardStyle.name}',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao alterar estilo dos cards Hoje'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Preview do estilo
            _buildTodayCardMiniPreview(cardStyle),
            const SizedBox(height: 8),
            // Nome da opção
            Text(
              cardStyle.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            // Descrição
            Text(
              cardStyle.description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCardMiniPreview(TodayCardStyle style) {
    switch (style) {
      case TodayCardStyle.withEmoji:
        return Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('📋', style: TextStyle(fontSize: 14)),
              SizedBox(width: 4),
              Text('Tarefa', style: TextStyle(fontSize: 10)),
            ],
          ),
        );
      case TodayCardStyle.withColorBorder:
        return Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text('Tarefa', style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildTodayCardStylePreview(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visualização dos cards na guia Hoje:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _buildTodayCardFullPreview(themeProvider.todayCardStyle),
        ],
      ),
    );
  }

  Widget _buildTodayCardFullPreview(TodayCardStyle style) {
    switch (style) {
      case TodayCardStyle.withEmoji:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: const Row(
            children: [
              Text('📋', style: TextStyle(fontSize: 18)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exemplo de tarefa para hoje',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Lista: Trabalho',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case TodayCardStyle.withColorBorder:
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exemplo de tarefa para hoje',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Lista: Trabalho',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
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

  // ============================================================================
  // SELETOR DE COR DA BARRA DE NAVEGAÇÃO
  // ============================================================================

  Widget _buildNavigationBarColorSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        // Opções de cor da barra de navegação
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final style in NavigationBarColorStyle.values)
              _buildNavigationBarColorOption(context, themeProvider, style),
          ],
        ),
        const SizedBox(height: 16),
        // Visualização da cor atual
        _buildNavigationBarColorPreview(context, themeProvider),
      ],
    );
  }

  Widget _buildNavigationBarColorOption(
    BuildContext context,
    ThemeProvider themeProvider,
    NavigationBarColorStyle colorStyle,
  ) {
    final isSelected = themeProvider.navigationBarColorStyle == colorStyle;

    return InkWell(
      onTap: () async {
        try {
          await themeProvider.setNavigationBarColorStyle(colorStyle);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Cor da barra de navegação alterada para ${colorStyle.name}',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao alterar cor da barra de navegação'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Preview da cor
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getNavigationBarPreviewColor(colorStyle),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            const SizedBox(height: 8),
            // Nome da opção
            Text(
              colorStyle.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            // Descrição
            Text(
              colorStyle.description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBarColorPreview(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: themeProvider.getNavigationBarColor(
          context,
          listColor: Colors.blue, // Exemplo para demonstração
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simular ícones da barra de navegação
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.task_alt, size: 20),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.note, size: 20),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.fitness_center, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            'Visualização: ${themeProvider.navigationBarColorStyle.name}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getNavigationBarPreviewColor(NavigationBarColorStyle style) {
    switch (style) {
      case NavigationBarColorStyle.systemTheme:
        return Colors.grey.shade100;
      case NavigationBarColorStyle.samsungLight:
        return const Color(0xFFF5F5F5);
      case NavigationBarColorStyle.white:
        return Colors.white;
      case NavigationBarColorStyle.listColor:
        return Colors.blue.withOpacity(0.15);
      case NavigationBarColorStyle.dark:
        return const Color(0xFF2B2B2B);
    }
  }

  // ============================================================================
  // SELETOR DE COR DA SIDEBAR
  // ============================================================================

  Widget _buildSidebarColorSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        // Opções de cor da sidebar
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final style in SidebarColorStyle.values)
              _buildSidebarColorOption(context, themeProvider, style),
          ],
        ),
        const SizedBox(height: 16),
        // Visualização da cor atual
        _buildSidebarColorPreview(context, themeProvider),
      ],
    );
  }

  Widget _buildSidebarColorOption(
    BuildContext context,
    ThemeProvider themeProvider,
    SidebarColorStyle colorStyle,
  ) {
    final isSelected = themeProvider.sidebarColorStyle == colorStyle;

    return InkWell(
      onTap: () async {
        try {
          await themeProvider.setSidebarColorStyle(colorStyle);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Cor do painel lateral alterada para ${colorStyle.name}',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao alterar cor do painel lateral'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Preview da cor
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getSidebarPreviewColor(colorStyle),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            const SizedBox(height: 8),
            // Nome da opção
            Text(
              colorStyle.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            // Descrição
            Text(
              colorStyle.description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarColorPreview(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: themeProvider.getSidebarColor(
          context,
          listColor: Colors.blue, // Exemplo para demonstração
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simular itens da sidebar
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.today_outlined, size: 20),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.star_border_outlined, size: 20),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.folder_outlined, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            'Visualização: ${themeProvider.sidebarColorStyle.name}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getSidebarPreviewColor(SidebarColorStyle style) {
    switch (style) {
      case SidebarColorStyle.systemTheme:
        return Colors.grey.shade100;
      case SidebarColorStyle.samsungLight:
        return const Color(0xFFF5F5F5);
      case SidebarColorStyle.white:
        return Colors.white;
      case SidebarColorStyle.listColor:
        return Colors.blue.withOpacity(0.15);
      case SidebarColorStyle.dark:
        return const Color(0xFF2B2B2B);
    }
  }

  Color _getPreviewColor(BackgroundColorStyle style) {
    switch (style) {
      case BackgroundColorStyle.listColor:
        return Colors.blue.withOpacity(0.1);
      case BackgroundColorStyle.samsungLight:
        return SamsungNotesColors.backgroundColor;
      case BackgroundColorStyle.white:
        return Colors.white;
      case BackgroundColorStyle.systemTheme:
        return Colors.grey.shade100;
    }
  }
}
