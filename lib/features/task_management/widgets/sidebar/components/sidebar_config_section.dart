import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/task_dialog_service.dart';
import '../../../themes/theme_provider.dart';
import '../../../themes/app_theme.dart';
import 'sidebar_item.dart';
import '../../settings/samsung_style/samsung_section_header.dart';

/// **SidebarConfigSection** - Seção de configurações da sidebar
///
/// Este componente é responsável por:
/// - Renderizar link para configurações
/// - Aplicar tema automaticamente
/// - Gerenciar navegação
class SidebarConfigSection extends StatelessWidget {
  final TaskDialogService dialogService;

  const SidebarConfigSection({Key? key, required this.dialogService})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isSamsungTheme =
            themeProvider.sidebarTheme == SidebarTheme.samsungNotes;

        return Column(
          children: [
            // Espaçador/separador
            if (isSamsungTheme)
              const SamsungSectionHeader(title: '')
            else
              Container(
                height: 1,
                color: Theme.of(context).dividerColor,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),

            // Item de configurações
            SidebarItem(
              title: 'Configurações',
              icon: Icons.settings_outlined,
              onTap: () => dialogService.navigateToSettings(context),
            ),
          ],
        );
      },
    );
  }
}
