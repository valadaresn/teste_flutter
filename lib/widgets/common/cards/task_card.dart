import 'package:flutter/material.dart';
import 'modular_card.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.title,
    this.description,
    required this.listColor,
    this.isRunning = false,
    this.onPlay,
    this.onStop,
    this.onTap,
    this.isSelected = false,
    this.timerLabel,
  });

  final String title;
  final String? description;
  final Color listColor; // cor da lista (borda esquerda)
  final bool isRunning; // se o timer está rodando
  final VoidCallback? onPlay;
  final VoidCallback? onStop;
  final VoidCallback? onTap;
  final bool isSelected;
  final String? timerLabel; // label do timer (ex: "25:00")

  @override
  Widget build(BuildContext context) {
    return ModularCard(
      onTap: onTap,
      backgroundColor: isSelected ? Colors.grey.shade50 : Colors.white,
      // Borda esquerda colorida
      leftBorderColor: listColor,
      leftBorderWidth: 5.0,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      // Título da tarefa
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      // Descrição (opcional)
      content:
          description?.isNotEmpty == true
              ? Text(
                description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              )
              : null,
      // Actions: timer + play/stop
      actions: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (timerLabel != null)
            Text(
              timerLabel!,
              style: TextStyle(
                fontFeatures: const [FontFeature.tabularFigures()],
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          if (timerLabel != null) const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
                isRunning
                    ? IconButton(
                      key: const ValueKey('stop'),
                      icon: const Icon(Icons.stop),
                      onPressed: onStop,
                    )
                    : IconButton(
                      key: const ValueKey('play'),
                      icon: const Icon(Icons.play_arrow),
                      onPressed: onPlay,
                    ),
          ),
        ],
      ),
    );
  }
}
