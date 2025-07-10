import 'package:flutter/material.dart';
import 'dart:ui';

/// **TimerDisplay** - Widget para exibir cronômetro em tempo real
///
/// Mostra o tempo decorrido formatado como MM:SS
class TimerDisplay extends StatelessWidget {
  final String formattedTime;
  final bool isActive;

  const TimerDisplay({
    Key? key,
    required this.formattedTime,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color:
            isActive
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color:
              isActive
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 12,
            color:
                isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color:
                  isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
