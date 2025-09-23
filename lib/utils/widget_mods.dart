import 'package:flutter/material.dart';

/// ==============================
///  WIDGET MODIFIERS - Extensions para código mais legível
/// ==============================
///
/// Extensões que reduzem aninhamento e tornam o código mais fluido.
/// Inspirado em SwiftUI modifiers e Tailwind CSS.
///
/// **Como usar:**
/// ```dart
/// // ❌ Antes - aninhamento profundo
/// Padding(
///   padding: EdgeInsets.all(12),
///   child: InkWell(
///     onTap: onTap,
///     child: ClipRRect(
///       borderRadius: BorderRadius.circular(8),
///       child: Container(
///         color: Colors.blue,
///         child: Center(
///           child: myWidget
///         )
///       )
///     )
///   )
/// )
///
/// // ✅ Depois - fluent interface
/// myWidget
///   .center()
///   .container(color: Colors.blue)
///   .clipRRect(BorderRadius.circular(8))
///   .tappable(onTap)
///   .padAll(12)
/// ```
extension WidgetMods on Widget {
  /// 📏 **Padding Modifiers** - Aplicam espaçamento

  /// Aplica padding em todas as direções
  Widget padAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Aplica padding simétrico (horizontal/vertical)
  Widget padSym({double h = 0, double v = 0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
    child: this,
  );

  /// Aplica padding específico por lado
  Widget padOnly({double l = 0, double t = 0, double r = 0, double b = 0}) =>
      Padding(
        padding: EdgeInsets.only(left: l, top: t, right: r, bottom: b),
        child: this,
      );

  /// Aplica EdgeInsets customizado
  Widget padding(EdgeInsets padding) => Padding(padding: padding, child: this);

  /// 📐 **Layout Modifiers** - Controlam posicionamento e tamanho

  /// Centraliza o widget
  Widget center() => Center(child: this);

  /// Alinha o widget
  Widget align(AlignmentGeometry alignment) =>
      Align(alignment: alignment, child: this);

  /// Expande o widget para ocupar espaço disponível
  Widget expanded([int flex = 1]) => Expanded(flex: flex, child: this);

  /// Aplica Flexible
  Widget flexible([int flex = 1]) => Flexible(flex: flex, child: this);

  /// Aplica tamanho fixo
  Widget sized({double? width, double? height}) =>
      SizedBox(width: width, height: height, child: this);

  /// 🎨 **Visual Modifiers** - Aplicam decoração e efeitos

  /// Aplica clipping com border radius
  Widget clipRRect(BorderRadius borderRadius) =>
      ClipRRect(borderRadius: borderRadius, child: this);

  /// Aplica Container com decoração
  Widget container({
    Color? color,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxDecoration? decoration,
    double? width,
    double? height,
  }) => Container(
    color: color,
    padding: padding,
    margin: margin,
    decoration: decoration,
    width: width,
    height: height,
    child: this,
  );

  /// Aplica Card wrapper
  Widget card({
    Color? color,
    double? elevation,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
  }) => Card(
    color: color,
    elevation: elevation,
    shape: shape,
    margin: margin,
    child: this,
  );

  /// 🖱️ **Interaction Modifiers** - Adicionam comportamento

  /// Torna o widget clicável com efeito ripple
  Widget tappable(
    VoidCallback? onTap, {
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
  }) => InkWell(
    onTap: onTap,
    borderRadius: borderRadius,
    splashColor: splashColor,
    highlightColor: highlightColor,
    child: this,
  );

  /// Adiciona GestureDetector
  Widget gesture({
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    VoidCallback? onLongPress,
    GestureTapDownCallback? onTapDown,
    GestureTapUpCallback? onTapUp,
  }) => GestureDetector(
    onTap: onTap,
    onDoubleTap: onDoubleTap,
    onLongPress: onLongPress,
    onTapDown: onTapDown,
    onTapUp: onTapUp,
    child: this,
  );

  /// 🔄 **Conditional Modifiers** - Aplicação condicional

  /// Aplica modificador apenas se condição for verdadeira
  Widget when(bool condition, Widget Function(Widget) modifier) {
    return condition ? modifier(this) : this;
  }

  /// Escolhe entre dois modificadores baseado em condição
  Widget conditional(
    bool condition,
    Widget Function(Widget) ifTrue,
    Widget Function(Widget) ifFalse,
  ) {
    return condition ? ifTrue(this) : ifFalse(this);
  }
}
