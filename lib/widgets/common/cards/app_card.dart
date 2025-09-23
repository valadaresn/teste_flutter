import 'package:flutter/material.dart';

/// 📋 AppCard - Componente genérico para cards
///
/// Suporta diferentes layouts e estilos para ser usado em:
/// - NoteCard: com borda lateral colorida e tags
/// - HabitCard: com ícone interativo e botões
/// - TaskItem: com checkbox circular e trailing múltiplo
/// - Outros cards futuros
class AppCard extends StatefulWidget {
  // === CONTEÚDO ===
  final String? title;
  final String? subtitle;
  final String? content;
  final Widget? customContent;

  // === LEADING (Esquerda) ===
  final Widget? leading;
  final String? leadingText;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final Color? leadingBackgroundColor;
  final VoidCallback? onLeadingTap;

  // === CHECKBOX CIRCULAR ===
  final bool showCheckbox;
  final bool? isChecked;
  final VoidCallback? onCheckboxChanged;
  final Color? checkboxActiveColor;
  final bool animateCheckbox;

  // === TRAILING (Direita) ===
  final Widget? trailing;
  final String? trailingText;
  final IconData? trailingIcon;
  final Color? trailingIconColor;
  final Color? trailingBackgroundColor;
  final VoidCallback? onTrailingTap;

  // === MÚLTIPLAS ACTIONS ===
  final List<Widget>? actions;
  final Widget? Function(BuildContext)? conditionalTrailing;
  final bool Function()? showTrailing;

  // === FOOTER ===
  final List<Widget>? children;
  final Widget? footer;

  // === INFORMAÇÕES SECUNDÁRIAS ===
  final List<Widget>? secondaryInfo;
  final bool showSeparators;
  final Color? separatorColor;

  // === VISUAL ===
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? hoverBackgroundColor;
  final double borderRadius;
  final double elevation;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  // === BORDA LATERAL ===
  final Color? leftBorderColor;
  final double leftBorderWidth;

  // === BORDA DINÂMICA ===
  final Color? dynamicBorderColor;
  final double selectedBorderWidth;
  final double unselectedBorderWidth;

  // === ESTADO ===
  final bool isSelected;
  final bool enabled;
  final bool showBorder;
  final bool enableInstantSelection;

  // === HOVER ===
  final bool enableHover;
  final MouseCursor? cursor;

  // === INTERATIVIDADE ===
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? hoverColor;

  // === ESTILO DE TEXTO ===
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? contentStyle;
  final int? contentMaxLines;
  final TextOverflow? contentOverflow;
  final bool strikethrough;
  final Color? textColorWhenDisabled;

  const AppCard({
    Key? key,

    // Conteúdo
    this.title,
    this.subtitle,
    this.content,
    this.customContent,

    // Leading
    this.leading,
    this.leadingText,
    this.leadingIcon,
    this.leadingIconColor,
    this.leadingBackgroundColor,
    this.onLeadingTap,

    // Checkbox
    this.showCheckbox = false,
    this.isChecked,
    this.onCheckboxChanged,
    this.checkboxActiveColor,
    this.animateCheckbox = true,

    // Trailing
    this.trailing,
    this.trailingText,
    this.trailingIcon,
    this.trailingIconColor,
    this.trailingBackgroundColor,
    this.onTrailingTap,

    // Actions múltiplas
    this.actions,
    this.conditionalTrailing,
    this.showTrailing,

    // Footer
    this.children,
    this.footer,

    // Informações secundárias
    this.secondaryInfo,
    this.showSeparators = true,
    this.separatorColor,

    // Visual
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.hoverBackgroundColor,
    this.borderRadius = 8.0,
    this.elevation = 2.0,
    this.margin,
    this.padding,

    // Borda lateral
    this.leftBorderColor,
    this.leftBorderWidth = 0.0,

    // Borda dinâmica
    this.dynamicBorderColor,
    this.selectedBorderWidth = 2.0,
    this.unselectedBorderWidth = 1.0,

    // Estado
    this.isSelected = false,
    this.enabled = true,
    this.showBorder = false,
    this.enableInstantSelection = false,

    // Hover
    this.enableHover = false,
    this.cursor,

    // Interatividade
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,

    // Estilo de texto
    this.titleStyle,
    this.subtitleStyle,
    this.contentStyle,
    this.contentMaxLines = 1,
    this.contentOverflow = TextOverflow.ellipsis,
    this.strikethrough = false,
    this.textColorWhenDisabled,
  }) : super(key: key);

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;
  bool _isVisuallySelected = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determinar se está selecionado (incluindo seleção visual instantânea)
    final isSelected = widget.isSelected || _isVisuallySelected;

    // Container principal do card
    Widget cardContent = _buildCardContent(context, theme, isSelected);

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

  /// Constrói o conteúdo principal do card
  Widget _buildCardContent(
    BuildContext context,
    ThemeData theme,
    bool isSelected,
  ) {
    // Cor de fundo baseada no estado
    final cardColor = _getCardColor(context, theme, isSelected);

    // Margem e padding
    final cardMargin =
        widget.margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    final cardPadding = widget.padding ?? const EdgeInsets.all(12);

    return Container(
      margin: cardMargin,
      child: Card(
        color: cardColor,
        elevation: widget.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          side: _buildBorder(isSelected),
        ),
        child: Container(
          decoration: _buildLeftBorderDecoration(),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: InkWell(
              onTap: widget.enabled ? _handleTap : null,
              onLongPress: widget.enabled ? widget.onLongPress : null,
              onDoubleTap: widget.enabled ? widget.onDoubleTap : null,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              splashColor: widget.splashColor,
              highlightColor: widget.highlightColor,
              hoverColor: widget.hoverColor,
              child: Padding(
                padding: cardPadding,
                child: _buildContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Determina a cor de fundo do card
  Color _getCardColor(BuildContext context, ThemeData theme, bool isSelected) {
    if (isSelected) {
      return widget.selectedBackgroundColor ??
          theme.colorScheme.primaryContainer;
    }

    if (widget.enableHover && _isHovered) {
      return widget.hoverBackgroundColor ??
          theme.colorScheme.onSurface.withOpacity(0.04);
    }

    return widget.backgroundColor ?? theme.colorScheme.surface;
  }

  /// Manipula o toque no card
  void _handleTap() {
    if (widget.enableInstantSelection) {
      setState(() => _isVisuallySelected = true);
    }
    widget.onTap?.call();
  }

  /// Constrói a borda do card
  BorderSide _buildBorder(bool isSelected) {
    if (widget.dynamicBorderColor != null && isSelected) {
      return BorderSide(
        color: widget.dynamicBorderColor!,
        width: widget.selectedBorderWidth,
      );
    }

    if (widget.showBorder && isSelected) {
      return BorderSide(color: Colors.blue, width: widget.selectedBorderWidth);
    }

    if (isSelected) {
      return BorderSide(color: Colors.blue, width: widget.selectedBorderWidth);
    }

    return BorderSide(
      color: Colors.grey.withOpacity(0.2),
      width: widget.unselectedBorderWidth,
    );
  }

  /// Constrói a decoração da borda lateral colorida
  BoxDecoration? _buildLeftBorderDecoration() {
    if (widget.leftBorderColor != null && widget.leftBorderWidth > 0) {
      return BoxDecoration(
        border: Border(
          left: BorderSide(
            color: widget.leftBorderColor!,
            width: widget.leftBorderWidth,
          ),
        ),
      );
    }
    return null;
  }

  /// Constrói o conteúdo principal do card
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linha principal com leading, conteúdo e trailing
        Row(
          children: [
            // Checkbox (se habilitado)
            if (widget.showCheckbox) ...[
              _buildCircularCheckbox(),
              const SizedBox(width: 12),
            ],

            // Leading (se não for checkbox)
            if (!widget.showCheckbox && _hasLeading()) ...[
              _buildLeading(),
              const SizedBox(width: 12),
            ],

            // Conteúdo principal (expansível)
            Expanded(child: _buildMainContent(context)),

            // Actions múltiplas (se disponíveis)
            if (widget.actions != null && widget.actions!.isNotEmpty) ...[
              const SizedBox(width: 8),
              ..._buildFilteredActions(),
            ],

            // Trailing único (se não houver actions)
            if ((widget.actions == null || widget.actions!.isEmpty) &&
                _hasTrailing()) ...[
              const SizedBox(width: 8),
              _buildTrailing(),
            ],
          ],
        ),

        // Informações secundárias
        if (_hasSecondaryInfo()) ...[
          const SizedBox(height: 4),
          _buildSecondaryInfoWithSeparators(),
        ],

        // Footer com children ou footer customizado
        if (_hasFooter()) ...[const SizedBox(height: 8), _buildFooter()],
      ],
    );
  }

  /// Constrói o checkbox circular animado
  Widget _buildCircularCheckbox() {
    final isChecked = widget.isChecked ?? false;
    final activeColor = widget.checkboxActiveColor ?? Colors.blue;

    Widget checkbox = Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isChecked ? activeColor : Colors.grey.shade400,
          width: 2,
        ),
        color: isChecked ? activeColor : Colors.transparent,
      ),
      child:
          isChecked
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
    );

    if (widget.animateCheckbox) {
      checkbox = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isChecked ? activeColor : Colors.grey.shade400,
            width: 2,
          ),
          color: isChecked ? activeColor : Colors.transparent,
        ),
        child:
            isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
      );
    }

    return GestureDetector(onTap: widget.onCheckboxChanged, child: checkbox);
  }

  /// Filtra e retorna as actions baseado no showTrailing
  List<Widget> _buildFilteredActions() {
    if (widget.showTrailing != null && !widget.showTrailing!()) {
      return [];
    }
    return widget.actions!;
  }

  /// Verifica se há conteúdo leading
  bool _hasLeading() {
    return widget.leading != null ||
        widget.leadingIcon != null ||
        widget.leadingText != null;
  }

  /// Verifica se há conteúdo trailing
  bool _hasTrailing() {
    return widget.trailing != null ||
        widget.trailingIcon != null ||
        widget.trailingText != null;
  }

  /// Verifica se há footer
  bool _hasFooter() {
    return widget.footer != null ||
        (widget.children != null && widget.children!.isNotEmpty);
  }

  /// Verifica se há informações secundárias
  bool _hasSecondaryInfo() {
    return widget.secondaryInfo != null && widget.secondaryInfo!.isNotEmpty;
  }

  /// Constrói o widget leading
  Widget _buildLeading() {
    if (widget.leading != null) {
      return GestureDetector(
        onTap: widget.onLeadingTap,
        child: widget.leading!,
      );
    }

    // Ícone ou texto leading
    Widget leadingWidget;

    if (widget.leadingIcon != null) {
      leadingWidget = Icon(
        widget.leadingIcon!,
        color: widget.leadingIconColor ?? Colors.black54,
        size: 24,
      );
    } else if (widget.leadingText != null) {
      leadingWidget = Text(
        widget.leadingText!,
        style: const TextStyle(fontSize: 20),
      );
    } else {
      return const SizedBox.shrink();
    }

    // Wrapper com background se especificado
    if (widget.leadingBackgroundColor != null) {
      leadingWidget = Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: widget.leadingBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: leadingWidget),
      );
    }

    return GestureDetector(onTap: widget.onLeadingTap, child: leadingWidget);
  }

  /// Constrói o widget trailing
  Widget _buildTrailing() {
    if (widget.trailing != null) {
      return GestureDetector(
        onTap: widget.onTrailingTap,
        child: widget.trailing!,
      );
    }

    // Ícone ou texto trailing
    Widget trailingWidget;

    if (widget.trailingIcon != null) {
      trailingWidget = Icon(
        widget.trailingIcon!,
        color: widget.trailingIconColor ?? Colors.black54,
        size: 24,
      );
    } else if (widget.trailingText != null) {
      trailingWidget = Text(
        widget.trailingText!,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      );
    } else {
      return const SizedBox.shrink();
    }

    // Wrapper com background se especificado
    if (widget.trailingBackgroundColor != null) {
      trailingWidget = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: widget.trailingBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: trailingWidget),
      );
    }

    return GestureDetector(onTap: widget.onTrailingTap, child: trailingWidget);
  }

  /// Constrói o conteúdo principal (título, subtitle, content)
  Widget _buildMainContent(BuildContext context) {
    if (widget.customContent != null) {
      return widget.customContent!;
    }

    final theme = Theme.of(context);
    final defaultTitleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );
    final defaultSubtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.black54,
    );
    final defaultContentStyle = theme.textTheme.bodyMedium?.copyWith(
      color: Colors.black87,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: _getTitleStyle(context, defaultTitleStyle),
            maxLines: widget.contentMaxLines,
            overflow: widget.contentOverflow,
          ),
          if (widget.subtitle != null || widget.content != null)
            const SizedBox(height: 4),
        ],

        // Subtitle
        if (widget.subtitle != null) ...[
          Text(
            widget.subtitle!,
            style: widget.subtitleStyle ?? defaultSubtitleStyle,
          ),
          if (widget.content != null) const SizedBox(height: 4),
        ],

        // Content
        if (widget.content != null)
          Text(
            widget.content!,
            maxLines: widget.contentMaxLines,
            overflow: widget.contentOverflow,
            style: widget.contentStyle ?? defaultContentStyle,
          ),
      ],
    );
  }

  /// Obtém o estilo do título considerando strikethrough
  TextStyle _getTitleStyle(BuildContext context, TextStyle? defaultStyle) {
    final baseStyle =
        widget.titleStyle ??
        defaultStyle ??
        Theme.of(context).textTheme.titleMedium!;

    if (widget.strikethrough) {
      return baseStyle.copyWith(
        decoration: TextDecoration.lineThrough,
        color: widget.textColorWhenDisabled ?? Colors.grey.shade500,
      );
    }

    return baseStyle;
  }

  /// Constrói as informações secundárias com separadores
  Widget _buildSecondaryInfoWithSeparators() {
    if (widget.secondaryInfo == null || widget.secondaryInfo!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!widget.showSeparators) {
      return Row(children: widget.secondaryInfo!);
    }

    final separatorColor = widget.separatorColor ?? Colors.grey.shade300;

    return Row(
      children: [
        for (int i = 0; i < widget.secondaryInfo!.length; i++) ...[
          widget.secondaryInfo![i],
          if (i < widget.secondaryInfo!.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(width: 1, height: 12, color: separatorColor),
            ),
        ],
      ],
    );
  }

  /// Constrói o footer
  Widget _buildFooter() {
    if (widget.footer != null) {
      return widget.footer!;
    }

    if (widget.children != null && widget.children!.isNotEmpty) {
      return Wrap(spacing: 4, runSpacing: 4, children: widget.children!);
    }

    return const SizedBox.shrink();
  }
}
