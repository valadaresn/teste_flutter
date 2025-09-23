import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// 🔔 **NotificationUtils** - Utilitários para notificações padronizadas
///
/// **FUNCIONALIDADE:**
/// - Notificações do sistema + SnackBar coordenadas
/// - Estilo consistente para diferentes contextos
/// - Ações rápidas integradas na SnackBar (callback genérico)
///
/// **USADO POR:**
/// - PomodoroTimerModule - para timer de hábitos/tarefas
/// - TaskModule - para conclusão de tarefas
/// - HabitModule - para marcos de hábitos
/// - Qualquer módulo que precise de notificação + ação

/// � Notificação genérica com ação customizável
Future<void> showCustomNotification({
  required BuildContext context,
  required String title,
  required String message,
  Color? color,
  IconData? icon,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) async {
  // 🔔 Notificação do sistema (Windows/Android)
  await showNotification(title, message);

  // 📱 SnackBar na tela com ação customizável
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? Colors.black87,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}