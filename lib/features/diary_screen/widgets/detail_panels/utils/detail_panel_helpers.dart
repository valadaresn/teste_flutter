import 'package:flutter/material.dart';
import 'detail_panel_constants.dart';

/// **DetailPanelHelpers** - Funções utilitárias para painéis
///
/// Contém métodos auxiliares para formatação, detecção de dispositivo,
/// criação de dados e exibição de feedback para os painéis de detalhes.
class DetailPanelHelpers {
  /// 📱 Detecta se é mobile ou desktop baseado na largura da tela
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <
        DetailPanelConstants.mobileBreakpoint;
  }

  /// 📊 Detecta se é tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= DetailPanelConstants.tabletBreakpoint &&
        width < DetailPanelConstants.desktopBreakpoint;
  }

  /// 🖥️ Detecta se é desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >=
        DetailPanelConstants.desktopBreakpoint;
  }

  /// 📅 Formata data e hora para exibição no formato brasileiro
  static String formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = DetailPanelConstants.monthsShort[dateTime.month];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year às $hour:$minute';
  }

  /// 📝 Cria mapa de dados para atualização de entrada
  static Map<String, dynamic> createUpdateData({
    required String content,
    required String mood,
    required bool isFavorite,
  }) {
    return {'content': content.trim(), 'mood': mood, 'isFavorite': isFavorite};
  }

  /// 📢 Mostra SnackBar padrão com estilo consistente
  static void showSnackBar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(DetailPanelConstants.contentPadding),
        duration: DetailPanelConstants.snackBarDuration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// 🎨 Obtém cor do fundo baseada no contexto (mobile/desktop)
  static Color getBackgroundColor(BuildContext context) {
    return isMobile(context)
        ? DetailPanelConstants.backgroundColorMobile
        : DetailPanelConstants.backgroundColorDesktop;
  }

  /// 📐 Calcula largura do painel baseada no dispositivo
  static double getPanelWidth(BuildContext context) {
    if (isMobile(context)) {
      return MediaQuery.of(context).size.width;
    }

    // Para tablet e desktop, usar largura fixa
    return DetailPanelConstants.desktopPanelWidth;
  }

  /// 🔍 Valida se o conteúdo foi modificado
  static bool hasContentChanged(String original, String current) {
    return original.trim() != current.trim();
  }

  /// ⚡ Cria configuração de animação padrão
  static AnimationController createAnimationController(
    TickerProvider vsync, {
    Duration? duration,
  }) {
    return AnimationController(
      duration: duration ?? DetailPanelConstants.slideAnimationDuration,
      vsync: vsync,
    );
  }

  /// 🎭 Cria animação de slide padrão
  static Animation<Offset> createSlideAnimation(
    AnimationController controller,
  ) {
    return Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: DetailPanelConstants.slideAnimationCurve,
      ),
    );
  }
}
