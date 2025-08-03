import 'package:flutter/material.dart';
import '../../../../../models/diary_entry.dart';
import '../../../../../screens/diary_screen/diary_controller.dart';

/// **DetailPanelBase** - Classe base abstrata para painéis de detalhes
///
/// Define a interface comum que todos os painéis de detalhes devem implementar.
/// Fornece estrutura base para mobile e desktop com callbacks padronizados.
abstract class DetailPanelBase extends StatefulWidget {
  /// Entrada do diário a ser editada
  final DiaryEntry entry;

  /// Controlador para operações CRUD
  final DiaryController controller;

  /// Callback chamado quando entrada é excluída
  final VoidCallback? onDeleted;

  /// Callback chamado quando entrada é atualizada
  final VoidCallback? onUpdated;

  /// Callback chamado quando painel é fechado (apenas desktop)
  final VoidCallback? onClose;

  const DetailPanelBase({
    Key? key,
    required this.entry,
    required this.controller,
    this.onDeleted,
    this.onUpdated,
    this.onClose,
  }) : super(key: key);

  /// 🏗️ Constrói o layout principal do painel
  Widget buildLayout(BuildContext context);

  /// 📋 Constrói o header do painel
  Widget buildHeader(BuildContext context);

  /// 📝 Constrói a área de conteúdo editável
  Widget buildContent(BuildContext context);

  /// 🔧 Constrói o rodapé com ações
  Widget buildFooter(BuildContext context);

  /// 🎨 Define a cor de fundo do painel
  Color getBackgroundColor(BuildContext context);

  /// 📐 Define as dimensões do painel
  Size getPanelSize(BuildContext context);

  /// ⚙️ Configurações específicas do painel
  Map<String, dynamic> getPanelConfig();
}

/// **DetailPanelConfig** - Configurações do painel
///
/// Classe utilitária para encapsular configurações específicas
/// de cada tipo de painel (mobile/desktop).
class DetailPanelConfig {
  final bool showAppBar;
  final bool showCloseButton;
  final bool isFullScreen;
  final bool hasAnimation;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  const DetailPanelConfig({
    this.showAppBar = false,
    this.showCloseButton = false,
    this.isFullScreen = false,
    this.hasAnimation = false,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius,
  });

  /// Configuração padrão para mobile
  static const mobile = DetailPanelConfig(
    showAppBar: true,
    showCloseButton: true,
    isFullScreen: true,
    hasAnimation: false,
  );

  /// Configuração padrão para desktop
  static const desktop = DetailPanelConfig(
    showAppBar: false,
    showCloseButton: true,
    isFullScreen: false,
    hasAnimation: true,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(12),
      bottomLeft: Radius.circular(12),
    ),
  );
}
