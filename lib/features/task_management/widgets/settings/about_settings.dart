// ============================================================================
// SEÇÃO SOBRE O APLICATIVO
// ============================================================================
// Este componente exibe informações sobre o aplicativo incluindo:
// - Versão do app
// - Framework utilizado (Flutter)
// - Informações dos desenvolvedores
// - Acesso às licenças e créditos
// ============================================================================

import 'package:flutter/material.dart';

/// ============================================================================
/// ABOUT SETTINGS - Seção sobre o aplicativo
/// ============================================================================
/// Exibe informações do aplicativo em um formato limpo e organizado:
/// - Versão atual do aplicativo
/// - Framework de desenvolvimento (Flutter)
/// - Créditos da equipe de desenvolvimento
/// - Acesso rápido às licenças de código aberto
/// ============================================================================
class AboutSettings extends StatelessWidget {
  const AboutSettings({Key? key}) : super(key: key);

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
            'Sobre o App',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context, Icons.info_outline, 'Versão', '1.0.0'),
          const SizedBox(height: 12),
          _buildInfoRow(context, Icons.code, 'Framework', 'Flutter'),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.developer_mode,
            'Desenvolvido',
            'Task Management Team',
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showLicenses(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Licenças e Créditos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Task Management',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Task Management Team',
    );
  }
}
