// ============================================================================
// CONFIGURAÇÕES DE TEMA DO PAINEL LATERAL
// ============================================================================
// Este componente permite escolher entre diferentes temas para o painel lateral:
// - Padrão: Painel colorido com emojis e elementos visuais
// - Samsung Notes: Painel minimalista e clean estilo Samsung Notes
// ============================================================================

import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../../themes/theme_provider.dart';

/// ============================================================================
/// SIDEBAR THEME SETTINGS - Configurações de tema do painel lateral
/// ============================================================================
/// Permite escolher entre diferentes estilos visuais para o painel lateral:
/// - Padrão: Interface colorida com emojis e elementos visuais ricos
/// - Samsung Notes: Interface minimalista e clean inspirada no Samsung Notes
/// ============================================================================
class SidebarThemeSettings extends StatelessWidget {
  final ThemeProvider themeProvider;

  const SidebarThemeSettings({Key? key, required this.themeProvider})
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
            'Aparência do Painel Lateral',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Escolha o estilo visual do painel lateral de navegação',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children:
                SidebarTheme.values.map((theme) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildSidebarThemeOption(context, theme),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarThemeOption(BuildContext context, SidebarTheme theme) {
    final isSelected = themeProvider.sidebarTheme == theme;

    String title;
    String description;
    IconData icon;

    switch (theme) {
      case SidebarTheme.defaultTheme:
        title = 'Padrão';
        description = 'Painel colorido com emojis e elementos visuais';
        icon = Icons.dashboard;
        break;
      case SidebarTheme.samsungNotes:
        title = 'Samsung Notes';
        description = 'Painel minimalista e clean estilo Samsung Notes';
        icon = Icons.note;
        break;
    }

    return GestureDetector(
      onTap: () => themeProvider.setSidebarTheme(theme),
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
