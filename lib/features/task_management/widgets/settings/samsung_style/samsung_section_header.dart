import 'package:flutter/material.dart';
import 'samsung_sidebar_theme.dart';

/// Widget de cabeçalho de seção para o sidebar Samsung Notes
///
/// Usado para separar e rotular seções como "Projetos", "Listas", etc.
class SamsungSectionHeader extends StatelessWidget {
  final String title;
  final bool showDivider;
  final Widget? trailing;

  const SamsungSectionHeader({
    Key? key,
    required this.title,
    this.showDivider = true,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divisor superior (se necessário)
        if (showDivider) _buildDivider(),

        // Cabeçalho da seção
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SamsungSidebarTheme.itemHorizontalPadding,
            vertical: 8.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(title, style: SamsungSidebarTheme.headerTextStyle),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 1,
        color: SamsungSidebarTheme.dividerColor,
        width: double.infinity,
      ),
    );
  }
}
