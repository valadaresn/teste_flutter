// ============================================================================
// CONFIGURAÇÕES DE ESTILO DOS CARDS DE TAREFAS POR VISUALIZAÇÃO
// ============================================================================
// Este componente permite configurar o estilo dos cards (padrão/compacto) para
// diferentes visualizações: Hoje, Todas as Tarefas e Visualização de Lista.
// Cada visualização pode ter seu próprio estilo independente.
// ============================================================================

import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../../themes/theme_provider.dart';

/// ============================================================================
/// TASK CARD STYLE SETTINGS - Configurações de estilo dos cards de tarefas
/// ============================================================================
/// Permite configurar o estilo dos cards (standard/compact) para diferentes
/// visualizações de forma independente. Oferece opções de:
/// - Visualização Hoje: Cards para tela principal de tarefas de hoje
/// - Todas as Tarefas: Cards para visualização de todas as tarefas
/// - Visualização de Lista: Cards para visualização por lista específica
/// ============================================================================
class TaskCardStyleSettings extends StatelessWidget {
  final ThemeProvider themeProvider;

  const TaskCardStyleSettings({Key? key, required this.themeProvider})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildViewCardStyleOption(
          context,
          'Visualização Hoje',
          'Configuração para a tela principal de tarefas de hoje',
          themeProvider.todayViewCardStyle,
          (style) => themeProvider.setTodayViewCardStyle(style),
        ),
        const SizedBox(height: 16),
        _buildViewCardStyleOption(
          context,
          'Todas as Tarefas',
          'Configuração para a visualização de todas as tarefas',
          themeProvider.allTasksViewCardStyle,
          (style) => themeProvider.setAllTasksViewCardStyle(style),
        ),
        const SizedBox(height: 16),
        _buildViewCardStyleOption(
          context,
          'Visualização de Lista',
          'Configuração para a visualização por lista específica',
          themeProvider.listViewCardStyle,
          (style) => themeProvider.setListViewCardStyle(style),
        ),
      ],
    );
  }

  Widget _buildViewCardStyleOption(
    BuildContext context,
    String title,
    String subtitle,
    TaskCardStyle currentStyle,
    Function(TaskCardStyle) onStyleChanged,
  ) {
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
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCardStyleRadioOption(
                  context,
                  'Padrão',
                  'Cards com espaçamento normal',
                  TaskCardStyle.standard,
                  currentStyle,
                  onStyleChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCardStyleRadioOption(
                  context,
                  'Compacto',
                  'Cards com menos espaçamento',
                  TaskCardStyle.compact,
                  currentStyle,
                  onStyleChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStyleRadioOption(
    BuildContext context,
    String title,
    String subtitle,
    TaskCardStyle style,
    TaskCardStyle currentStyle,
    Function(TaskCardStyle) onStyleChanged,
  ) {
    final isSelected = currentStyle == style;

    return GestureDetector(
      onTap: () => onStyleChanged(style),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
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
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                subtitle,
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
            ),
          ],
        ),
      ),
    );
  }
}
