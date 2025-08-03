import 'package:flutter/material.dart';
import '../utils/detail_panel_constants.dart';

/// **DetailContentEditor** - Editor de conteúdo principal
///
/// Componente responsável pela área de edição de texto:
/// - TextField expansível e sem decoração
/// - Configurações de foco e comportamento
/// - Estilo consistente entre mobile e desktop
/// - Callbacks para mudanças e foco
class DetailContentEditor extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool autofocus;
  final Color? backgroundColor;
  final String? hintText;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Border? border;
  final bool expands;
  final int? maxLines;

  const DetailContentEditor({
    Key? key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onTap,
    this.autofocus = false,
    this.backgroundColor,
    this.hintText,
    this.textStyle,
    this.padding,
    this.borderRadius,
    this.border,
    this.expands = true,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? const EdgeInsets.all(DetailPanelConstants.contentPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? DetailPanelConstants.contentBackgroundColor,
        borderRadius:
            borderRadius ??
            BorderRadius.circular(DetailPanelConstants.borderRadius),
        border: border ?? Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        maxLines: expands ? null : maxLines,
        expands: expands,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText ?? 'O que você quer registrar?',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: DetailPanelConstants.hintTextSize,
          ),
        ),
        style:
            textStyle ??
            const TextStyle(
              fontSize: DetailPanelConstants.textFieldFontSize,
              height: DetailPanelConstants.textFieldLineHeight,
            ),
      ),
    );
  }
}

/// **DetailContentEditorCompact** - Versão compacta do editor
///
/// Versão com altura fixa para contextos onde não se quer expansão total.
class DetailContentEditorCompact extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final double height;
  final Color? backgroundColor;
  final String? hintText;

  const DetailContentEditorCompact({
    Key? key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.height = 120.0,
    this.backgroundColor,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DetailContentEditor(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        backgroundColor: backgroundColor,
        hintText: hintText,
        expands: false,
        maxLines: null,
      ),
    );
  }
}

/// **DetailContentEditorReadOnly** - Versão somente leitura
///
/// Para exibir conteúdo sem permitir edição.
class DetailContentEditorReadOnly extends StatelessWidget {
  final String content;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  const DetailContentEditorReadOnly({
    Key? key,
    required this.content,
    this.backgroundColor,
    this.textStyle,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? const EdgeInsets.all(DetailPanelConstants.contentPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? DetailPanelConstants.contentBackgroundColor,
        borderRadius: BorderRadius.circular(DetailPanelConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Text(
        content.isEmpty ? 'Sem conteúdo' : content,
        style:
            textStyle ??
            const TextStyle(
              fontSize: DetailPanelConstants.textFieldFontSize,
              height: DetailPanelConstants.textFieldLineHeight,
              color: Colors.black87,
            ),
      ),
    );
  }
}
