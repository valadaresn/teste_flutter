import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modules/hover_module.dart';
import 'modules/dynamic_border_module.dart';

/// 🧩 Módulo base - interface para todos os módulos
abstract class CardModule {
  Widget build(BuildContext context, Map<String, dynamic> data);
  String get moduleId;
  String get position;
}

/// 🎯 Módulo com posição definida
abstract class PositionableModule extends CardModule {
  final String
  position; // 'leading', 'content', 'trailing', 'header-trailing', 'footer', 'decoration'

  PositionableModule(this.position);
}

/// 📱 ModularBaseCard - Sistema LEGO para cards
///
/// Aceita módulos plugáveis que definem funcionalidades específicas:
/// - leading: Antes do conteúdo (checkbox, ícones)
/// - content: Meio do conteúdo (info secundária, progresso)
/// - trailing: Depois do conteúdo (ações, menu)
/// - header-trailing: No cabeçalho à direita (data, status)
/// - footer: Rodapé (tags, informações extras)
/// - decoration: Decorações visuais (bordas, backgrounds)
class ModularBaseCard extends StatefulWidget {
  // === CONTEÚDO BÁSICO ===
  final String? title;
  final String? subtitle;
  final String? content;
  final Widget? customContent;

  // === MÓDULOS ===
  final List<CardModule> modules;
  final Map<String, dynamic> data; // Dados compartilhados entre módulos

  // === VISUAL ===
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? hoverBackgroundColor;
  final double borderRadius;
  final double elevation;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  // === ESTILO TÍTULO ===
  final TextStyle? titleStyle;
  final bool strikeThrough; // Para tarefas completadas

  // === ESTADO ===
  final bool isSelected;
  final bool enabled;
  final bool enableHover;
  final MouseCursor? cursor;

  // === INTERATIVIDADE ===
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? hoverColor;

  const ModularBaseCard({
    Key? key,
    this.title,
    this.subtitle,
    this.content,
    this.customContent,
    this.modules = const [],
    this.data = const {},
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.hoverBackgroundColor,
    this.borderRadius = 8.0,
    this.elevation = 2.0,
    this.margin,
    this.padding,
    this.titleStyle,
    this.strikeThrough = false,
    this.isSelected = false,
    this.enabled = true,
    this.enableHover = false,
    this.cursor,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
  }) : super(key: key);

  @override
  State<ModularBaseCard> createState() => _ModularBaseCardState();
}

class _ModularBaseCardState extends State<ModularBaseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget cardContent = _buildCardContent(context);

    // Wrap com decorações dos módulos
    cardContent = _wrapWithDecorations(cardContent);

    // Wrap com MouseRegion se hover habilitado
    if (widget.enableHover) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.cursor ?? SystemMouseCursors.click,
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildCardContent(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = _getCardColor(context, theme);
    final cardMargin =
        widget.margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 8);
    final cardPadding = widget.padding ?? const EdgeInsets.all(12);

    return Container(
      margin: cardMargin,
      child: Card(
        color: cardColor,
        elevation: widget.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          side:
              widget.isSelected
                  ? BorderSide(color: Colors.blue, width: 2)
                  : BorderSide.none,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            onTap: widget.enabled ? widget.onTap : null,
            onLongPress: widget.enabled ? widget.onLongPress : null,
            onDoubleTap: widget.enabled ? widget.onDoubleTap : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            splashColor: widget.splashColor,
            highlightColor: widget.highlightColor,
            hoverColor: widget.hoverColor,
            child: Padding(padding: cardPadding, child: _buildContent(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Linha principal com leading, conteúdo e trailing
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Módulos leading
            ..._buildModulesByPosition('leading'),

            // Conteúdo principal (sempre presente com Expanded)
            Expanded(child: _buildMainContent(context)),

            // Módulos trailing
            ..._buildModulesByPosition('trailing'),
          ],
        ),

        // Módulos content (linha separada)
        ..._buildModulesByPosition('content'),

        // Módulos footer
        ..._buildModulesByPosition('footer'),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    if (widget.customContent != null) {
      return widget.customContent!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho com título e header-trailing
        if (widget.title != null || _hasModulesByPosition('header-trailing'))
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null)
                Expanded(
                  child: Text(
                    widget.title!,
                    style:
                        widget.titleStyle ??
                        TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration:
                              widget.strikeThrough
                                  ? TextDecoration.lineThrough
                                  : null,
                          color:
                              widget.strikeThrough
                                  ? Colors.grey.shade500
                                  : null,
                        ),
                  ),
                ),

              // Módulos header-trailing
              ..._buildModulesByPosition('header-trailing'),
            ],
          ),

        // Subtitle
        if (widget.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            widget.subtitle!,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],

        // Content
        if (widget.content != null) ...[
          const SizedBox(height: 4),
          Text(widget.content!, style: const TextStyle(fontSize: 14)),
        ],
      ],
    );
  }

  List<Widget> _buildModulesByPosition(String position) {
    final modules =
        widget.modules.where((module) => module.position == position).toList();

    if (modules.isEmpty) return [];

    return modules.map((module) {
      Widget moduleWidget = module.build(context, widget.data);

      // Adicionar espaçamento automático baseado na posição
      if (position == 'leading') {
        moduleWidget = Padding(
          padding: const EdgeInsets.only(right: 12),
          child: moduleWidget,
        );
      } else if (position == 'trailing') {
        moduleWidget = Padding(
          padding: const EdgeInsets.only(left: 8),
          child: moduleWidget,
        );
      } else if (position == 'content' || position == 'footer') {
        moduleWidget = Padding(
          padding: const EdgeInsets.only(top: 8),
          child: moduleWidget,
        );
      }

      return moduleWidget;
    }).toList();
  }

  bool _hasModulesByPosition(String position) {
    return widget.modules.any((module) => module.position == position);
  }

  Widget _wrapWithDecorations(Widget child) {
    final decorationModules =
        widget.modules
            .where((module) => module.position == 'decoration')
            .toList();

    if (decorationModules.isEmpty) return child;

    // Aplicar decorações em sequência
    Widget decorated = child;
    for (final module in decorationModules) {
      decorated = module.build(context, {'child': decorated, ...widget.data});
    }

    return decorated;
  }

  Color _getCardColor(BuildContext context, ThemeData theme) {
    if (widget.isSelected) {
      return widget.selectedBackgroundColor ??
          theme.colorScheme.primaryContainer.withOpacity(0.1);
    }

    if (widget.enableHover && _isHovered) {
      return widget.hoverBackgroundColor ??
          theme.colorScheme.onSurface.withOpacity(0.04);
    }

    return widget.backgroundColor ?? theme.colorScheme.surface;
  }
}
