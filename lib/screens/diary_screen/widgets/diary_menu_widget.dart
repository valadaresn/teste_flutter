import 'package:flutter/material.dart';
import 'diary_card.dart'; // Import for DiaryCardLayout enum

/// Widget that builds the app bar menu items for the diary screen
class DiaryMenuWidget {
  /// Builds the popup menu items for the diary screen
  static List<PopupMenuEntry<String>> buildMenuItems({
    required DiaryCardLayout cardLayout,
    required String currentView,
  }) {
    return [
      PopupMenuItem(
        value: 'view_standard',
        child: Row(
          children: [
            const Icon(Icons.view_agenda),
            const SizedBox(width: 8),
            const Text('Visualização Completa'),
            const Spacer(),
            if (cardLayout == DiaryCardLayout.standard)
              const Icon(Icons.check, size: 20),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'view_clean',
        child: Row(
          children: [
            const Icon(Icons.view_stream),
            const SizedBox(width: 8),
            const Text('Visualização Simples'),
            const Spacer(),
            if (cardLayout == DiaryCardLayout.clean)
              const Icon(Icons.check, size: 20),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'view_timeline',
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            const Text('Por Data'),
            const Spacer(),
            if (currentView == 'timeline') const Icon(Icons.check, size: 20),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'view_favorites',
        child: Row(
          children: [
            const Icon(Icons.star),
            const SizedBox(width: 8),
            const Text('Favoritos'),
            const Spacer(),
            if (currentView == 'favorites') const Icon(Icons.check, size: 20),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'view_mood',
        child: Row(
          children: [
            const Icon(Icons.emoji_emotions),
            const SizedBox(width: 8),
            const Text('Por Humor'),
            const Spacer(),
            if (currentView == 'mood') const Icon(Icons.check, size: 20),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'view_tags',
        child: Row(
          children: [
            const Icon(Icons.tag),
            const SizedBox(width: 8),
            const Text('Por Tags'),
            const Spacer(),
            if (currentView == 'tags') const Icon(Icons.check, size: 20),
          ],
        ),
      ),
    ];
  }

  /// Handles the selected menu item
  static String handleMenuSelection(
    String value, {
    required Function(DiaryCardLayout) onLayoutChanged,
    required Function(String) onViewChanged,
  }) {
    String newView = '';

    switch (value) {
      case 'view_clean':
        onLayoutChanged(DiaryCardLayout.clean);
        break;
      case 'view_standard':
        onLayoutChanged(DiaryCardLayout.standard);
        break;
      case 'view_timeline':
        newView = 'timeline';
        onViewChanged(newView);
        break;
      case 'view_favorites':
        newView = 'favorites';
        onViewChanged(newView);
        break;
      case 'view_mood':
        newView = 'mood';
        onViewChanged(newView);
        break;
      case 'view_tags':
        newView = 'tags';
        onViewChanged(newView);
        break;
    }

    return newView;
  }
}
