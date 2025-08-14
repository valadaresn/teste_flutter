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

  /// 🖥️ Método estático para exibição desktop (dialog)
  static Future<void> showDesktop({
    required BuildContext context,
    required DiaryEntry entry,
    required NewDiary.DiaryController controller,
    VoidCallback? onDeleted,
    VoidCallback? onUpdated,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder:
          (context) => Align(
            alignment: Alignment.centerRight,
            child: DiaryDetailPanel(
              entry: entry,
              controller: controller,
              onDeleted: onDeleted,
              onUpdated: onUpdated,
              onClose: () => Navigator.of(context).pop(),
            ),
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
