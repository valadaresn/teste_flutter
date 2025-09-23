import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../habit_model.dart';
import '../../../services/notification_service.dart';

/// 📱 Widget principal do cartão de hábito
/// Responsável pela estrutura geral e gerenciamento de estado
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: _CardContainer(
        isSelected: widget.isSelected,
        onTap: widget.onTap,
        child: Row(
          children: [
            // Ícone ou checkmark do hábito
            _HabitIcon(
              habit: widget.habit,
              onToggleCompletion: () {
                widget.onToggleTodayCompletion();
                setState(() {});
              },
            ),

            const SizedBox(width: 16),

            // Conteúdo principal (título, timer ativo)
            _HabitContent(
              habit: widget.habit,
              isTimerRunning: _isTimerRunning,
              remainingSeconds: _remainingSeconds,
              formatTime: _formatTime,
            ),

            // Botão de timer (se aplicável)
            if (widget.habit.hasTimer && widget.habit.targetTime != null)
              _TimerButton(
                habit: widget.habit,
                isTimerRunning: _isTimerRunning,
                onStartTimer: _startTimer,
                onStopTimer: _stopTimer,
              ),
          ],
        ),
      ),
    );
  }
}

/// 🖼️ Container principal do card com visual e interatividade
/// Gerencia o visual e interações de toque do card
class _CardContainer extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _CardContainer({
    Key? key,
    required this.isSelected,
    required this.onTap,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          // Sem efeitos visuais de animação para evitar atrasos
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}

/// 🎯 Ícone do hábito ou checkmark quando concluído
/// Mostra o emoji do hábito ou o checkmark quando está concluído
class _HabitIcon extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggleCompletion;

  const _HabitIcon({
    Key? key,
    required this.habit,
    required this.onToggleCompletion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggleCompletion,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color:
              habit.isDoneToday() ? habit.color : habit.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child:
              habit.isDoneToday()
                  ? const Icon(Icons.check, color: Colors.white, size: 24)
                  : Text(habit.emoji, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}

/// 📝 Conteúdo principal do card
/// Exibe o título do hábito e informações do timer quando ativo
class _HabitContent extends StatelessWidget {
  final Habit habit;
  final bool isTimerRunning;
  final int remainingSeconds;
  final String Function(int) formatTime;

  const _HabitContent({
    Key? key,
    required this.habit,
    required this.isTimerRunning,
    required this.remainingSeconds,
    required this.formatTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habit.title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (isTimerRunning) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: habit.color),
                const SizedBox(width: 4),
                Text(
                  formatTime(remainingSeconds),
                  style: textTheme.bodySmall?.copyWith(
                    color: habit.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// ⏱️ Botão de controle do timer
/// Permite iniciar/parar o timer e mostra o tempo-alvo
class _TimerButton extends StatelessWidget {
  final Habit habit;
  final bool isTimerRunning;
  final VoidCallback onStartTimer;
  final VoidCallback onStopTimer;

  const _TimerButton({
    Key? key,
    required this.habit,
    required this.isTimerRunning,
    required this.onStartTimer,
    required this.onStopTimer,
  }) : super(key: key);

  String _formatTargetTime() {
    if (habit.targetTime == null) return "";

    final seconds = habit.targetTime!;
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
    return GestureDetector(
      onTap: () {
        if (isTimerRunning) {
          onStopTimer();
        } else {
          onStartTimer();
        }
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isTimerRunning ? habit.color : habit.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTimerRunning ? Icons.stop : Icons.play_arrow,
              color: isTimerRunning ? Colors.white : habit.color,
              size: 20,
            ),
          ),
          if (!isTimerRunning) ...[
            const SizedBox(height: 4),
            Text(
              _formatTargetTime(),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}

/// 📅 Indicador visual dos dias da semana
/// Mostra quais dias da semana o hábito está programado
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

/// 📊 Barra de progresso do hábito
/// Visualiza o progresso da sequência atual vs. a melhor sequência
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

/// 🔘 Botões de ação do hábito
/// Contém botões para marcar como feito e ativar/pausar o hábito
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
