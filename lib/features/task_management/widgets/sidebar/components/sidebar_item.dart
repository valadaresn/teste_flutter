import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../themes/theme_provider.dart';
import '../../../themes/app_theme.dart';
import '../../settings/samsung_style/samsung_sidebar_theme.dart';

/// **SidebarItem** - Componente base para itens da sidebar
///
/// Este componente é responsável por:
/// - Renderizar itens individuais da sidebar (projetos, listas, ações)
/// - Aplicar estilos baseados no tema ativo (padrão ou Samsung)
/// - Suportar clique direito (desktop) e toque longo (mobile)
/// - Fornecer feedback visual consistente
class SidebarItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final int count;
  final bool isSelected;
  final bool isNested;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final void Function(Offset)? onSecondaryTap;

  const SidebarItem({
    Key? key,
    required this.title,
    this.icon,
    this.count = 0,
    this.isSelected = false,
    this.isNested = false,
    required this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isSamsungTheme =
            themeProvider.sidebarTheme == SidebarTheme.samsungNotes;

        if (onSecondaryTap != null) {
          return GestureDetector(
            onSecondaryTapDown:
                (details) => onSecondaryTap!(details.globalPosition),
            child: _buildItem(context, isSamsungTheme),
          );
        }

        return _buildItem(context, isSamsungTheme);
      },
    );
  }

  Widget _buildItem(BuildContext context, bool isSamsungTheme) {
    if (isSamsungTheme) {
      return _buildSamsungStyleItem(context);
    } else {
      return _buildDefaultStyleItem(context);
    }
  }

  /// Estilo Samsung Notes
  Widget _buildSamsungStyleItem(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(SamsungSidebarTheme.borderRadius),
      child: Container(
        decoration:
            isSelected ? SamsungSidebarTheme.selectedItemDecoration : null,
        padding: EdgeInsets.symmetric(
          horizontal: SamsungSidebarTheme.itemHorizontalPadding,
          vertical: SamsungSidebarTheme.itemVerticalPadding,
        ),
        margin: EdgeInsets.only(
          left: isNested ? SamsungSidebarTheme.nestedItemIndent : 0,
          right: 4.0,
          bottom: 1.0,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: SamsungSidebarTheme.iconSize,
                color:
                    isSelected
                        ? SamsungSidebarTheme.textColor
                        : SamsungSidebarTheme.iconColor,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: SamsungSidebarTheme.itemFontSize,
                  fontWeight:
                      isSelected
                          ? FontWeight.w500
                          : SamsungSidebarTheme.itemFontWeight,
                  color: SamsungSidebarTheme.textColor,
                ),
              ),
            ),
            if (count > 0)
              Text(
                '$count',
                style: TextStyle(
                  fontSize: SamsungSidebarTheme.counterFontSize,
                  fontWeight: FontWeight.w400,
                  color: SamsungSidebarTheme.textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Estilo padrão
  Widget _buildDefaultStyleItem(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isNested ? 24 : 16,
        vertical: 8,
      ),
      child: ListTile(
        dense: true,
        leading:
            icon != null
                ? Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                )
                : null,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        trailing:
            count > 0
                ? Text(
                  '$count',
                  style: TextStyle(
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                )
                : null,
        selected: isSelected,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
