import 'package:flutter/material.dart';

/// ==============================
///  SPACING TOKENS - Design system consistente
/// ==============================
///
/// Tokens de espaçamento centralizados para uso em todo o app.
/// Evita "números mágicos" espalhados no código e mantém consistência visual.
///
/// **Como usar:**
/// ```dart
/// // Em widgets
/// EdgeInsets.all(Spacing.lg)
/// SizedBox(height: Spacing.md)
///
/// // Com widget extensions
/// widget.padAll(Spacing.lg)
/// widget.padSym(h: Spacing.md, v: Spacing.sm)
/// ```
class Spacing {
  static const xs = 2.0; // Micro espaçamentos - divisores, ajustes finos
  static const sm = 4.0; // Pequenos espaçamentos - entre elementos próximos
  static const md = 8.0; // Médios espaçamentos - separação padrão
  static const lg = 12.0; // Grandes espaçamentos - separação entre seções
  static const xl = 16.0; // Extra grandes - margens principais
  static const xxl = 24.0; // Espaçamentos de layout - entre componentes

  // Shortcuts comuns para EdgeInsets
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  // Margins padrão para cards
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    vertical: sm,
    horizontal: md,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
}
