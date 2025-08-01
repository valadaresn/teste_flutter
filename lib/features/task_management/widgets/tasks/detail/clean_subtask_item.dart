import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/task_controller.dart';
import '../../../models/task_model.dart';
import '../../../../log_screen/controllers/log_controller.dart';
import 'subtask_edit_dialog.dart';

/// **CleanSubtaskItem** - Item de subtarefa para o CleanTaskPanel
///
/// Componente isolado para exibir subtarefas com botão play/stop e
/// tempo acumulado persistente
class CleanSubtaskItem extends StatelessWidget {
  final Task subtask;
  final TaskController taskController;
  final TextEditingController textController;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final Function(String) onTitleChanged;

  const CleanSubtaskItem({
    Key? key,
    required this.subtask,
    required this.taskController,
    required this.textController,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onTitleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<LogController, TaskController>(
      builder: (context, logController, taskController, child) {
        final isBeingLogged = logController.isTaskBeingLogged(subtask.id);

        // Buscar subtask atualizada do TaskController para ter o tempo mais recente
        final updatedSubtask =
            taskController.getTaskById(subtask.id) ?? subtask;

        // Calcula tempo total acumulado (sessões anteriores + sessão atual)
        final totalAccumulatedSeconds = logController
            .getTotalAccumulatedTimeSync(
              subtask.id,
              updatedSubtask
                  .accumulatedTimeSeconds, // Usar tempo atualizado do banco
            );

        // Sempre mostrar o tempo total calculado
        final displayTimeSeconds = totalAccumulatedSeconds;

        // Formata o tempo total para exibição
        String formatAccumulatedTime(int seconds) {
          final hours = seconds ~/ 3600;
          final minutes = (seconds % 3600) ~/ 60;
          final remainingSeconds = seconds % 60;

          if (hours > 0) {
            return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
          } else {
            return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
          }
        }

        final accumulatedTimeFormatted = formatAccumulatedTime(
          displayTimeSeconds,
        );

        return GestureDetector(
          onSecondaryTapDown: (details) {
            print('Botão direito detectado');
            _showSubtaskContextMenu(context, details.globalPosition);
          },
          onLongPress: () {
            print('Toque longo detectado');
            _showSubtaskContextMenu(context, null);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onToggleComplete,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            subtask.isCompleted
                                ? Colors.blue
                                : Colors.grey.shade400,
                        width: 2,
                      ),
                      color:
                          subtask.isCompleted
                              ? Colors.blue
                              : Colors.transparent,
                    ),
                    child:
                        subtask.isCompleted
                            ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                            : null,
                  ),
                ),

                const SizedBox(width: 12),

                // Campo de texto editável - com GestureDetector separado
                Expanded(
                  child: GestureDetector(
                    onSecondaryTapDown: (details) {
                      print('Botão direito no texto detectado');
                      _showSubtaskContextMenu(context, details.globalPosition);
                    },
                    onLongPress: () {
                      print('Toque longo no texto detectado');
                      _showSubtaskContextMenu(context, null);
                    },
                    child: TextField(
                      controller: textController,
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            subtask.isCompleted
                                ? Colors.grey.shade500
                                : Colors.black87,
                        decoration:
                            subtask.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => onTitleChanged(subtask.id),
                    ),
                  ),
                ),

                // Tempo acumulado ou contagem regressiva do pomodoro
                if (totalAccumulatedSeconds > 0 ||
                    logController.isPomodoroRunning(subtask.id)) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isBeingLogged
                              ? Colors.green.shade50
                              : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isBeingLogged
                                ? Colors.green.shade200
                                : Colors.grey.shade200,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTimeIcon(
                            logController,
                            subtask.id,
                            isBeingLogged,
                          ),
                          size: 12,
                          color:
                              isBeingLogged
                                  ? Colors.green.shade600
                                  : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeDisplay(
                            logController,
                            subtask.id,
                            accumulatedTimeFormatted,
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color:
                                isBeingLogged
                                    ? Colors.green.shade700
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(width: 8),

                // Botão temporário para testar menu
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () => _showSubtaskContextMenu(context, null),
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  padding: EdgeInsets.zero,
                ),

                // Botão play/pause
                _buildPlayButton(context, logController),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Botão play/pause para subtarefa
  Widget _buildPlayButton(BuildContext context, LogController logController) {
    final isBeingLogged = logController.isTaskBeingLogged(subtask.id);

    // Buscar subtask atualizada para verificar se já tem tempo acumulado
    final updatedSubtask = taskController.getTaskById(subtask.id) ?? subtask;
    final hasAccumulatedTime = updatedSubtask.accumulatedTimeSeconds > 0;

    // Definir cor do botão baseado no estado
    Color buttonColor;
    if (isBeingLogged) {
      buttonColor = Colors.red; // Vermelho quando ativo (Stop)
    } else if (hasAccumulatedTime) {
      buttonColor = Colors.orange; // Laranja quando há tempo acumulado
    } else {
      buttonColor = Theme.of(context).colorScheme.primary; // Azul quando novo
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        icon: Icon(
          isBeingLogged ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
          size: 14,
        ),
        onPressed: () => _handlePlayPause(context, logController),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        tooltip: isBeingLogged ? 'Parar' : 'Iniciar',
      ),
    );
  }

  /// Controlar play/pause da subtarefa
  Future<void> _handlePlayPause(
    BuildContext context,
    LogController logController,
  ) async {
    try {
      final taskList = taskController.getListById(subtask.listId);
      final isLogged = logController.isTaskBeingLogged(subtask.id);

      if (!isLogged) {
        // Iniciar log
        await logController.startTaskLog(subtask, taskList: taskList);
      } else {
        // Parar log (não pausar)
        await logController.stopTaskLog(subtask.id);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
      }
    }
  }

  /// Mostrar menu de contexto para subtarefa
  void _showSubtaskContextMenu(BuildContext context, [Offset? globalPosition]) {
    print('_showSubtaskContextMenu chamado com posição: $globalPosition');

    try {
      if (globalPosition != null) {
        print('Mostrando menu na posição específica');
        // Usar posição específica do clique (botão direito)
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            globalPosition.dx,
            globalPosition.dy,
            globalPosition.dx + 1,
            globalPosition.dy + 1,
          ),
          items: [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ).then((value) {
          print('Menu retornou valor: $value');
          if (value == 'edit') {
            _editSubtask(context);
          } else if (value == 'delete') {
            onDelete();
          }
        });
      } else {
        print('Mostrando menu na posição do widget');
        // Usar posição do widget (toque longo)
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final Offset position = renderBox.localToGlobal(Offset.zero);
          print('Posição do widget: $position');

          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              position.dx,
              position.dy,
              position.dx + renderBox.size.width,
              position.dy + renderBox.size.height,
            ),
            items: [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ).then((value) {
            print('Menu retornou valor: $value');
            if (value == 'edit') {
              _editSubtask(context);
            } else if (value == 'delete') {
              onDelete();
            }
          });
        } else {
          print('RenderBox é null');
        }
      }
    } catch (e) {
      print('Erro ao mostrar menu: $e');
    }
  }

  /// Abrir modal de edição da subtarefa
  void _editSubtask(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) =>
              SubtaskEditDialog(subtask: subtask, controller: taskController),
    );
  }

  /// Obter ícone apropriado baseado no estado do timer
  IconData _getTimeIcon(
    LogController logController,
    String taskId,
    bool isBeingLogged,
  ) {
    if (!isBeingLogged) {
      return Icons.schedule; // Relógio para tempo acumulado
    }

    // Se está rodando, verificar se é pomodoro ou cronômetro
    final isPomodoroActive = logController.isPomodoroRunning(taskId);
    if (isPomodoroActive) {
      return Icons.hourglass_bottom; // Ampulheta para contagem regressiva
    } else {
      return Icons.timer; // Timer normal para cronômetro
    }
  }

  /// Obter texto de exibição do tempo baseado no estado
  String _getTimeDisplay(
    LogController logController,
    String taskId,
    String accumulatedTimeFormatted,
  ) {
    final isBeingLogged = logController.isTaskBeingLogged(taskId);

    if (!isBeingLogged) {
      return accumulatedTimeFormatted; // Mostrar tempo acumulado quando parado
    }

    // Se está rodando, verificar se é pomodoro ou cronômetro
    final isPomodoroActive = logController.isPomodoroRunning(taskId);
    if (isPomodoroActive) {
      // Mostrar tempo restante do pomodoro
      final remainingTime = logController.getPomodoroRemainingTime(taskId);
      if (remainingTime != null && remainingTime > 0) {
        final minutes = (remainingTime ~/ 60).toString().padLeft(2, '0');
        final seconds = (remainingTime % 60).toString().padLeft(2, '0');
        return '$minutes:$seconds';
      }
    }

    // Fallback para tempo acumulado
    return accumulatedTimeFormatted;
  }
}
