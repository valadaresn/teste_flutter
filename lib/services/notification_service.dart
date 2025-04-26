import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const windowsInit = WindowsInitializationSettings(
    appName: 'Pomodoro Tasks',
    appUserModelId: 'br.com.pomodorotasks',
    guid: '123e4567-e89b-12d3-a456-426614174000',
  );

  const initializationSettings = InitializationSettings(
    android: androidInit,
    windows: windowsInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _handleNotificationTap,
  );

  // Só verifica permissões em dispositivos móveis, não na web
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }
}

Future<void> _handleNotificationTap(NotificationResponse details) async {
  // A implementação correta para o Windows é através do protocol launcher
  // que é configurado no manifest do Windows
}

Future<void> showNotification(String title, String body) async {
  // Não mostra notificações na web
  if (kIsWeb) return;

  if (Platform.isAndroid) {
    final androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Notifications',
      channelDescription: 'Notificações de conclusão do pomodoro',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      enableLights: true,
      color: const Color(0xFF4CAF50),
      ledColor: const Color(0xFF4CAF50),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    final details = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, details);
  } else if (Platform.isWindows) {
    final windowsDetails = WindowsNotificationDetails();
    final details = NotificationDetails(windows: windowsDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, details);
  }
}
