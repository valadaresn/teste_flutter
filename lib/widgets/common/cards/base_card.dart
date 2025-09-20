import 'package:flutter/material.dart';

/// Widget de card genérico e reutilizável
/// Pode ser usado para notas, tarefas, hábitos, etc.
class BaseCard extends StatelessWidget {
  // Conteúdo
  final String? title;
  final String? subtitle;
  final String? content;
  final Widget? customContent;

  // Visual
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final List<BoxShadow>? shadows;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  // Interação
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  // Ações
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? trailing;

  // Indicadores
  final List<Widget>? tags;
  final Widget? statusIndicator;
  final String? dateText;

  // Estados
  final bool isSelected;
  final bool isEnabled;
  final bool showBorder;

  const BaseCard({
    Key? key,
    this.title,
    this.subtitle,
    this.content,
    this.customContent,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.shadows,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.actions,
    this.leading,
    this.trailing,
    this.tags,
    this.statusIndicator,
    this.dateText,
    this.isSelected = false,
    this.isEnabled = true,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        elevation: isSelected ? 4 : 2,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          onLongPress: isEnabled ? onLongPress : null,
          onDoubleTap: isEnabled ? onDoubleTap : null,
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
              border:
                  showBorder
                      ? Border.all(
                        color: borderColor ?? Theme.of(context).dividerColor,
                        width: isSelected ? 2 : 1,
                      )
                      : null,
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho com título e ações
                if (title != null || actions != null || trailing != null)
                  _buildHeader(context),

                if (title != null && (content != null || customContent != null))
                  const SizedBox(height: 8),

                // Conteúdo principal
                if (customContent != null)
                  customContent!
                else if (content != null)
                  _buildContent(context),

                // Footer com tags e data
                if ((tags != null && tags!.isNotEmpty) || dateText != null)
                  _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? null : Theme.of(context).disabledColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isEnabled
                            ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7)
                            : Theme.of(context).disabledColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        if (statusIndicator != null) ...[
          const SizedBox(width: 8),
          statusIndicator!,
        ],

        if (trailing != null) ...[const SizedBox(width: 8), trailing!],

        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(width: 8),
          Row(mainAxisSize: MainAxisSize.min, children: actions!),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      content!,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isEnabled ? null : Theme.of(context).disabledColor,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            // Tags
            if (tags != null && tags!.isNotEmpty)
              Expanded(child: Wrap(spacing: 6, runSpacing: 4, children: tags!)),

            // Data
            if (dateText != null) ...[
              if (tags != null && tags!.isNotEmpty) const SizedBox(width: 12),
              Text(
                dateText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      isEnabled
                          ? Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6)
                          : Theme.of(context).disabledColor,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;

    if (isSelected) {
      return Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1);
    }

    if (!isEnabled) {
      return Theme.of(context).colorScheme.surface.withOpacity(0.5);
    }

    return Theme.of(context).colorScheme.surface;
  }
}
