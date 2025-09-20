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

/// **DetailPanelMobile** - Layout para mobile (tela cheia)
///
/// Implementação específica para dispositivos móveis:
/// - Tela cheia com Scaffold
/// - AppBar com botão de voltar
/// - Layout vertical otimizado para touch
/// - Navegação por push/pop
class DetailPanelMobile extends DetailPanelBase {
  const DetailPanelMobile({
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
  State<DetailPanelMobile> createState() => _DetailPanelMobileState();

  @override
  Widget buildLayout(BuildContext context) {
    // Implementação será feita no State
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
    return DetailPanelConstants.backgroundColorMobile;
  }

  @override
  Size getPanelSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  @override
  Map<String, dynamic> getPanelConfig() {
    return DetailPanelConfig.mobile.toMap();
  }
}

/// State para o painel mobile
class _DetailPanelMobileState extends State<DetailPanelMobile>
    with DetailPanelStateMixin, DetailPanelLogicMixin {
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
  }

  @override
  void dispose() {
    disposePanelState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.getBackgroundColor(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: DetailHeader(
          customContent: DetailDateDivider(
            dateTime: selectedDateTime,
            onDateTimeChanged: changeDateTime,
            isEditable: true,
          ),
          isSaving: isSaving,
          hasUnsavedChanges: hasUnsavedChanges,
          onClose: () => Navigator.of(context).pop(),
          showCloseButton: true,
          useAppBar: true,
          backgroundColor: widget.getBackgroundColor(context),
        ),
      ),
      body: _buildMobileBody(),
      // Comportamento padrão do Flutter - permite que o teclado ajuste a tela
    );
  }

  /// 📱 Constrói o corpo do layout mobile
  Widget _buildMobileBody() {
    return SafeArea(
      bottom: true, // Mantém SafeArea apenas no bottom
      child: Column(
        children: [
          // Área de conteúdo principal (expansível)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DetailPanelConstants.contentPadding,
                DetailPanelConstants.contentPadding,
                DetailPanelConstants.contentPadding,
                2, // Reduzida distância para o footer
              ),
              child: DetailContentEditor(
                controller: contentController,
                focusNode: contentFocusNode,
                onChanged: onContentChanged,
                autofocus: false,
              ),
            ),
          ),

          // Footer com ações
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DetailPanelConstants.contentPadding,
              0, // Sem distância do conteúdo
              DetailPanelConstants.contentPadding,
              12, // Distância do bottom aumentada
            ),
            child: DetailFooterActions(
              selectedMood: selectedMood,
              isFavorite: isFavorite,
              onEmojiTap: showEmojiPopup,
              onFavoriteTap: toggleFavorite,
              onDeleteTap: confirmDelete,
              showLabels: false, // Labels removidas
            ),
          ),
        ],
      ),
    );
  }
}

/// Extensão para converter config em Map
extension DetailPanelConfigExtension on DetailPanelConfig {
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
