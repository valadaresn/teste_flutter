// ============================================================================
// CONFIGURAÇÕES DE COR DE FUNDO DA ÁREA PRINCIPAL
// ============================================================================
// Este componente permite escolher a cor de fundo para a área principal do app:
// - Cor da Lista: Usa a cor da lista selecionada como fundo
// - Samsung Light: Fundo cinza claro estilo Samsung Notes
// - Branco: Fundo branco simples
// - Tema do Sistema: Segue o tema atual do sistema
// ============================================================================

import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../../themes/theme_provider.dart';

/// ============================================================================
/// BACKGROUND COLOR SETTINGS - Configurações de cor de fundo da área principal
/// ============================================================================
/// Permite configurar a cor de fundo da área principal do aplicativo com
/// preview visual de cada opção. Opções disponíveis:
/// - Cor da Lista: Dinâmica baseada na lista selecionada
/// - Samsung Light: Cinza claro (#FAFAFA) estilo Samsung Notes
/// - Branco: Fundo branco puro
/// - Tema do Sistema: Segue automaticamente o tema do sistema
/// ============================================================================
class BackgroundColorSettings extends StatelessWidget {
  final ThemeProvider themeProvider;

  const BackgroundColorSettings({Key? key, required this.themeProvider})
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
            'Cor de Fundo da Área Principal',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Escolha a cor de fundo para a área principal do app',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children:
                BackgroundColorStyle.values.map((style) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildBackgroundColorOption(context, style),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundColorOption(
    BuildContext context,
    BackgroundColorStyle style,
  ) {
    final isSelected = themeProvider.backgroundColorStyle == style;

    String title;
    String description;
    Color previewColor;

    switch (style) {
      case BackgroundColorStyle.listColor:
        title = 'Cor da Lista';
        description = 'Usa a cor da lista selecionada como fundo';
        previewColor = Theme.of(context).primaryColor;
        break;
      case BackgroundColorStyle.samsungLight:
        title = 'Samsung Notes';
        description = 'Fundo cinza claro estilo Samsung Notes';
        previewColor = const Color(0xFFFAFAFA);
        break;
      case BackgroundColorStyle.white:
        title = 'Branco';
        description = 'Fundo branco simples';
        previewColor = Colors.white;
        break;
      case BackgroundColorStyle.systemTheme:
        title = 'Tema do Sistema';
        description = 'Segue o tema atual do sistema';
        previewColor = Theme.of(context).colorScheme.background;
        break;
    }

    return GestureDetector(
      onTap: () => themeProvider.setBackgroundColorStyle(style),
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
