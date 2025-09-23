import 'package:flutter/material.dart';

/// ==============================
///  STYLE OBJECTS (CardStyle)
///
///  Propósito: descrever o VISUAL específico dos Cards do sistema.
///  Mantém o componente enxuto e evita "prop hell" no ModularBaseCard.
///  Cada componente pode ter seu próprio style (CardStyle, ListItemStyle, etc.).
/// ==============================
class CardStyle {
  final Color? bgSelected, bgUnselected; // Fundo (selecionado vs não)
  final Color? borderSelected, borderUnselected; // Borda (selecionado vs não)
  final double? borderWidth; // Largura da borda
  final BorderRadius? radius; // Raio das bordas
  final EdgeInsets? margin; // Margem externa
  final EdgeInsets? padding; // Padding interno
  final double? elevation; // Elevação/sombra

  const CardStyle({
    this.bgSelected,
    this.bgUnselected,
    this.borderSelected,
    this.borderUnselected,
    this.borderWidth,
    this.radius,
    this.margin,
    this.padding,
    this.elevation,
  });

  /// Resolve o estilo efetivo combinando:
  /// 1) Valores passados
  /// 2) Tokens/tema (dividerColor, radius base, etc.)
  /// 3) Defaults seguros
  ResolvedCardStyle resolve(BuildContext c, {required bool isSelected}) {
    final t = Theme.of(c);
    final divider = t.dividerColor;

    final resolvedRadius = radius ?? BorderRadius.circular(RadiusScale.base);
    final resolvedMargin =
        margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 8);
    final resolvedPadding = padding ?? const EdgeInsets.all(12);
    final resolvedElevation = elevation ?? 2.0;
    final resolvedBWidth = borderWidth ?? 1.0;

    final bg =
        isSelected
            ? (bgSelected ?? Colors.grey.shade200)
            : (bgUnselected ?? Colors.white);

    final borderColor =
        isSelected
            ? (borderSelected ?? divider)
            : (borderUnselected ?? divider);

    return ResolvedCardStyle(
      bg: bg,
      borderColor: borderColor,
      borderWidth: resolvedBWidth,
      radius: resolvedRadius,
      margin: resolvedMargin,
      padding: resolvedPadding,
      elevation: resolvedElevation,
    );
  }

  /// API ergonômica para variações pontuais
  CardStyle copyWith({
    Color? bgSelected,
    Color? bgUnselected,
    Color? borderSelected,
    Color? borderUnselected,
    double? borderWidth,
    BorderRadius? radius,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? elevation,
  }) {
    return CardStyle(
      bgSelected: bgSelected ?? this.bgSelected,
      bgUnselected: bgUnselected ?? this.bgUnselected,
      borderSelected: borderSelected ?? this.borderSelected,
      borderUnselected: borderUnselected ?? this.borderUnselected,
      borderWidth: borderWidth ?? this.borderWidth,
      radius: radius ?? this.radius,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      elevation: elevation ?? this.elevation,
    );
  }
}

/// Estilo já resolvido (sem optionals) para uso direto no widget tree
class ResolvedCardStyle {
  final Color bg, borderColor;
  final double borderWidth, elevation;
  final BorderRadius radius;
  final EdgeInsets margin, padding;

  const ResolvedCardStyle({
    required this.bg,
    required this.borderColor,
    required this.borderWidth,
    required this.radius,
    required this.margin,
    required this.padding,
    required this.elevation,
  });
}

/// ==============================
///  TOKENS / SCALES - Design system consistente
/// ==============================
class RadiusScale {
  static const base = 8.0; // Border radius padrão do design system
}

/// ==============================
///  ESTILOS PREDEFINIDOS - Design system do app
/// ==============================
/// Coleção de estilos prontos para uso imediato.
/// Facilita consistência visual e reduz código boilerplate.
///
/// **COMO USAR:**
/// ```dart
/// // 1. Usar estilo predefinido
/// ModularBaseCard(style: CardStyles.diary, ...)
///
/// // 2. Customizar estilo específico
/// ModularBaseCard(
///   style: CardStyles.diary.copyWith(elevation: 4.0),
///   ...
/// )
/// ```
class CardStyles {
  /// 📝 **Estilo para cards de diário**
  ///
  /// **Características visuais:**
  /// - Fundo branco padrão, cinza claro quando selecionado
  /// - Bordas arredondadas (8px radius)
  /// - Borda cinza clara (1px)
  /// - Elevação suave (2.0)
  /// - Padding confortável (12px)
  /// - Margin espaçada (4px vertical, 8px horizontal)
  ///
  /// **Uso típico:**
  /// ```dart
  /// ModularDiaryCard(
  ///   style: CardStyles.diary.copyWith(
  ///     borderSelected: Colors.orange.shade200,
  ///     bgSelected: Color(0xFFFFF3E0),
  ///   ),
  ///   content: "Meu dia foi incrível!",
  ///   mood: "😊",
  /// )
  /// ```
  static const diary = CardStyle(
    bgUnselected: Colors.white,
    bgSelected: Color(0xFFF5F5F5), // Cinza bem claro para seleção
    borderWidth: 1.0,
    radius: BorderRadius.all(Radius.circular(8.0)),
    elevation: 2.0,
    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    padding: EdgeInsets.all(12),
  );

  /// 📄 **Estilo para cards de notas**
  ///
  /// **Características visuais:**
  /// - Visual clean e minimalista
  /// - Bordas personalizadas (top mais arredondado)
  /// - Suporte a borda esquerda colorida (para tags)
  /// - Seleção com fundo cinza padrão
  /// - Conteúdo limitado a 1 linha (ellipsis)
  ///
  /// **Uso típico:**
  /// ```dart
  /// ModularBaseCard(
  ///   style: CardStyles.note,
  ///   content: "Lembrar de comprar café",
  ///   modules: [
  ///     LeftBorderModule(color: Colors.blue, width: 5),
  ///   ],
  /// )
  /// ```
  static const note = CardStyle(
    bgUnselected: Colors.white,
    borderWidth: 1.0,
    radius: BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomLeft: Radius.circular(8),
      bottomRight: Radius.circular(8),
    ),
    elevation: 2.0,
    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    padding: EdgeInsets.all(12),
  );

  /// ✅ Estilo para cards de tarefas
  /// Características: visual compacto, seleção sutil
  static const task = CardStyle(
    bgUnselected: Colors.white,
    borderWidth: 1.0,
    radius: BorderRadius.all(Radius.circular(6.0)),
    elevation: 1.0,
    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
    padding: EdgeInsets.all(8),
  );

  /// 🎨 Estilo padrão para casos genéricos
  /// Características: visual neutro e flexível
  static const standard = CardStyle(
    bgUnselected: Colors.white,
    borderWidth: 1.0,
    elevation: 2.0,
  );
}

/// ==============================
///  UTILITÁRIOS E EXTENSÕES
/// ==============================
extension CardStyleExt on CardStyle {
  /// Aplica override rápido para elevation
  CardStyle withElevation(double elevation) => copyWith(elevation: elevation);

  /// Aplica override rápido para radius
  CardStyle withRadius(double radius) =>
      copyWith(radius: BorderRadius.circular(radius));

  /// Aplica override rápido para padding
  CardStyle withPadding(EdgeInsets padding) => copyWith(padding: padding);
}
