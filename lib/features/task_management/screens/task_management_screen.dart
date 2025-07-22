import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/task_controller.dart';
import '../themes/theme_provider.dart';
import '../themes/app_theme.dart';
import '../widgets/common/app_state_handler.dart'; // Novo componente extraído
import '../widgets/lists/list_panel.dart'; // Novo componente extraído
import '../widgets/projects/project_panel.dart'; // Novo componente extraído
import '../widgets/tasks/task_panel.dart'; // Novo componente extraído
import '../widgets/tasks/task_detail_panel.dart';
import '../widgets/subtasks/clean_task_panel.dart';
import '../widgets/today/today_panel.dart';
import '../widgets/layouts/samsung_style/index.dart'; // Novo import para Samsung sidebar
import '../../log_screen/controllers/log_controller.dart';
import '../../log_screen/screens/log_screen.dart';
import '../../log_screen/screens/daily_activities_screen.dart'; // Import para tela de atividades
import '../screens/settings_screen.dart'; // Import para configurações

/// Tipos de layout responsivo
enum LayoutType { mobile, tablet, desktop }

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({Key? key}) : super(key: key);

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen>
    with SingleTickerProviderStateMixin {
  bool _isSidebarExpanded = true; // Estado da sidebar
  late AnimationController _animationController;
  late Animation<double> _sidebarAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadSidebarState();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _sidebarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Iniciar com sidebar expandida
    _animationController.value = 1.0;
  }

  Future<void> _loadSidebarState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isExpanded = prefs.getBool('sidebar_expanded') ?? true;
      setState(() {
        _isSidebarExpanded = isExpanded;
        if (_isSidebarExpanded) {
          _animationController.value = 1.0;
        } else {
          _animationController.value = 0.0;
        }
      });
    } catch (e) {
      // Ignorar erro e usar valor padrão
    }
  }

  Future<void> _toggleSidebar() async {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });

    if (_isSidebarExpanded) {
      await _animationController.forward();
    } else {
      await _animationController.reverse();
    }

    // Salvar estado
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sidebar_expanded', _isSidebarExpanded);
    } catch (e) {
      // Ignorar erro de salvamento
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Detecta o tipo de layout baseado na largura da tela
  LayoutType _getLayoutType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return LayoutType.mobile;
    if (width < 1024) return LayoutType.tablet;
    return LayoutType.desktop;
  }

  /// Constrói o layout responsivo baseado no tipo de tela
  Widget _buildResponsiveLayout(
    BuildContext context,
    TaskController controller,
    LayoutType layoutType,
  ) {
    switch (layoutType) {
      case LayoutType.mobile:
        return _buildMobileLayout(context, controller);
      case LayoutType.tablet:
        return _buildTabletLayout(context, controller);
      case LayoutType.desktop:
        return _buildDesktopLayout(context, controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final layoutType = _getLayoutType(context);

    return Consumer<TaskController>(
      builder: (context, controller, _) {
        return Scaffold(
          drawer:
              (layoutType == LayoutType.mobile ||
                      layoutType == LayoutType.tablet)
                  ? _buildSidebarDrawer(context, controller)
                  : null,
          body: AppStateHandler(
            controller: controller,
            child: _buildResponsiveLayout(context, controller, layoutType),
          ),
          floatingActionButton: _buildFloatingActionButton(context, controller),
        );
      },
    );
  }

  /// Layout para Desktop (> 1024px) - Layout atual completo
  Widget _buildDesktopLayout(BuildContext context, TaskController controller) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Row(
          children: [
            // Painel lateral esquerdo - Animado
            AnimatedBuilder(
              animation: _sidebarAnimation,
              builder: (context, child) {
                final sidebarWidth = _sidebarAnimation.value * 280;

                return Container(
                  width: sidebarWidth < 20 ? 0 : sidebarWidth,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child:
                      sidebarWidth > 100
                          ? _buildSidebar(context, controller, themeProvider)
                          : null, // Ocultar completamente quando muito pequeno
                );
              },
            ),

            // Área principal - Tarefas ou Visualização Hoje
            Expanded(
              child: Container(
                color: themeProvider.getBackgroundColor(
                  context,
                  listColor:
                      controller.selectedListId != null
                          ? controller
                              .getListById(controller.selectedListId!)
                              ?.color
                          : null,
                ),
                child:
                    controller.showTodayView
                        ? TodayPanel(
                          controller: controller,
                          onToggleSidebar: _toggleSidebar,
                        )
                        : controller.showActivitiesView
                        ? _buildActivitiesPanel(context, controller)
                        : TaskPanel(
                          controller: controller,
                          onShowSearch:
                              () => _showSearchDialog(context, controller),
                          onShowFilter:
                              () => _showFilterDialog(context, controller),
                          onToggleSidebar: _toggleSidebar,
                        ),
              ),
            ),

            // Painel lateral direito - Detalhes da tarefa (se houver tarefa selecionada)
            if (controller.selectedTaskId != null)
              Container(
                width: 400,
                decoration: BoxDecoration(
                  color: themeProvider.getBackgroundColor(
                    context,
                    listColor:
                        controller.selectedListId != null
                            ? controller
                                .getListById(controller.selectedListId!)
                                ?.color
                            : null,
                  ),
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child:
                    controller.showTodayView
                        ? CleanTaskPanel(controller: controller)
                        : TaskDetailPanel(
                          task: controller.getSelectedTask()!,
                          controller: controller,
                          onClose: () => controller.selectTask(null),
                        ),
              ),
          ],
        );
      },
    );
  }

  /// Layout para Tablet (600px - 1024px) - Painel principal com sidebar direita igual desktop
  Widget _buildTabletLayout(BuildContext context, TaskController controller) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Row(
          children: [
            // Área principal
            Expanded(
              child: Container(
                color: themeProvider.getBackgroundColor(
                  context,
                  listColor:
                      controller.selectedListId != null
                          ? controller
                              .getListById(controller.selectedListId!)
                              ?.color
                          : null,
                ),
                child:
                    controller.showTodayView
                        ? TodayPanel(
                          controller: controller,
                          onToggleSidebar:
                              () => Scaffold.of(context).openDrawer(),
                        )
                        : controller.showActivitiesView
                        ? _buildActivitiesPanel(context, controller)
                        : TaskPanel(
                          controller: controller,
                          onShowSearch:
                              () => _showSearchDialog(context, controller),
                          onShowFilter:
                              () => _showFilterDialog(context, controller),
                          onToggleSidebar:
                              () => Scaffold.of(context).openDrawer(),
                        ),
              ),
            ),

            // Painel lateral direito - Detalhes da tarefa (igual desktop, mas menor)
            if (controller.selectedTaskId != null)
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: themeProvider.getBackgroundColor(
                    context,
                    listColor:
                        controller.selectedListId != null
                            ? controller
                                .getListById(controller.selectedListId!)
                                ?.color
                            : null,
                  ),
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child:
                    controller.showTodayView
                        ? CleanTaskPanel(controller: controller)
                        : TaskDetailPanel(
                          task: controller.getSelectedTask()!,
                          controller: controller,
                          onClose: () => controller.selectTask(null),
                        ),
              ),
          ],
        );
      },
    );
  }

  /// Layout para Mobile (< 600px) - Sidebar como drawer + bottom navigation
  Widget _buildMobileLayout(BuildContext context, TaskController controller) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          color: themeProvider.getBackgroundColor(
            context,
            listColor:
                controller.selectedListId != null
                    ? controller.getListById(controller.selectedListId!)?.color
                    : null,
          ),
          child: Stack(
            children: [
              // Painel principal full-width
              controller.showTodayView
                  ? TodayPanel(
                    controller: controller,
                    onToggleSidebar: () => Scaffold.of(context).openDrawer(),
                  )
                  : controller.showActivitiesView
                  ? _buildActivitiesPanel(context, controller)
                  : TaskPanel(
                    controller: controller,
                    onShowSearch: () => _showSearchDialog(context, controller),
                    onShowFilter: () => _showFilterDialog(context, controller),
                    onToggleSidebar: () => Scaffold.of(context).openDrawer(),
                  ),

              // Task details como modal bottom sheet (se houver tarefa selecionada)
              if (controller.selectedTaskId != null)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => controller.selectTask(null),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () {}, // Evita fechar ao tocar no conteúdo
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: themeProvider.getBackgroundColor(
                                context,
                                listColor:
                                    controller.selectedListId != null
                                        ? controller
                                            .getListById(
                                              controller.selectedListId!,
                                            )
                                            ?.color
                                        : null,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child:
                                controller.showTodayView
                                    ? CleanTaskPanel(controller: controller)
                                    : TaskDetailPanel(
                                      task: controller.getSelectedTask()!,
                                      controller: controller,
                                      onClose:
                                          () => controller.selectTask(null),
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Drawer com sidebar completa para mobile e tablet
  Widget _buildSidebarDrawer(BuildContext context, TaskController controller) {
    final layoutType = _getLayoutType(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Drawer(
          width:
              layoutType == LayoutType.mobile
                  ? MediaQuery.of(context).size.width *
                      0.85 // 85% da tela no mobile
                  : 280,
          backgroundColor: themeProvider.getSidebarColor(context),
          child: _buildSidebar(context, controller, themeProvider),
        );
      },
    );
  }

  /// Constrói o sidebar escolhendo entre o tema padrão e Samsung Notes
  Widget _buildSidebar(
    BuildContext context,
    TaskController controller,
    ThemeProvider themeProvider,
  ) {
    // Se o tema Samsung Notes estiver selecionado, usar o novo sidebar
    if (themeProvider.sidebarTheme == SidebarTheme.samsungNotes) {
      return SamsungSidebar(controller: controller);
    }

    // Caso contrário, usar o sidebar padrão
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: themeProvider.getSidebarColor(context),
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // SEÇÃO HOJE - Botão sempre visível na sidebar
          _buildTodaySection(context, controller),
          Container(height: 1, color: Theme.of(context).dividerColor),

          // SEÇÃO ATIVIDADES DO DIA - Nova seção
          _buildActivitiesSection(context, controller),
          Container(height: 1, color: Theme.of(context).dividerColor),

          // SEÇÃO LOGS - Nova seção para logs
          _buildLogsSection(context, controller),
          Container(height: 1, color: Theme.of(context).dividerColor),

          // SEÇÃO DE PROJETOS - Extraída para componente separado
          ProjectPanel(controller: controller),

          // DIVISOR
          Container(height: 1, color: Theme.of(context).dividerColor),

          // SEÇÃO DE LISTAS - Extraída para componente separado
          ListPanel(controller: controller),

          // DIVISOR
          Container(height: 1, color: Theme.of(context).dividerColor),

          // SEÇÃO CONFIGURAÇÕES
          _buildSettingsSection(context),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    TaskController controller,
  ) {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Implementar diálogo de criação de tarefa
        print('➕ Criar nova tarefa');
      },
      tooltip: 'Nova Tarefa',
      child: const Icon(Icons.add),
    );
  }

  void _showSearchDialog(BuildContext context, TaskController controller) {
    // TODO: Implementar diálogo de busca
    print('🔍 Mostrar diálogo de busca');
  }

  void _showFilterDialog(BuildContext context, TaskController controller) {
    // TODO: Implementar diálogo de filtros
    print('🔽 Mostrar diálogo de filtros');
  }

  /// Constrói a seção "Hoje" na sidebar
  Widget _buildTodaySection(BuildContext context, TaskController controller) {
    final todayTasks = controller.getTodayTasks();
    final overdueTasks = controller.getOverdueTasks();
    final totalCount = todayTasks.length + overdueTasks.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.today,
          size: 20,
          color:
              controller.showTodayView ? Theme.of(context).primaryColor : null,
        ),
        title: Text(
          'Hoje',
          style: TextStyle(
            fontWeight:
                controller.showTodayView ? FontWeight.bold : FontWeight.normal,
            color:
                controller.showTodayView
                    ? Theme.of(context).primaryColor
                    : null,
          ),
        ),
        trailing:
            totalCount > 0
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        controller.showTodayView
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$totalCount',
                    style: TextStyle(
                      color:
                          controller.showTodayView
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                : null,
        selected: controller.showTodayView,
        onTap: () => controller.toggleTodayView(),
      ),
    );
  }

  /// Constrói a seção "Atividades do Dia" na sidebar
  Widget _buildActivitiesSection(
    BuildContext context,
    TaskController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.event_note_outlined,
          size: 20,
          color:
              controller.showActivitiesView
                  ? Theme.of(context).primaryColor
                  : null,
        ),
        title: Text(
          'Atividades do Dia',
          style: TextStyle(
            fontWeight:
                controller.showActivitiesView
                    ? FontWeight.bold
                    : FontWeight.normal,
            color:
                controller.showActivitiesView
                    ? Theme.of(context).primaryColor
                    : null,
          ),
        ),
        selected: controller.showActivitiesView,
        onTap: () => controller.toggleActivitiesView(),
      ),
    );
  }

  /// Constrói a seção "Logs" na sidebar
  Widget _buildLogsSection(BuildContext context, TaskController controller) {
    return Consumer<LogController>(
      builder: (context, logController, child) {
        final activeLogs = logController.getActiveLogsList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            dense: true,
            leading: Icon(
              Icons.access_time,
              size: 20,
              color:
                  activeLogs.isNotEmpty
                      ? Theme.of(context).colorScheme.primary
                      : null,
            ),
            title: const Text('Logs de Atividade'),
            trailing:
                activeLogs.isNotEmpty
                    ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${activeLogs.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    : null,
            onTap: () => _navigateToLogs(context),
          ),
        );
      },
    );
  }

  /// Navega para a tela de logs
  void _navigateToLogs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogScreen()),
    );
  }

  /// Constrói a seção "Configurações" na sidebar
  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.settings_outlined, size: 20),
        title: const Text('Configurações'),
        onTap: () => _navigateToSettings(context),
      ),
    );
  }

  /// Navega para a tela de configurações
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  /// Constrói o painel da visualização "Atividades do Dia" na área principal
  Widget _buildActivitiesPanel(
    BuildContext context,
    TaskController controller,
  ) {
    return const DailyActivitiesScreen();
  }
}
