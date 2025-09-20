import 'package:flutter/material.dart';

/// **DetailDateTimeEditor** - Editor de data e hora
///
/// Componente que fornece métodos estáticos para editar data ou hora separadamente.
/// Clique direto na data = DatePicker. Clique direto na hora = TimePicker.
class DetailDateTimeEditor {
  /// 📅 Mostra seletor nativo de data
  static Future<DateTime?> showDateOnly({
    required BuildContext context,
    required DateTime initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Colors.pink.shade400),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return null;

    // Retorna nova data mantendo a hora original
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      initialDateTime.hour,
      initialDateTime.minute,
    );
  }

  /// ⏰ Mostra seletor nativo de hora
  static Future<DateTime?> showTimeOnly({
    required BuildContext context,
    required DateTime initialDateTime,
  }) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
      initialEntryMode:
          TimePickerEntryMode.input, // 🎯 Modo de entrada de texto
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Colors.pink.shade400),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null) return null;

    // Retorna nova hora mantendo a data original
    return DateTime(
      initialDateTime.year,
      initialDateTime.month,
      initialDateTime.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }
}
