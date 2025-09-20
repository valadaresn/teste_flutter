import 'package:flutter/material.dart';

/// Seletor de tempo do Pomodoro simplificado para QuickAddTaskInput
class QuickPomodoroSelector extends StatelessWidget {
  final int pomodoroTime;
  final Function(int) onTimeChanged;

  const QuickPomodoroSelector({
    Key? key,
    required this.pomodoroTime,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDefault = pomodoroTime == 25;

    return GestureDetector(
      onTap: () => _showTimeSlider(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade500),
            if (!isDefault) ...[
              const SizedBox(width: 6),
              Text(
                '${pomodoroTime}m',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTimeSlider(BuildContext context) {
    double currentTime = pomodoroTime.toDouble();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Tempo do Pomodoro'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${currentTime.round()} minutos',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                        ),
                        child: Slider(
                          value: currentTime,
                          min: 5,
                          max: 90,
                          divisions: 17,
                          label: '${currentTime.round()}m',
                          onChanged: (value) {
                            setDialogState(() {
                              currentTime = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '5m',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '90m',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onTimeChanged(currentTime.round());
                        Navigator.of(context).pop();
                      },
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
          ),
    );
  }
}
