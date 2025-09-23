import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// ⏱️ **TimerModule** - Módulo de timer com controles para cards modulares
///
/// **FUNCIONALIDADE:**
/// - Display de tempo em formato MM:SS ou HH:MM:SS
/// - Controles de play, pause, stop e reset
/// - Múltiplos modos de exibição (circular, linear, text)
/// - Cores customizáveis para timer e fundo
/// - Opção de mostrar/ocultar controles
///
/// **USADO POR:**
/// - HabitCard (posição trailing) - para cronometrar hábitos
/// - CleanCardExamples (exemplos diversos)
///
/// **MODOS DE EXIBIÇÃO:**
/// - `circular`: Progress indicator circular com tempo no centro
/// - `linear`: Progress indicator linear com tempo acima
/// - `text`: Apenas texto do tempo
///
/// **POSIÇÕES COMUNS:**
/// - `trailing`: Lado direito do card (padrão para hábitos)
/// - `header-trailing`: Direita do cabeçalho (modo compacto)
/// - `footer`: Rodapé do card (modo linear)
///
/// **EXEMPLO DE USO:**
/// ```dart
/// TimerModuleFactory.trailing(
///   duration: Duration(minutes: 10),
///   isRunning: timerIsRunning,
///   onPlay: startTimer,
///   onPause: pauseTimer,
///   displayMode: TimerDisplayMode.circular,
/// )
/// ```

/// ⏱️ Módulo de Timer para cards
class TimerModule extends PositionableModule {
  final Duration? duration;
  final bool isRunning;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onStop;
  final VoidCallback? onReset;
  final Color? primaryColor;
  final Color? backgroundColor;
  final double size;
  final bool showControls;
  final TimerDisplayMode displayMode;

  TimerModule({
    required String position,
    this.duration,
    this.isRunning = false,
    this.onPlay,
    this.onPause,
    this.onStop,
    this.onReset,
    this.primaryColor,
    this.backgroundColor,
    this.size = 40.0,
    this.showControls = true,
    this.displayMode = TimerDisplayMode.circular,
  }) : super(position);

  @override
  String get moduleId => 'timer_${isRunning ? 'running' : 'stopped'}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    final theme = Theme.of(context);
    final effectivePrimaryColor = primaryColor ?? theme.primaryColor;
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timer Display
        _buildTimerDisplay(
          context,
          effectivePrimaryColor,
          effectiveBackgroundColor,
        ),

        // Controls (if enabled)
        if (showControls) ...[
          const SizedBox(height: 8),
          _buildControls(context, effectivePrimaryColor),
        ],
      ],
    );
  }

  Widget _buildTimerDisplay(
    BuildContext context,
    Color primaryColor,
    Color backgroundColor,
  ) {
    final timeText = _formatDuration(duration ?? Duration.zero);

    switch (displayMode) {
      case TimerDisplayMode.circular:
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: isRunning ? null : 0.0,
                backgroundColor: backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                strokeWidth: 3,
              ),
              Text(
                timeText,
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        );

      case TimerDisplayMode.linear:
        return Column(
          children: [
            Text(
              timeText,
              style: TextStyle(
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: size * 2,
              child: LinearProgressIndicator(
                value: isRunning ? null : 0.0,
                backgroundColor: backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ],
        );

      case TimerDisplayMode.text:
        return Text(
          timeText,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        );
    }
  }

  Widget _buildControls(BuildContext context, Color primaryColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Pause Button
        IconButton(
          icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
          onPressed: isRunning ? onPause : onPlay,
          color: primaryColor,
          iconSize: 16,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          padding: EdgeInsets.zero,
        ),

        // Stop Button
        if (onStop != null)
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: onStop,
            color: primaryColor,
            iconSize: 16,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            padding: EdgeInsets.zero,
          ),

        // Reset Button
        if (onReset != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onReset,
            color: primaryColor,
            iconSize: 16,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}

/// 🎨 Modos de exibição do timer
enum TimerDisplayMode {
  circular, // Circular progress indicator com tempo no centro
  linear, // Linear progress indicator com tempo acima
  text, // Apenas texto
}

/// 🎯 Factory para criar timers em diferentes posições
class TimerModuleFactory {
  /// Timer na posição trailing (direita)
  static TimerModule trailing({
    Duration? duration,
    bool isRunning = false,
    VoidCallback? onPlay,
    VoidCallback? onPause,
    VoidCallback? onStop,
    VoidCallback? onReset,
    Color? primaryColor,
    Color? backgroundColor,
    double size = 40.0,
    bool showControls = true,
    TimerDisplayMode displayMode = TimerDisplayMode.circular,
  }) {
    return TimerModule(
      position: 'trailing',
      duration: duration,
      isRunning: isRunning,
      onPlay: onPlay,
      onPause: onPause,
      onStop: onStop,
      onReset: onReset,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      size: size,
      showControls: showControls,
      displayMode: displayMode,
    );
  }

  /// Timer no header-trailing (direita do header)
  static TimerModule headerTrailing({
    Duration? duration,
    bool isRunning = false,
    VoidCallback? onPlay,
    VoidCallback? onPause,
    VoidCallback? onStop,
    VoidCallback? onReset,
    Color? primaryColor,
    Color? backgroundColor,
    double size = 30.0,
    bool showControls = false,
    TimerDisplayMode displayMode = TimerDisplayMode.text,
  }) {
    return TimerModule(
      position: 'header-trailing',
      duration: duration,
      isRunning: isRunning,
      onPlay: onPlay,
      onPause: onPause,
      onStop: onStop,
      onReset: onReset,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      size: size,
      showControls: showControls,
      displayMode: displayMode,
    );
  }

  /// Timer no footer (embaixo)
  static TimerModule footer({
    Duration? duration,
    bool isRunning = false,
    VoidCallback? onPlay,
    VoidCallback? onPause,
    VoidCallback? onStop,
    VoidCallback? onReset,
    Color? primaryColor,
    Color? backgroundColor,
    double size = 50.0,
    bool showControls = true,
    TimerDisplayMode displayMode = TimerDisplayMode.linear,
  }) {
    return TimerModule(
      position: 'footer',
      duration: duration,
      isRunning: isRunning,
      onPlay: onPlay,
      onPause: onPause,
      onStop: onStop,
      onReset: onReset,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      size: size,
      showControls: showControls,
      displayMode: displayMode,
    );
  }
}
