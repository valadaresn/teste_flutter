import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/task_management/themes/theme_provider.dart';

/// Barra de navegação vertical para telas grandes
/// Mostra apenas ícones de forma minimalista
class VerticalNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const VerticalNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Obter a cor da barra de navegação baseada na configuração do usuário
        final backgroundColor = themeProvider.getNavigationBarColor(
          context,
          listColor:
              Colors.blue, // Pode ser passado como parâmetro se necessário
        );

        return Container(
          width: 42,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            // Adicionar sombra sutil para profundidade
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Diário
              _buildNavItem(
                context: context,
                icon: Icons.book,
                label: 'Diário',
                index: 0,
              ),
              const SizedBox(height: 20),
              // Notas
              _buildNavItem(
                context: context,
                icon: Icons.note,
                label: 'Notas',
                index: 1,
              ),
              const SizedBox(height: 20),
              // Hábitos
              _buildNavItem(
                context: context,
                icon: Icons.fitness_center,
                label: 'Hábitos',
                index: 2,
              ),
              const SizedBox(height: 20),
              // Tarefas+
              _buildNavItem(
                context: context,
                icon: Icons.dashboard_customize,
                label: 'Tarefas+',
                index: 3,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return Tooltip(
      message: label,
      preferBelow: false,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onDestinationSelected(index),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withOpacity(0.8)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
