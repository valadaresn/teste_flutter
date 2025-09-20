import 'package:flutter/material.dart';
import '../utils/detail_panel_constants.dart';

/// **DetailHeader** - Header do painel com título e indicadores de status
///
/// Componente reutilizável que mostra:
/// - Título do painel ou widget customizado
/// - Botão de fechar (opcional)
/// - Indicadores de salvamento/alterações pendentes
/// - Suporte para AppBar (mobile) ou Container (desktop)
class DetailHeader extends StatelessWidget {
  final String? title;
  final Widget? customContent;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final bool useAppBar;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const DetailHeader({
    Key? key,
    this.title,
    this.customContent,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.onClose,
    this.showCloseButton = true,
    this.useAppBar = false,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useAppBar) {
      return _buildAppBar(context);
    } else {
      return _buildContainer(context);
    }
  }

  /// 📱 Constrói AppBar para mobile
  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: customContent ?? Text(title ?? ''),
      backgroundColor:
          backgroundColor ?? DetailPanelConstants.backgroundColorMobile,
      foregroundColor: foregroundColor,
      elevation: 0,
      leading:
          showCloseButton && onClose != null
              ? IconButton(onPressed: onClose, icon: const Icon(Icons.close))
              : null,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: _buildStatusIndicator(),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey.shade300),
      ),
    );
  }

  /// 🖥️ Constrói Container para desktop
  Widget _buildContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DetailPanelConstants.headerPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? DetailPanelConstants.backgroundColorDesktop,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Botão fechar
          if (showCloseButton && onClose != null)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              color: Colors.grey.shade700,
            ),

          // Conteúdo principal (título ou widget customizado)
          Expanded(
            child:
                customContent ??
                Text(
                  title ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: foregroundColor ?? Colors.black87,
                  ),
                ),
          ),

          // Indicador de status
          _buildStatusIndicator(),
        ],
      ),
    );
  }

  /// 🔄 Constrói indicador de status (salvando/alterações pendentes)
  Widget _buildStatusIndicator() {
    if (isSaving) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
        ),
      );
    } else if (hasUnsavedChanges) {
      return Icon(Icons.circle, size: 8, color: Colors.orange.shade600);
    }

    return const SizedBox(width: 16, height: 16);
  }
}

/// **DetailHeaderPreferredSize** - Wrapper para usar DetailHeader como PreferredSizeWidget
///
/// Permite usar o DetailHeader em Scaffold.appBar quando necessário.
class DetailHeaderPreferredSize extends StatelessWidget
    implements PreferredSizeWidget {
  final DetailHeader header;

  const DetailHeaderPreferredSize({Key? key, required this.header})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return header;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
