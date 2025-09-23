import 'package:flutter/material.dart';

/// ==============================
///  RADIUS TOKENS - Design system consistente
/// ==============================
///
/// Tokens de border radius centralizados para uso em todo o app.
/// Mantém consistência visual entre cards, botões, dialogs, etc.
///
/// **Como usar:**
/// ```dart
/// // Border radius simples
/// BorderRadius.circular(RadiusScale.base)
///
/// // Border radius predefinidos
/// decoration: BoxDecoration(borderRadius: RadiusScale.cardRadius)
///
/// // Border radius customizados
/// BorderRadius.only(
///   topLeft: Radius.circular(RadiusScale.large),
///   topRight: Radius.circular(RadiusScale.large),
/// )
/// ```
class RadiusScale {
  // Valores base do design system
  static const none = 0.0; // Sem radius - elementos retos
  static const small = 4.0; // Radius pequeno - badges, chips
  static const base = 8.0; // Radius padrão - cards, botões
  static const medium = 12.0; // Radius médio - panels, dialogs
  static const large = 16.0; // Radius grande - sheets, modals
  static const xlarge = 24.0; // Radius extra grande - especiais

  // BorderRadius predefinidos comuns
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(base),
  );
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(base),
  );
  static const BorderRadius dialogRadius = BorderRadius.all(
    Radius.circular(medium),
  );
  static const BorderRadius sheetRadius = BorderRadius.only(
    topLeft: Radius.circular(large),
    topRight: Radius.circular(large),
  );

  // BorderRadius especiais para componentes específicos
  static const BorderRadius noteCardRadius = BorderRadius.only(
    topLeft: Radius.circular(medium),
    topRight: Radius.circular(medium),
    bottomLeft: Radius.circular(base),
    bottomRight: Radius.circular(base),
  );
}
