import 'package:flutter/material.dart';
import '../utils/detail_panel_helpers.dart';
import 'detail_datetime_editor.dart';

/// **DetailDateDivider** - Divider discreto com data/hora
///
/// Componente que exibe a data/hora de criação da entrada
/// entre linhas divisórias, criando um separador visual elegante.
/// Agora com funcionalidade de edição ao clicar.
class DetailDateDivider extends StatelessWidget {
  final DateTime dateTime;
  final Color? dividerColor;
  final Color? textColor;
  final double? thickness;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final ValueChanged<DateTime>? onDateTimeChanged;
  final bool isEditable;

  const DetailDateDivider({
    Key? key,
    required this.dateTime,
    this.dividerColor,
    this.textColor,
    this.thickness,
    this.padding,
    this.textStyle,
    this.onDateTimeChanged,
    this.isEditable = true,
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

          // Container para data e hora com cliques separados
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 📅 Parte da data (clicável)
                GestureDetector(
                  onTap:
                      isEditable && onDateTimeChanged != null
                          ? () => _onDateTap(context)
                          : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration:
                        isEditable && onDateTimeChanged != null
                            ? BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            )
                            : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEditable && onDateTimeChanged != null) ...[
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          _formatDateOnly(dateTime),
                          style:
                              textStyle ??
                              TextStyle(
                                fontSize: 12,
                                color: textColor ?? Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Separador
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'às',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ),

                // ⏰ Parte da hora (clicável)
                GestureDetector(
                  onTap:
                      isEditable && onDateTimeChanged != null
                          ? () => _onTimeTap(context)
                          : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration:
                        isEditable && onDateTimeChanged != null
                            ? BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            )
                            : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEditable && onDateTimeChanged != null) ...[
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          _formatTimeOnly(dateTime),
                          style:
                              textStyle ??
                              TextStyle(
                                fontSize: 12,
                                color: textColor ?? Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

  /// 📅 Formata apenas a data
  String _formatDateOnly(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$day/$month/$year';
  }

  /// ⏰ Formata apenas a hora
  String _formatTimeOnly(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 📅 Manipula o toque na data para abrir o DatePicker
  void _onDateTap(BuildContext context) async {
    if (onDateTimeChanged == null) return;

    final newDateTime = await DetailDateTimeEditor.showDateOnly(
      context: context,
      initialDateTime: dateTime,
    );

    if (newDateTime != null) {
      onDateTimeChanged!(newDateTime);
    }
  }

  /// ⏰ Manipula o toque na hora para abrir o TimePicker
  void _onTimeTap(BuildContext context) async {
    if (onDateTimeChanged == null) return;

    final newDateTime = await DetailDateTimeEditor.showTimeOnly(
      context: context,
      initialDateTime: dateTime,
    );

    if (newDateTime != null) {
      onDateTimeChanged!(newDateTime);
    }
  }
}

/// **DetailDateDividerCompact** - Versão compacta do divider
///
/// Versão com menos padding para contextos mais compactos.
class DetailDateDividerCompact extends StatelessWidget {
  final DateTime dateTime;
  final Color? dividerColor;
  final Color? textColor;
  final ValueChanged<DateTime>? onDateTimeChanged;
  final bool isEditable;

  const DetailDateDividerCompact({
    Key? key,
    required this.dateTime,
    this.dividerColor,
    this.textColor,
    this.onDateTimeChanged,
    this.isEditable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailDateDivider(
      dateTime: dateTime,
      dividerColor: dividerColor,
      textColor: textColor,
      onDateTimeChanged: onDateTimeChanged,
      isEditable: isEditable,
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
  final ValueChanged<DateTime>? onDateTimeChanged;
  final bool isEditable;

  const DetailDateDividerVertical({
    Key? key,
    required this.dateTime,
    this.dividerColor,
    this.textColor,
    this.thickness,
    this.onDateTimeChanged,
    this.isEditable = true,
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

        // Container único clicável (abre seletor completo)
        GestureDetector(
          onTap:
              isEditable && onDateTimeChanged != null
                  ? () => _onDateTap(context)
                  : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration:
                isEditable && onDateTimeChanged != null
                    ? BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    )
                    : null,
            child: Column(
              children: [
                if (isEditable && onDateTimeChanged != null) ...[
                  Icon(
                    Icons.edit_calendar,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  DetailPanelHelpers.formatDateTime(dateTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor ?? Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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

  /// 📅 Abre seletor de data (versão vertical usa só um clique)
  void _onDateTap(BuildContext context) async {
    if (onDateTimeChanged == null) return;

    final newDateTime = await DetailDateTimeEditor.showDateOnly(
      context: context,
      initialDateTime: dateTime,
    );

    if (newDateTime != null) {
      onDateTimeChanged!(newDateTime);
    }
  }
}
