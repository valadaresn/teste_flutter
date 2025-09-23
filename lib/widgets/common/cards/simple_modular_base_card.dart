import 'package:flutter/material.dart';
import 'modules/simple_left_border_module.dart';

/// 🧩 Módulo base - interface para todos os módulos
abstract class CardModule {
  Widget build(BuildContext context, Map<String, dynamic> data);
  String get moduleId;
  String get position;
}

/// 🎯 Módulo com posição definida
abstract class PositionableModule extends CardModule {
  final String position;

  PositionableModule(this.position);
}

/// 📱 ModularBaseCard - Versão SIMPLES para debug
class ModularBaseCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? content;
  final Widget? customContent;
  final List<CardModule> modules;
  final Map<String, dynamic> data;
  final Color? backgroundColor;

  // === BORDER RADIUS CONFIGURÁVEL ===
  final double borderRadius; // Valor padrão para todas as bordas
  final BorderRadius? customBorderRadius; // Para controle completo das 4 bordas

  // === CONTROLE DE BORDA ===
  final Color? borderColor; // Cor da borda
  final double? borderWidth; // Espessura da borda

  // === CONTROLE DE LINHAS DO CONTEÚDO ===
  final int? maxContentLines; // null = sem limite, 1 = apenas 1 linha, etc.
  final TextOverflow contentOverflow; // Como tratar overflow

  final double elevation;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool isSelected;
  final VoidCallback? onTap;

  const ModularBaseCard({
    Key? key,
    this.title,
    this.subtitle,
    this.content,
    this.customContent,
    this.modules = const [],
    this.data = const {},
    this.backgroundColor,
    this.borderRadius = 8.0,
    this.customBorderRadius,
    this.borderColor,
    this.borderWidth,
    this.maxContentLines,
    this.contentOverflow = TextOverflow.ellipsis,
    this.elevation = 2.0,
    this.margin,
    this.padding,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardMargin =
        margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 8);
    final cardPadding = padding ?? const EdgeInsets.all(12);

    // Determinar BorderRadius a usar (customBorderRadius tem prioridade)
    final effectiveBorderRadius =
        customBorderRadius ?? BorderRadius.circular(borderRadius);

    // Verificar se há módulo de borda esquerda
    LeftBorderModule? leftBorderModule;
    try {
      leftBorderModule =
          modules.firstWhere((module) => module is LeftBorderModule)
              as LeftBorderModule?;
    } catch (e) {
      leftBorderModule = null;
    }

    final hasLeftBorder = leftBorderModule != null;

    return Container(
      margin: cardMargin,
      child: Card(
        color: backgroundColor ?? Colors.white,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: effectiveBorderRadius,
          side: BorderSide.none,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: effectiveBorderRadius,
            border: Border.all(
              color: borderColor ?? Colors.grey.shade200,
              width: borderWidth ?? 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: effectiveBorderRadius,
            child: Container(
              decoration:
                  hasLeftBorder
                      ? BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: leftBorderModule.color,
                            width: leftBorderModule.width,
                          ),
                        ),
                      )
                      : null,
              child: InkWell(
                onTap: onTap,
                borderRadius: effectiveBorderRadius,
                child: Padding(
                  padding: cardPadding,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Módulos leading (lado esquerdo) - ALTURA TOTAL
                        ..._buildModulesByPosition('leading', context),

                        // Espaçamento entre emoji e conteúdo
                        if (_buildModulesByPosition(
                          'leading',
                          context,
                        ).isNotEmpty)
                          const SizedBox(width: 12),

                        // Conteúdo principal
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header com título e módulos header-trailing
                              if (title != null ||
                                  _buildModulesByPosition(
                                    'header-trailing',
                                    context,
                                  ).isNotEmpty)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Título
                                    if (title != null)
                                      Expanded(
                                        child: Text(
                                          title!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                    // Módulos header-trailing (exceto borda esquerda)
                                    ..._buildModulesByPosition(
                                      'header-trailing',
                                      context,
                                    ),
                                  ],
                                ),

                              // Subtitle
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],

                              // Content com controle de linhas
                              if (content != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  content!,
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: maxContentLines,
                                  overflow:
                                      maxContentLines != null
                                          ? contentOverflow
                                          : null,
                                ),
                              ],

                              // Módulos content (área principal de conteúdo)
                              ..._buildModulesByPosition('content', context),

                              // Custom content
                              if (customContent != null) ...[
                                const SizedBox(height: 4),
                                customContent!,
                              ],

                              // Módulos footer (exceto borda esquerda)
                              ..._buildModulesByPosition('footer', context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildModulesByPosition(String position, BuildContext context) {
    final filteredModules =
        modules
            .where(
              (module) =>
                  module.position == position && module is! LeftBorderModule,
            )
            .toList();
    if (filteredModules.isEmpty) return [];

    return filteredModules.map((module) {
      Widget moduleWidget = module.build(context, data);

      // Adicionar espaçamento automático baseado na posição
      if (position == 'footer') {
        moduleWidget = Padding(
          padding: const EdgeInsets.only(
            bottom: 2.0,
          ), // BOTTOM como no original
          child: moduleWidget,
        );
      } else if (position == 'content') {
        moduleWidget = Padding(
          padding: const EdgeInsets.only(top: 4),
          child: moduleWidget,
        );
      }

      return moduleWidget;
    }).toList();
  }
}
