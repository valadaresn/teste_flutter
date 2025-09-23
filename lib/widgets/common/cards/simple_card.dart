import 'package:flutter/material.dart';
import 'base_card.dart';

/// 📄 SimpleCard - Card minimalista para casos básicos
///
/// Funcionalidades específicas:
/// - Layout simples e clean
/// - Mínimo de propriedades
/// - Máxima flexibilidade de conteúdo
/// - Ideal para protótipos e casos simples
class SimpleCard extends StatelessWidget {
  final String? title;
  final String? content;
  final Widget? child;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const SimpleCard({
    Key? key,
    this.title,
    this.content,
    this.child,
    this.onTap,
    this.isSelected = false,
    this.backgroundColor,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: title,
      content: content,
      customContent: child,
      isSelected: isSelected,
      backgroundColor: backgroundColor,
      margin: margin,
      padding: padding,
      onTap: onTap,
    );
  }
}
