import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../habit_model.dart';
import '../../../services/notification_service.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleTodayCompletion;
  final VoidCallback onResetStreak;
  final VoidCallback? onUndoResetStreak;
  final bool isSelected;

  const HabitCard({
    Key? key,
    required this.habit,
    required this.onTap,
    required this.onToggleActive,
    required this.onToggleTodayCompletion,
    required this.onResetStreak,
    this.onUndoResetStreak,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (widget.habit.targetTime == null) return;

    setState(() {
      _remainingSeconds = widget.habit.targetTime!;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopTimer();
          _showTimerCompleteNotification();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = 0;
    });
  }

  void _showTimerCompleteNotification() async {
    // Notificação do sistema
    await showNotification(
      '⏰ Timer Concluído!',
      '🎉 ${widget.habit.title} - Timer finalizado! Marque como concluído.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.timer_off, color: Colors.white),
              const SizedBox(width: 8),
              Text('🎉 Timer do ${widget.habit.title} concluído!'),
            ],
          ),
          backgroundColor: widget.habit.color,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Marcar como feito',
            textColor: Colors.white,
            onPressed: () {
              widget.onToggleTodayCompletion();
              setState(() {});
            },
          ),
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatTargetTime() {
    if (widget.habit.targetTime == null) return "";

    final seconds = widget.habit.targetTime!;
    if (seconds == 3) {
      return "3 seg";
    } else if (seconds < 60) {
      return "$seconds seg";
    } else {
      final minutes = seconds ~/ 60;
      return "$minutes min";
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Container(
        // ✅ REMOVIDO: AnimatedContainer
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border:
              widget.isSelected
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap, // ✅ REMOVIDO: HapticFeedback
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Ícone do hábito / Check button
                  GestureDetector(
                    onTap: () {
                      widget.onToggleTodayCompletion();
                      setState(() {});
                    },
                    child: Container(
                      // ✅ REMOVIDO: AnimatedContainer
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            widget.habit.isDoneToday()
                                ? widget.habit.color
                                : widget.habit.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child:
                            widget.habit
                                    .isDoneToday() // ✅ REMOVIDO: AnimatedSwitcher
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                )
                                : Text(
                                  widget.habit.emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Conteúdo principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (_isTimerRunning) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: widget.habit.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(_remainingSeconds),
                                style: textTheme.bodySmall?.copyWith(
                                  color: widget.habit.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Botão de timer (se habilitado e tem targetTime)
                  if (widget.habit.hasTimer &&
                      widget.habit.targetTime != null) ...[
                    GestureDetector(
                      onTap: () {
                        if (_isTimerRunning) {
                          _stopTimer();
                        } else {
                          _startTimer();
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            // ✅ REMOVIDO: AnimatedContainer
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  _isTimerRunning
                                      ? widget.habit.color
                                      : widget.habit.color.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isTimerRunning ? Icons.stop : Icons.play_arrow,
                              color:
                                  _isTimerRunning
                                      ? Colors.white
                                      : widget.habit.color,
                              size: 20,
                            ),
                          ),
                          if (!_isTimerRunning) ...[
                            const SizedBox(height: 4),
                            Text(
                              _formatTargetTime(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Classes usadas em versões anteriores (mantidas para compatibilidade)
class _DayIndicator extends StatelessWidget {
  final List<String> daysOfWeek;
  final Color activeColor;
  const _DayIndicator({
    Key? key,
    required this.daysOfWeek,
    required this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const allDays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return Row(
      children:
          allDays.map((d) {
            final isActive = daysOfWeek.contains(d);
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? activeColor : activeColor.withOpacity(0.3),
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _HabitProgress extends StatelessWidget {
  final int streak;
  final int bestStreak;
  final Color color;
  const _HabitProgress({
    Key? key,
    required this.streak,
    required this.bestStreak,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = bestStreak > 0 ? streak / bestStreak : 1.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progresso: $streak / $bestStreak',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: color.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ],
    );
  }
}

class _HabitActions extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggleTodayCompletion;
  final VoidCallback onToggleActive;
  const _HabitActions({
    Key? key,
    required this.habit,
    required this.onToggleTodayCompletion,
    required this.onToggleActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: onToggleTodayCompletion,
          icon: Icon(
            habit.isDoneToday()
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
          ),
          label: Text(habit.isDoneToday() ? 'Feito' : 'Marcar'),
        ),
        TextButton.icon(
          onPressed: onToggleActive,
          icon: Icon(habit.isActive ? Icons.pause_circle : Icons.play_circle),
          label: Text(habit.isActive ? 'Pausar' : 'Ativar'),
        ),
      ],
    );
  }
}
