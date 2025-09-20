// ============================================================================
// CONFIGURAÇÕES DE COR DO PAINEL LATERAL
// ============================================================================
// Este componente permite escolher a cor de fundo do painel lateral de navegação:
// - Tema do Sistema: Segue o tema do sistema
// - Samsung Light: Cinza claro estilo Samsung Notes
// - Branco: Fundo branco simples
// - Cor da Lista: Usa a cor da lista selecionada
// - Escuro: Fundo escuro/preto
// ============================================================================

import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../../themes/theme_provider.dart';

/// ============================================================================
/// SIDEBAR COLOR SETTINGS - Configurações de cor do painel lateral
/// ============================================================================
/// Permite configurar a cor de fundo do painel lateral de navegação com
/// preview visual das cores. Opções disponíveis:
/// - Tema do Sistema: Cor automática baseada no tema do sistema
/// - Samsung Light: Cinza claro (#F5F5F5) estilo Samsung Notes
/// - Branco: Fundo branco puro
/// - Cor da Lista: Dinâmica baseada na lista selecionada
/// - Escuro: Fundo escuro para modo noturno
/// ============================================================================
class SidebarColorSettings extends StatelessWidget {
  final ThemeProvider themeProvider;

  const SidebarColorSettings({Key? key, required this.themeProvider})
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
            'Cor do Painel Lateral',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Escolha a cor de fundo do painel lateral de navegação',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children:
                SidebarColorStyle.values.map((style) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildSidebarColorOption(context, style),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarColorOption(
    BuildContext context,
    SidebarColorStyle style,
  ) {
    final isSelected = themeProvider.sidebarColorStyle == style;

    String title;
    String description;
    Color previewColor;

    switch (style) {
      case SidebarColorStyle.systemTheme:
        title = 'Tema do Sistema';
        description = 'Segue o tema do sistema';
        previewColor = Theme.of(context).colorScheme.surface;
        break;
      case SidebarColorStyle.samsungLight:
        title = 'Samsung Light';
        description = 'Cinza claro estilo Samsung Notes';
        previewColor = const Color(0xFFF5F5F5);
        break;
      case SidebarColorStyle.white:
        title = 'Branco';
        description = 'Fundo branco simples';
        previewColor = Colors.white;
        break;
      case SidebarColorStyle.listColor:
        title = 'Cor da Lista';
        description = 'Usa a cor da lista selecionada';
        previewColor = Theme.of(context).primaryColor;
        break;
      case SidebarColorStyle.dark:
        title = 'Escuro';
        description = 'Fundo escuro/preto';
        previewColor = Colors.grey.shade900;
        break;
    }

    return GestureDetector(
      onTap: () => themeProvider.setSidebarColorStyle(style),
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
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: previewColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
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
