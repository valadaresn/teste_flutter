import 'package:flutter/material.dart';
import '../../../models/diary_entry.dart';
import '../diary_controller.dart' as NewDiary;
import 'detail_panels/layouts/detail_panel_mobile.dart';
import 'detail_panels/layouts/detail_panel_desktop.dart';
import 'detail_panels/utils/detail_panel_helpers.dart';

/// **DiaryDetailPanel** - Ponto de entrada principal para painéis de detalhes
///
/// Factory que detecta automaticamente o tipo de dispositivo e usa:
/// - DetailPanelMobile para dispositivos móveis (tela cheia)
/// - DetailPanelDesktop para desktop/tablet (painel lateral)
///
/// Integra todos os componentes modulares criados:
/// - Core: DetailPanelBase, DetailPanelState, DetailPanelLogic
/// - Components: DetailHeader, DetailContentEditor, DetailDateDivider,
///               DetailFooterActions, DetailEmojiSelector
/// - Utils: DetailPanelConstants, DetailPanelHelpers
class DiaryDetailPanel extends StatelessWidget {
  final DiaryEntry entry;
  final NewDiary.DiaryController controller;
  final VoidCallback? onDeleted;
  final VoidCallback? onUpdated;
  final VoidCallback? onClose;

  const DiaryDetailPanel({
    Key? key,
    required this.entry,
    required this.controller,
    this.onDeleted,
    this.onUpdated,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 📱🖥️ Detecção automática de dispositivo
    if (DetailPanelHelpers.isMobile(context)) {
      // MOBILE: Navegação full-screen
      return DetailPanelMobile(
        entry: entry,
        controller: controller,
        onDeleted: onDeleted,
        onUpdated: onUpdated,
        onClose: onClose,
      );
    } else {
      // DESKTOP: Painel lateral
      return DetailPanelDesktop(
        entry: entry,
        controller: controller,
        onDeleted: onDeleted,
        onUpdated: onUpdated,
        onClose: onClose,
      );
    }
  }

  /// 📱 Método estático para navegação mobile (push)
  static Future<void> showMobile({
    required BuildContext context,
    required DiaryEntry entry,
    required NewDiary.DiaryController controller,
    VoidCallback? onDeleted,
    VoidCallback? onUpdated,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => DiaryDetailPanel(
              entry: entry,
              controller: controller,
              onDeleted: onDeleted,
              onUpdated: onUpdated,
            ),
      ),
    );
  }

  /// 🖥️ Método estático para exibição desktop (split-screen)
  static Future<void> showDesktop({
    required BuildContext context,
    required DiaryEntry entry,
    required NewDiary.DiaryController controller,
    VoidCallback? onDeleted,
    VoidCallback? onUpdated,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => _DesktopSplitScreen(
              entry: entry,
              controller: controller,
              onDeleted: onDeleted,
              onUpdated: onUpdated,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        barrierColor: Colors.black.withOpacity(0.1),
        opaque: false,
        maintainState: true,
      ),
    );
  }

  /// 🔄 Método estático para abertura automática (detecta dispositivo)
  static Future<void> showAuto({
    required BuildContext context,
    required DiaryEntry entry,
    required NewDiary.DiaryController controller,
    VoidCallback? onDeleted,
    VoidCallback? onUpdated,
  }) {
    if (DetailPanelHelpers.isMobile(context)) {
      return showMobile(
        context: context,
        entry: entry,
        controller: controller,
        onDeleted: onDeleted,
        onUpdated: onUpdated,
      );
    } else {
      return showDesktop(
        context: context,
        entry: entry,
        controller: controller,
        onDeleted: onDeleted,
        onUpdated: onUpdated,
      );
    }
  }
}

/// 🖥️ Layout split-screen para desktop (painel à direita + conteúdo à esquerda)
class _DesktopSplitScreen extends StatelessWidget {
  final DiaryEntry entry;
  final NewDiary.DiaryController controller;
  final VoidCallback? onDeleted;
  final VoidCallback? onUpdated;

  const _DesktopSplitScreen({
    Key? key,
    required this.entry,
    required this.controller,
    this.onDeleted,
    this.onUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.1),
      body: SafeArea(
        child: Row(
          children: [
            // 📱 Área esquerda (tela original, semi-transparente)
            Expanded(
              flex: 7,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Text(
                      'Toque para voltar',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 🖥️ Painel direito (detail panel)
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DetailPanelDesktop(
                    entry: entry,
                    controller: controller,
                    onDeleted: () {
                      onDeleted?.call();
                      Navigator.of(context).pop();
                    },
                    onUpdated: onUpdated,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
