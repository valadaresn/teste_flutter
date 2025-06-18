// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../habit_model.dart';

// enum _ActionOption { resetStreak, timer, qualityRating }

// class HabitCard extends StatelessWidget {
//   final Habit habit;
//   final VoidCallback onTap;
//   final VoidCallback onToggleActive;
//   final VoidCallback onToggleTodayCompletion;
//   final VoidCallback onResetStreak;
//   final VoidCallback? onUndoResetStreak;

//   const HabitCard({
//     Key? key,
//     required this.habit,
//     required this.onTap,
//     required this.onToggleActive,
//     required this.onToggleTodayCompletion,
//     required this.onResetStreak,
//     this.onUndoResetStreak,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final double streakProgress =
//         habit.bestStreak > 0 ? habit.streak / habit.bestStreak : 1.0;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Container(
//             decoration: BoxDecoration(
//               color: habit.color.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: habit.color.withOpacity(0.3)),
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () {
//                   HapticFeedback.selectionClick();
//                   onTap();
//                 },
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     ListTile(
//                       leading: Semantics(
//                         label: 'Ícone do hábito',
//                         child: CircleAvatar(
//                           backgroundColor: habit.color.withOpacity(0.2),
//                           child: Text(
//                             habit.emoji,
//                             style: textTheme.titleMedium,
//                           ),
//                         ),
//                       ),
//                       title: Text(habit.title, style: textTheme.titleLarge),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _DayIndicator(
//                             daysOfWeek: habit.daysOfWeek,
//                             activeColor: habit.color,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(_getDaysText(), style: textTheme.bodySmall),
//                         ],
//                       ),
//                       trailing: PopupMenuButton<_ActionOption>(
//                         onSelected: (opt) {
//                           HapticFeedback.lightImpact();
//                           switch (opt) {
//                             case _ActionOption.resetStreak:
//                               onResetStreak();
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: const Text('Sequência resetada'),
//                                   action: SnackBarAction(
//                                     label: 'Desfazer',
//                                     onPressed: () {
//                                       if (onUndoResetStreak != null) {
//                                         onUndoResetStreak!();
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               );
//                               break;
//                             case _ActionOption.timer:
//                               // TODO: implementar timer
//                               break;
//                             case _ActionOption.qualityRating:
//                               // TODO: implementar avaliação de qualidade
//                               break;
//                           }
//                         },
//                         itemBuilder:
//                             (_) => [
//                               const PopupMenuItem(
//                                 value: _ActionOption.resetStreak,
//                                 child: Text('Resetar sequência'),
//                               ),
//                               if (habit.hasTimer && habit.targetTime != null)
//                                 PopupMenuItem(
//                                   value: _ActionOption.timer,
//                                   child: Text('Timer: ${habit.targetTime} min'),
//                                 ),
//                               if (habit.hasQualityRating)
//                                 const PopupMenuItem(
//                                   value: _ActionOption.qualityRating,
//                                   child: Text('Avaliar qualidade'),
//                                 ),
//                             ],
//                       ),
//                     ),

//                     if (habit.bestStreak > 0)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 4,
//                         ),
//                         child: _HabitProgress(
//                           streak: habit.streak,
//                           bestStreak: habit.bestStreak,
//                           color: habit.color,
//                         ),
//                       ),

//                     const Divider(height: 1),

//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       child: _HabitActions(
//                         habit: habit,
//                         onToggleTodayCompletion: onToggleTodayCompletion,
//                         onToggleActive: onToggleActive,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String _getDaysText() {
//     if (habit.daysOfWeek.length == 7) {
//       return 'Todos os dias';
//     }
//     const dayLabels = {
//       'mon': 'Seg',
//       'tue': 'Ter',
//       'wed': 'Qua',
//       'thu': 'Qui',
//       'fri': 'Sex',
//       'sat': 'Sáb',
//       'sun': 'Dom',
//     };
//     final labels = habit.daysOfWeek.map((d) => dayLabels[d]).toList();
//     return labels.join(', ');
//   }
// }

// class _DayIndicator extends StatelessWidget {
//   final List<String> daysOfWeek;
//   final Color activeColor;
//   const _DayIndicator({
//     Key? key,
//     required this.daysOfWeek,
//     required this.activeColor,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     const allDays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
//     return Row(
//       children:
//           allDays.map((d) {
//             final isActive = daysOfWeek.contains(d);
//             return Padding(
//               padding: const EdgeInsets.only(right: 4),
//               child: Container(
//                 width: 6,
//                 height: 6,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: isActive ? activeColor : activeColor.withOpacity(0.3),
//                 ),
//               ),
//             );
//           }).toList(),
//     );
//   }
// }

// class _HabitProgress extends StatelessWidget {
//   final int streak;
//   final int bestStreak;
//   final Color color;
//   const _HabitProgress({
//     Key? key,
//     required this.streak,
//     required this.bestStreak,
//     required this.color,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final progress = bestStreak > 0 ? streak / bestStreak : 1.0;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Progresso: $streak / $bestStreak',
//           style: Theme.of(context).textTheme.bodySmall,
//         ),
//         const SizedBox(height: 4),
//         TweenAnimationBuilder<double>(
//           tween: Tween(begin: 0, end: progress),
//           duration: const Duration(milliseconds: 300),
//           builder: (context, value, child) {
//             return LinearProgressIndicator(
//               value: value,
//               minHeight: 6,
//               backgroundColor: color.withOpacity(0.3),
//               valueColor: AlwaysStoppedAnimation(color),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// class _HabitActions extends StatelessWidget {
//   final Habit habit;
//   final VoidCallback onToggleTodayCompletion;
//   final VoidCallback onToggleActive;
//   const _HabitActions({
//     Key? key,
//     required this.habit,
//     required this.onToggleTodayCompletion,
//     required this.onToggleActive,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ButtonBar(
//       alignment: MainAxisAlignment.spaceBetween,
//       children: [
//         TextButton.icon(
//           onPressed: () {
//             HapticFeedback.lightImpact();
//             onToggleTodayCompletion();
//           },
//           icon: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             transitionBuilder:
//                 (child, anim) => ScaleTransition(scale: anim, child: child),
//             child: Icon(
//               habit.isDoneToday()
//                   ? Icons.check_circle
//                   : Icons.radio_button_unchecked,
//               key: ValueKey(habit.isDoneToday()),
//             ),
//           ),
//           label: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             child: Text(
//               habit.isDoneToday() ? 'Feito' : 'Marcar',
//               key: ValueKey(habit.isDoneToday()),
//             ),
//           ),
//         ),
//         TextButton.icon(
//           onPressed: () {
//             HapticFeedback.lightImpact();
//             onToggleActive();
//           },
//           icon: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             transitionBuilder:
//                 (child, anim) => ScaleTransition(scale: anim, child: child),
//             child: Icon(
//               habit.isActive ? Icons.pause_circle : Icons.play_circle,
//               key: ValueKey(habit.isActive),
//             ),
//           ),
//           label: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             child: Text(
//               habit.isActive ? 'Pausar' : 'Ativar',
//               key: ValueKey(habit.isActive),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
