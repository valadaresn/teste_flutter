import 'package:flutter/material.dart';
import 'samsung_sidebar_theme.dart';

/// Widget de item de lista com estilo Samsung Notes
///
/// Este widget representa um item individual no sidebar (projetos, listas, etc.)
/// seguindo o design minimalista do Samsung Notes
class SamsungListItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final int count;
  final bool isSelected;
  final bool isNested;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const SamsungListItem({
    Key? key,
    required this.title,
    this.icon,
    this.count = 0,
    this.isSelected = false,
    this.isNested = false,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            // Ícone (se fornecido)
            if (icon != null) ...[
              Icon(
                icon,
                color: SamsungSidebarTheme.iconColor,
                size: SamsungSidebarTheme.iconSize,
              ),
              SizedBox(width: 12),
            ],

            // Título do item
            Expanded(
              child: Text(
                title,
                style: SamsungSidebarTheme.itemTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Contador (se maior que zero)
            if (count > 0)
              Text(
                count.toString(),
                style: SamsungSidebarTheme.counterTextStyle,
              ),
          ],
        ),
      ),
    );
  }
}
