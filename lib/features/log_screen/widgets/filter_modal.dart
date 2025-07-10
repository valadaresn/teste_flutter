import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../task_management/controllers/task_controller.dart';
import '../../task_management/models/project_model.dart';
import '../../task_management/models/list_model.dart';
import '../log_model.dart';
import '../models/filter_state.dart';

/// **FilterModal** - Modal para filtros avançados de logs
///
/// Permite filtrar por:
/// - Período (hoje, semana, mês, etc.)
/// - Projetos específicos
/// - Listas específicas
/// - Status dos logs
/// - Range customizado de datas
class FilterModal extends StatefulWidget {
  final FilterState currentFilters;
  final Function(FilterState) onFiltersChanged;

  const FilterModal({
    Key? key,
    required this.currentFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  /// Mostra a modal de filtros
  static Future<void> show({
    required BuildContext context,
    required FilterState currentFilters,
    required Function(FilterState) onFiltersChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FilterModal(
            currentFilters: currentFilters,
            onFiltersChanged: onFiltersChanged,
          ),
    );
  }

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late FilterState _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle da modal
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              _buildHeader(theme, colorScheme),

              // Conteúdo scrollable
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodSection(theme, colorScheme),
                      const SizedBox(height: 24),
                      _buildProjectsSection(theme, colorScheme),
                      const SizedBox(height: 24),
                      _buildListsSection(theme, colorScheme),
                      const SizedBox(height: 24),
                      _buildStatusSection(theme, colorScheme),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Botões de ação
              _buildActionButtons(theme, colorScheme),
            ],
          );
        },
      ),
    );
  }

  /// Constrói o header da modal
  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            'Filtros Avançados',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_filters.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Ativos',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Constrói a seção de período
  Widget _buildPeriodSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, colorScheme, Icons.calendar_today, 'Período'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPeriodChip(theme, colorScheme, LogFilterPeriod.today, 'Hoje'),
            _buildPeriodChip(
              theme,
              colorScheme,
              LogFilterPeriod.yesterday,
              'Ontem',
            ),
            _buildPeriodChip(
              theme,
              colorScheme,
              LogFilterPeriod.week,
              'Esta Semana',
            ),
            _buildPeriodChip(
              theme,
              colorScheme,
              LogFilterPeriod.month,
              'Este Mês',
            ),
            _buildPeriodChip(
              theme,
              colorScheme,
              LogFilterPeriod.custom,
              'Personalizado',
            ),
          ],
        ),
        if (_filters.period == LogFilterPeriod.custom) ...[
          const SizedBox(height: 12),
          _buildCustomDateRange(theme, colorScheme),
        ],
      ],
    );
  }

  /// Constrói a seção de projetos
  Widget _buildProjectsSection(ThemeData theme, ColorScheme colorScheme) {
    return Consumer<TaskController>(
      builder: (context, taskController, child) {
        final projects = taskController.projects;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(theme, colorScheme, Icons.work, 'Projetos'),
            const SizedBox(height: 12),
            if (projects.isEmpty)
              Text(
                'Nenhum projeto encontrado',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    projects.map((project) {
                      return _buildProjectChip(theme, colorScheme, project);
                    }).toList(),
              ),
          ],
        );
      },
    );
  }

  /// Constrói a seção de listas
  Widget _buildListsSection(ThemeData theme, ColorScheme colorScheme) {
    return Consumer<TaskController>(
      builder: (context, taskController, child) {
        final lists = taskController.lists;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(theme, colorScheme, Icons.folder, 'Listas'),
            const SizedBox(height: 12),
            if (lists.isEmpty)
              Text(
                'Nenhuma lista encontrada',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    lists.map((list) {
                      return _buildListChip(theme, colorScheme, list);
                    }).toList(),
              ),
          ],
        );
      },
    );
  }

  /// Constrói a seção de status
  Widget _buildStatusSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          theme,
          colorScheme,
          Icons.assignment_turned_in,
          'Status',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatusChip(theme, colorScheme, LogFilterStatus.all, 'Todos'),
            _buildStatusChip(
              theme,
              colorScheme,
              LogFilterStatus.active,
              'Em Andamento',
            ),
            _buildStatusChip(
              theme,
              colorScheme,
              LogFilterStatus.completed,
              'Concluídos',
            ),
          ],
        ),
      ],
    );
  }

  /// Constrói o título de uma seção
  Widget _buildSectionTitle(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Constrói um chip de período
  Widget _buildPeriodChip(
    ThemeData theme,
    ColorScheme colorScheme,
    LogFilterPeriod period,
    String label,
  ) {
    final isSelected = _filters.period == period;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filters = _filters.copyWith(period: period);
          });
        }
      },
      selectedColor: colorScheme.primaryContainer,
      backgroundColor: colorScheme.surface,
      labelStyle: TextStyle(
        color:
            isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  /// Constrói um chip de projeto
  Widget _buildProjectChip(
    ThemeData theme,
    ColorScheme colorScheme,
    Project project,
  ) {
    final isSelected = _filters.selectedProjectIds.contains(project.id);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(project.emoji),
          const SizedBox(width: 4),
          Text(project.name),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          final newProjectIds = Set<String>.from(_filters.selectedProjectIds);
          if (selected) {
            newProjectIds.add(project.id);
          } else {
            newProjectIds.remove(project.id);
          }
          _filters = _filters.copyWith(selectedProjectIds: newProjectIds);
        });
      },
      selectedColor: project.color.withOpacity(0.3),
      backgroundColor: colorScheme.surface,
      checkmarkColor: project.color,
    );
  }

  /// Constrói um chip de lista
  Widget _buildListChip(
    ThemeData theme,
    ColorScheme colorScheme,
    TaskList list,
  ) {
    final isSelected = _filters.selectedListIds.contains(list.id);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(list.emoji), const SizedBox(width: 4), Text(list.name)],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          final newListIds = Set<String>.from(_filters.selectedListIds);
          if (selected) {
            newListIds.add(list.id);
          } else {
            newListIds.remove(list.id);
          }
          _filters = _filters.copyWith(selectedListIds: newListIds);
        });
      },
      selectedColor: list.color.withOpacity(0.3),
      backgroundColor: colorScheme.surface,
      checkmarkColor: list.color,
    );
  }

  /// Constrói um chip de status
  Widget _buildStatusChip(
    ThemeData theme,
    ColorScheme colorScheme,
    LogFilterStatus status,
    String label,
  ) {
    final isSelected = _filters.status == status;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filters = _filters.copyWith(status: status);
          });
        }
      },
      selectedColor: colorScheme.primaryContainer,
      backgroundColor: colorScheme.surface,
      labelStyle: TextStyle(
        color:
            isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  /// Constrói o seletor de range customizado
  Widget _buildCustomDateRange(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  theme,
                  colorScheme,
                  'Data Inicial',
                  _filters.customStartDate,
                  (date) => setState(() {
                    _filters = _filters.copyWith(customStartDate: date);
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateButton(
                  theme,
                  colorScheme,
                  'Data Final',
                  _filters.customEndDate,
                  (date) => setState(() {
                    _filters = _filters.copyWith(customEndDate: date);
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói um botão de data
  Widget _buildDateButton(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    DateTime? date,
    Function(DateTime?) onDateSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        OutlinedButton(
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            onDateSelected(selectedDate);
          },
          child: Text(
            date != null
                ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                : 'Selecionar',
          ),
        ),
      ],
    );
  }

  /// Constrói os botões de ação
  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Botão Limpar
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _filters = const FilterState();
                });
              },
              child: const Text('Limpar'),
            ),
          ),

          const SizedBox(width: 16),

          // Botão Aplicar
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.onFiltersChanged(_filters);
              },
              child: const Text('Aplicar Filtros'),
            ),
          ),
        ],
      ),
    );
  }
}
