// import 'package:flutter/material.dart';
// import '../../controllers/task_controller.dart';
// import '../../models/task_model.dart';
// import 'today_task_item.dart';

// /// Enum para identificar os tipos de grupos de tarefas
// enum TaskGroupType {
//   today, // Tarefas com prazo para hoje
//   overdue, // Tarefas atrasadas
//   completed, // Tarefas concluídas recentemente
// }

// /// **ExpansibleTaskGroup** - Componente expansível para grupos de tarefas
// ///
// /// Este componente exibe um grupo de tarefas em um container expansível,
// /// seguindo o padrão visual mostrado nas referências do usuário
// class ExpansibleTaskGroup extends StatefulWidget {
//   final String title;
//   final IconData icon;
//   final TaskController controller;
//   final TaskGroupType taskType;
//   final Color? iconColor;

//   const ExpansibleTaskGroup({
//     Key? key,
//     required this.title,
//     required this.icon,
//     required this.controller,
//     required this.taskType,
//     this.iconColor,
//   }) : super(key: key);

//   @override
//   State<ExpansibleTaskGroup> createState() => _ExpansibleTaskGroupState();
// }

// class _ExpansibleTaskGroupState extends State<ExpansibleTaskGroup> {
//   bool _isExpanded = true;

//   @override
//   Widget build(BuildContext context) {
//     // Obter tarefas baseado no tipo
//     List<Task> tasks = _getTasksByType();
//     int count = tasks.length;

//     // Se não há tarefas, não exibir o grupo
//     if (count == 0) {
//       return const SizedBox.shrink();
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4.0),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(8.0),
//         border: Border.all(
//           color: Theme.of(context).dividerColor.withOpacity(0.5),
//           width: 0.5,
//         ),
//       ),
//       child: Column(
//         children: [
//           // Header expansível
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: () => setState(() => _isExpanded = !_isExpanded),
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(8.0),
//               ),
//               hoverColor: Theme.of(
//                 context,
//               ).colorScheme.primary.withOpacity(0.04),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 12.0,
//                   horizontal: 16.0,
//                 ),
//                 decoration: BoxDecoration(
//                   color:
//                       _isExpanded
//                           ? Theme.of(
//                             context,
//                           ).colorScheme.primary.withOpacity(0.05)
//                           : Colors.transparent,
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(8.0),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       widget.icon,
//                       size: 18,
//                       color:
//                           widget.iconColor ??
//                           Theme.of(context).colorScheme.onSurface,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       widget.title,
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             widget.iconColor?.withOpacity(0.1) ??
//                             Theme.of(
//                               context,
//                             ).colorScheme.primary.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         '$count',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color:
//                               widget.iconColor ??
//                               Theme.of(context).colorScheme.primary,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//                     Icon(
//                       _isExpanded
//                           ? Icons.keyboard_arrow_up
//                           : Icons.keyboard_arrow_down,
//                       size: 16,
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.onSurface.withOpacity(0.6),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Lista de tarefas com recuo
//           if (_isExpanded) ...[
//             // Divisor sutil
//             Container(
//               height: 0.5,
//               margin: const EdgeInsets.symmetric(horizontal: 16.0),
//               color: Theme.of(context).dividerColor.withOpacity(0.3),
//             ),

//             // Lista de tarefas
//             Padding(
//               padding: const EdgeInsets.only(
//                 left: 16.0,
//                 right: 8.0,
//                 bottom: 8.0,
//               ),
//               child: Column(
//                 children:
//                     tasks.asMap().entries.map((entry) {
//                       int index = entry.key;
//                       Task task = entry.value;

//                       return Column(
//                         children: [
//                           TodayTaskItem(
//                             task: task,
//                             controller: widget.controller,
//                           ),

//                           // Divisor entre itens (exceto o último)
//                           if (index < tasks.length - 1)
//                             Container(
//                               height: 0.5,
//                               margin: const EdgeInsets.symmetric(
//                                 vertical: 4.0,
//                                 horizontal: 8.0,
//                               ),
//                               color: Theme.of(
//                                 context,
//                               ).dividerColor.withOpacity(0.2),
//                             ),
//                         ],
//                       );
//                     }).toList(),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   /// Obter tarefas baseado no tipo do grupo
//   List<Task> _getTasksByType() {
//     switch (widget.taskType) {
//       case TaskGroupType.today:
//         return widget.controller.getTodayTasks();
//       case TaskGroupType.overdue:
//         return widget.controller.getOverdueTasks();
//       case TaskGroupType.completed:
//         return widget.controller.getCompletedTasks();
//     }
//   }
// }
