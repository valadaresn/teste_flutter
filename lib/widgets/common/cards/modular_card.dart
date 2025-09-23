import 'package:flutter/material.dart';
import '../../../tokens/spacing.dart';
import '../../../tokens/radius.dart';
import '../../../utils/widget_mods.dart';

/// 🧩 **ModularCard** - Card base simplificado com slots diretos
///
/// **FILOSOFIA:** Expor widgets diretamente nas posições, sem abstrações
/// **INSPIRAÇÃO:** ListTile do Flutter + padrões modernos de composição
/// **VANTAGENS:** Simplicidade brutal, flexibilidade total, menos código
///
/// **SLOTS DISPONÍVEIS:**
/// - `leading`: Widget no lado esquerdo (emoji, checkbox, avatar, ícone)
/// - `title`: Título principal (Text customizado)
/// - `subtitle`: Subtítulo opcional (Text menor, opcional)
/// - `content`: Conteúdo principal (Text com maxLines ou widget complexo)
/// - `footer`: Rodapé (chips, metadata, data, tags)
/// - `actions`: Lado direito (timer, botões, menu de ações)
///
/// **EXEMPLO DE USO:**
/// ```dart
/// ModularCard(
///   onTap: () => Navigator.push(...),
///   leading: Container(
///     width: 32, height: 32,
///     decoration: BoxDecoration(
///       color: Colors.green.withOpacity(0.15),
///       borderRadius: BorderRadius.circular(6),
///     ),
///     child: Center(child: Text('😊')),
///   ),
///   title: Text('Título', style: TextStyle(fontWeight: FontWeight.w600)),
///   content: Text('Conteúdo...', maxLines: 2, overflow: TextOverflow.ellipsis),
///   footer: Row(
///     mainAxisAlignment: MainAxisAlignment.spaceBetween,
///     children: [
///       Text('12:30', style: TextStyle(fontSize: 12, color: Colors.grey)),
///       Icon(Icons.favorite, size: 16, color: Colors.red),
///     ],
///   ),
/// )
/// ```
class ModularCard extends StatelessWidget {
  const ModularCard({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.content,
    this.footer,
    this.actions,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.margin,
    this.padding,
    this.leftBorderColor,
    this.leftBorderWidth,
    this.borderRadius,
    this.crossAxisAlignment,
    this.height,
    this.paddingHorizontal,
    this.paddingVertical,
    this.footerSpacing,
  });

  final Widget?
  leading; // Widget no lado esquerdo (emoji, checkbox, avatar, ícone)
  final Widget? title; // Título principal (Text customizado)
  final Widget? subtitle; // Subtítulo opcional (Text menor)
  final Widget?
  content; // Conteúdo principal (Text com maxLines ou widget complexo)
  final Widget? footer; // Rodapé (chips, metadata, data, tags)
  final Widget? actions; // Lado direito (timer, botões, menu de ações)
  final VoidCallback?
  onTap; // Callback para tap no card inteiro (navegação, detalhes)
  final Color? backgroundColor; // Cor de fundo customizada
  final double? elevation; // Elevação do card
  final EdgeInsets? margin; // Margin externa do card
  final EdgeInsets? padding; // Padding interno do card
  final Color? leftBorderColor; // Cor da borda esquerda
  final double? leftBorderWidth; // Largura da borda esquerda
  final BorderRadius? borderRadius; // Border radius customizado
  final CrossAxisAlignment?
  crossAxisAlignment; // Alinhamento vertical (start/center)
  final double? height; // Altura fixa do card (opcional)
  final double? paddingHorizontal; // Padding horizontal do card
  final double? paddingVertical; // Padding vertical do card
  final double? footerSpacing; // Espaçamento entre conteúdo e footer

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? RadiusScale.cardRadius;

    return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🏷️ MAIN ROW - leading + title/subtitle/content + actions
            if (leading != null ||
                title != null ||
                subtitle != null ||
                content != null ||
                actions != null)
              Row(
                crossAxisAlignment:
                    crossAxisAlignment ?? CrossAxisAlignment.start,
                children: [
                  // Leading (lado esquerdo)
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: Spacing.md),
                  ],

                  // Title/Subtitle/Content area (centro - expande)
                  if (title != null || subtitle != null || content != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        if (title != null) title!,

                        // Subtítulo
                        if (subtitle != null) ...[
                          SizedBox(height: Spacing.sm),
                          subtitle!,
                        ],

                        // Conteúdo principal
                        if (content != null) ...[
                          SizedBox(height: Spacing.md),
                          content!,
                        ],
                      ],
                    ).expanded(),

                  // Actions (lado direito)
                  if (actions != null) actions!,
                ],
              ),

            // 🦶 FOOTER (sempre abaixo de tudo)
            if (footer != null) ...[
              SizedBox(
                height: footerSpacing ?? Spacing.lg,
              ), // ✅ Espaçamento configurável
              footer!,
            ],
          ],
        )
        .padding(
          padding ??
              EdgeInsets.symmetric(
                horizontal:
                    paddingHorizontal ?? Spacing.lg, // Default: 12px (original)
                vertical:
                    paddingVertical ?? Spacing.lg, // Default: 12px (original)
              ),
        )
        .container(
          //este é o Card, com borda esquerda configurável
          height: height, // ✅ Altura configurável
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: effectiveBorderRadius,
            border:
                leftBorderColor != null
                    ? Border(
                      left: BorderSide(
                        color: leftBorderColor!,
                        width: leftBorderWidth ?? 4.0,
                      ),
                    )
                    : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: elevation ?? 2.0,
                offset: Offset(0, (elevation ?? 2.0) / 2),
              ),
            ],
          ),
          margin: margin ?? Spacing.cardMargin,
        )
        .tappable(onTap, borderRadius: effectiveBorderRadius);
  }
}
