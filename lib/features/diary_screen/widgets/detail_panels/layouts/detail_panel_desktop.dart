import 'package:flutter/material.dart';
import '../../../../../models/diary_entry.dart';
import '../../../diary_controller.dart' as NewDiary;
import '../core/detail_panel_base.dart';
import '../core/detail_panel_state.dart';
import '../core/detail_panel_logic.dart';
import '../components/detail_header.dart';
import '../components/detail_content_editor.dart';
import '../components/detail_date_divider.dart';
import '../components/detail_footer_actions.dart';
import '../utils/detail_panel_constants.dart';
import '../utils/detail_panel_helpers.dart';

/// **DetailPanelDesktop** - Layout para desktop (painel lateral)
///
/// Implementação específica para desktop:
/// - Painel lateral com largura fixa
/// - Animação de slide da direita para esquerda
/// - Layout otimizado para mouse/keyboard
/// - Exibição em overlay/dialog
class DetailPanelDesktop extends DetailPanelBase {
  const DetailPanelDesktop({
    Key? key,
    required DiaryEntry entry,
    required NewDiary.DiaryController controller,
    VoidCallback? onDeleted,
    VoidCallback? onUpdated,
    VoidCallback? onClose,
  }) : super(
         key: key,
         entry: entry,
         controller: controller,
         onDeleted: onDeleted,
         onUpdated: onUpdated,
         onClose: onClose,
       );

  @override
  State<DetailPanelDesktop> createState() => _DetailPanelDesktopState();

  @override
  Widget buildLayout(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget buildHeader(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget buildContent(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget buildFooter(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Color getBackgroundColor(BuildContext context) {
    return DetailPanelConstants.backgroundColorDesktop;
  }

  @override
  Size getPanelSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Size(DetailPanelConstants.desktopPanelWidth, screenSize.height);
  }

  @override
  Map<String, dynamic> getPanelConfig() {
    return DetailPanelConfig.desktop.toMap();
  }
}

/// State para o painel desktop
class _DetailPanelDesktopState extends State<DetailPanelDesktop>
    with
        DetailPanelStateMixin,
        DetailPanelLogicMixin,
        SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  DiaryEntry get entry => widget.entry;

  @override
  NewDiary.DiaryController get controller => widget.controller;

  @override
  VoidCallback? get onDeleted => widget.onDeleted;

  @override
  VoidCallback? get onUpdated => widget.onUpdated;

  @override
  void initState() {
    super.initState();
    initializePanelState();
    _initializeAnimation();
  }

  @override
  void dispose() {
    disposePanelState();
    _animationController.dispose();
    super.dispose();
  }

  /// 🎭 Inicializa a animação de slide
  void _initializeAnimation() {
    _animationController = DetailPanelHelpers.createAnimationController(this);
    _slideAnimation = DetailPanelHelpers.createSlideAnimation(
      _animationController,
    );

    // Inicia a animação de entrada
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildDesktopPanel(),
      ),
    );
  }

  /// 🖥️ Constrói o painel desktop
  Widget _buildDesktopPanel() {
    return Container(
      width: DetailPanelConstants.desktopPanelWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: widget.getBackgroundColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          DetailHeader(
            title: 'Editar Entrada',
            isSaving: isSaving,
            hasUnsavedChanges: hasUnsavedChanges,
            onClose: _closePanel,
            showCloseButton: true,
            useAppBar: false,
            backgroundColor: widget.getBackgroundColor(context),
          ),

          // Conteúdo
          Expanded(child: _buildDesktopBody()),
        ],
      ),
    );
  }

  /// 📝 Constrói o corpo do painel desktop
  Widget _buildDesktopBody() {
    return Padding(
      padding: const EdgeInsets.all(DetailPanelConstants.contentPadding),
      child: Column(
        children: [
          // Área de conteúdo principal (expansível)
          Expanded(
            child: DetailContentEditor(
              controller: contentController,
              focusNode: contentFocusNode,
              onChanged: onContentChanged,
              autofocus: false,
            ),
          ),

          const SizedBox(height: 16),

          // Divider com data
          DetailDateDivider(dateTime: entry.dateTime),

          const SizedBox(height: 16),

          // Footer com ações
          DetailFooterActions(
            selectedMood: selectedMood,
            isFavorite: isFavorite,
            onEmojiTap: showEmojiPopup,
            onFavoriteTap: toggleFavorite,
            onDeleteTap: confirmDelete,
            showLabels: false, // Sem labels no desktop (mais compacto)
          ),
        ],
      ),
    );
  }

  /// 🚪 Fecha o painel com animação
  void _closePanel() {
    _animationController.reverse().then((_) {
      widget.onClose?.call();
    });
  }
}

/// Extensão para converter config em Map (evitar duplicação)
extension DetailPanelConfigMap on DetailPanelConfig {
  Map<String, dynamic> toMap() {
    return {
      'showAppBar': showAppBar,
      'showCloseButton': showCloseButton,
      'isFullScreen': isFullScreen,
      'hasAnimation': hasAnimation,
      'padding': padding,
      'borderRadius': borderRadius,
    };
  }
}
