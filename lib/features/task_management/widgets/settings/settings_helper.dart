// ============================================================================
// UTILITÁRIOS COMPARTILHADOS PARA UI DAS CONFIGURAÇÕES
// ============================================================================
// Este arquivo contém funções utilitárias reutilizáveis para manter
// consistência visual entre todos os componentes de configuração:
// - buildSectionHeader: Cabeçalhos padronizados para seções
// - buildSectionSeparator: Espaçamento consistente entre seções
// - buildSettingsContainer: Container padrão para configurações
// ============================================================================

import 'package:flutter/material.dart';

/// ============================================================================
/// SETTINGS HELPER - Utilitários compartilhados para UI das configurações
/// ============================================================================
/// Classe utilitária que fornece métodos estáticos para manter consistência
/// visual entre todos os componentes de configuração. Centraliza:
/// - Estilo de cabeçalhos de seção
/// - Espaçamento padronizado entre elementos
/// - Container base para componentes de configuração
/// ============================================================================
class SettingsHelper {
  /// Constrói um cabeçalho de seção para as configurações
  static Widget buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// Constrói um separador entre seções
  static Widget buildSectionSeparator() {
    return const SizedBox(height: 24);
  }

  /// Constrói um container padrão para as configurações
  static Widget buildSettingsContainer(BuildContext context, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: child,
    );
  }
}
