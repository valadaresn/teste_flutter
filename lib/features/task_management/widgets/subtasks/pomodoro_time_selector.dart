import 'package:flutter/material.dart';
import '../../models/task_model.dart';

/// Seletor de tempo do Pomodoro para o rodapé
class PomodoroTimeSelector extends StatefulWidget {
  final Task task;
  final Function(int) onTimeChanged;

  const PomodoroTimeSelector({
    Key? key,
    required this.task,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  State<PomodoroTimeSelector> createState() => _PomodoroTimeSelectorState();
}

class _PomodoroTimeSelectorState extends State<PomodoroTimeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: () => _showTimeSlider(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _isHovered ? Colors.grey.shade100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border:
                      _isHovered
                          ? Border.all(color: Colors.grey.shade300, width: 1)
                          : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.task.pomodoroTimeMinutes}min',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTimeSlider(BuildContext context) {
    double currentTime = widget.task.pomodoroTimeMinutes.toDouble();

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
                          divisions:
                              17, // 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90
                          label: '${currentTime.round()}min',
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
                            '5min',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '90min',
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
                        widget.onTimeChanged(currentTime.round());
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
