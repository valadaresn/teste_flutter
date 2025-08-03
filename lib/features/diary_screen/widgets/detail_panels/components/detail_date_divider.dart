import 'package:flutter/material.dart';
import '../utils/detail_panel_helpers.dart';

/// **DetailDateDivider** - Divider discreto com data/hora
///
/// Componente que exibe a data/hora de criação da entrada
/// entre linhas divisórias, criando um separador visual elegante.
class DetailDateDivider extends StatelessWidget {
  final DateTime dateTime;
  final Color? dividerColor;
  final Color? textColor;
  final double? thickness;
  final EdgeInsets? padding;
  final TextStyle? textStyle;

  const DetailDateDivider({
    Key? key,
    required this.dateTime,
    this.dividerColor,
    this.textColor,
    this.thickness,
    this.padding,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: dividerColor ?? Colors.grey.shade300,
              thickness: thickness ?? 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              DetailPanelHelpers.formatDateTime(dateTime),
              style:
                  textStyle ??
                  TextStyle(
                    fontSize: 12,
                    color: textColor ?? Colors.grey.shade600,
                  ),
            ),
          ),
          Expanded(
            child: Divider(
              color: dividerColor ?? Colors.grey.shade300,
              thickness: thickness ?? 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// **DetailDateDividerCompact** - Versão compacta do divider
///
/// Versão com menos padding para contextos mais compactos.
class DetailDateDividerCompact extends StatelessWidget {
  final DateTime dateTime;
  final Color? dividerColor;
  final Color? textColor;

  const DetailDateDividerCompact({
    Key? key,
    required this.dateTime,
    this.dividerColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailDateDivider(
      dateTime: dateTime,
      dividerColor: dividerColor,
      textColor: textColor,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      textStyle: TextStyle(
        fontSize: 10,
        color: textColor ?? Colors.grey.shade500,
      ),
    );
  }
}

/// **DetailDateDividerVertical** - Versão vertical do divider
///
/// Para layouts onde a data deve aparecer verticalmente.
class DetailDateDividerVertical extends StatelessWidget {
  final DateTime dateTime;
  final Color? dividerColor;
  final Color? textColor;
  final double? thickness;

  const DetailDateDividerVertical({
    Key? key,
    required this.dateTime,
    this.dividerColor,
    this.textColor,
    this.thickness,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: thickness ?? 0.5,
          height: 20,
          color: dividerColor ?? Colors.grey.shade300,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            DetailPanelHelpers.formatDateTime(dateTime),
            style: TextStyle(
              fontSize: 10,
              color: textColor ?? Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: thickness ?? 0.5,
          height: 20,
          color: dividerColor ?? Colors.grey.shade300,
        ),
      ],
    );
  }
}
