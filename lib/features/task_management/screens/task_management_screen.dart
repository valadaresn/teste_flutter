import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/task_controller.dart';
import '../themes/theme_provider.dart';
import '../filters/basic_filters.dart';
import '../widgets/common/app_state_handler.dart'; // Novo componente extraído
import '../widgets/tasks/task_panel.dart'; // Componente de tarefas
import '../widgets/tasks/detail/task_detail_panel_clean.dart';
import '../widgets/tasks/views/today_view.dart';
import '../widgets/sidebar/task_sidebar.dart'; // Novo componente extraído
import '../../log_screen/screens/daily_activities_screen.dart'; // Import para tela de atividades

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
          // FAB removido completamente
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
                          ? TaskSidebar(controller: controller)
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
                        ? TodayView(
                          controller: controller,
                          onToggleSidebar: _toggleSidebar,
                        )
                        : controller.showActivitiesView
                        ? _buildActivitiesPanel(context, controller)
                        : controller.selectedListId != null
                        ? TaskPanel(
                          controller: controller,
                          filter: ListFilter(
                            controller.selectedListId!,
                            controller
                                    .getListById(controller.selectedListId!)
                                    ?.name ??
                                'Lista',
                          ), // 🎯 Filtro externo para lista específica
                          onToggleSidebar: _toggleSidebar,
                        )
                        : TaskPanel(
                          controller: controller,
                          filter:
                              AllTasksFilter(), // 🎯 Filtro externo para todas as tarefas
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
                child: TaskDetailPanel(controller: controller),
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
                        ? TodayView(
                          controller: controller,
                          onToggleSidebar:
                              () => Scaffold.of(context).openDrawer(),
                        )
                        : controller.showActivitiesView
                        ? _buildActivitiesPanel(context, controller)
                        : controller.selectedListId != null
                        ? TaskPanel(
                          controller: controller,
                          filter: ListFilter(
                            controller.selectedListId!,
                            controller
                                    .getListById(controller.selectedListId!)
                                    ?.name ??
                                'Lista',
                          ), // 🎯 Filtro externo para lista específica
                          onToggleSidebar:
                              () => Scaffold.of(context).openDrawer(),
                        )
                        : TaskPanel(
                          controller: controller,
                          filter:
                              AllTasksFilter(), // 🎯 Filtro externo para todas as tarefas
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
                child: TaskDetailPanel(controller: controller),
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
                  ? TodayView(
                    controller: controller,
                    onToggleSidebar: () => Scaffold.of(context).openDrawer(),
                  )
                  : controller.showActivitiesView
                  ? _buildActivitiesPanel(context, controller)
                  : controller.selectedListId != null
                  ? TaskPanel(
                    controller: controller,
                    filter: ListFilter(
                      controller.selectedListId!,
                      controller
                              .getListById(controller.selectedListId!)
                              ?.name ??
                          'Lista',
                    ), // 🎯 Filtro externo para lista específica
                    onToggleSidebar: () => Scaffold.of(context).openDrawer(),
                  )
                  : TaskPanel(
                    controller: controller,
                    filter:
                        AllTasksFilter(), // 🎯 Filtro externo para todas as tarefas
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
                            child: TaskDetailPanel(controller: controller),
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
          child: TaskSidebar(controller: controller),
        );
      },
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
