import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_provider.dart';
import '../../themes/app_theme.dart';

/// Widget para demonstrar e alternar rapidamente entre temas do sidebar
///
/// Este widget pode ser adicionado na AppBar ou em um menu de configurações
/// para permitir troca rápida entre os temas
class SidebarThemeToggle extends StatelessWidget {
  const SidebarThemeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return PopupMenuButton<SidebarTheme>(
          icon: Icon(
            _getThemeIcon(themeProvider.sidebarTheme),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: 'Alterar tema do painel',
          onSelected: (SidebarTheme theme) async {
            await themeProvider.setSidebarTheme(theme);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tema alterado para ${theme.name}'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          itemBuilder:
              (BuildContext context) =>
                  SidebarTheme.values
                      .map(
                        (SidebarTheme theme) => PopupMenuItem<SidebarTheme>(
                          value: theme,
                          child: Row(
                            children: [
                              Icon(
                                _getThemeIcon(theme),
                                color:
                                    themeProvider.sidebarTheme == theme
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    theme.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      fontWeight:
                                          themeProvider.sidebarTheme == theme
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color:
                                          themeProvider.sidebarTheme == theme
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                              : null,
                                    ),
                                  ),
                                  Text(
                                    theme.description,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (themeProvider.sidebarTheme == theme)
                                Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 16,
                                ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
        );
      },
    );
  }

  IconData _getThemeIcon(SidebarTheme theme) {
    switch (theme) {
      case SidebarTheme.defaultTheme:
        return Icons.dashboard_outlined;
      case SidebarTheme.samsungNotes:
        return Icons.notes_outlined;
    }
  }
}
