// ============================================================================
// CONFIGURAÇÕES DE ESTILO DOS CARDS NA GUIA HOJE
// ============================================================================
// Este componente permite escolher como os cards de tarefas são exibidos na
// tela "Hoje":
// - Com Emoji: Mostra o emoji da lista em cada tarefa
// - Com Borda Colorida: Mostra uma borda colorida à esquerda em cada tarefa
// ============================================================================

import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../../themes/theme_provider.dart';

/// ============================================================================
/// TODAY CARD STYLE SETTINGS - Configurações de estilo dos cards na guia hoje
/// ============================================================================
/// Permite configurar como os cards de tarefas são exibidos especificamente
/// na visualização "Hoje". Opções de diferenciação visual:
/// - Com Emoji: Exibe o emoji da lista associada em cada card de tarefa
/// - Com Borda Colorida: Exibe uma borda lateral colorida baseada na lista
/// ============================================================================
class TodayCardStyleSettings extends StatelessWidget {
  final ThemeProvider themeProvider;

  const TodayCardStyleSettings({Key? key, required this.themeProvider})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estilo dos Cards na Guia Hoje',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Escolha como os cards de tarefas são exibidos na tela Hoje',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children:
                TodayCardStyle.values.map((style) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildTodayCardStyleOption(context, style),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCardStyleOption(
    BuildContext context,
    TodayCardStyle style,
  ) {
    final isSelected = themeProvider.todayCardStyle == style;

    String title;
    String description;
    IconData icon;

    switch (style) {
      case TodayCardStyle.withEmoji:
        title = 'Com Emoji';
        description = 'Mostra o emoji da lista em cada tarefa';
        icon = Icons.emoji_emotions;
        break;
      case TodayCardStyle.withColorBorder:
        title = 'Com Borda Colorida';
        description = 'Mostra uma borda colorida à esquerda em cada tarefa';
        icon = Icons.border_left;
        break;
    }

    return GestureDetector(
      onTap: () => themeProvider.setTodayCardStyle(style),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          isSelected
                              ? Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer.withOpacity(0.8)
                              : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
