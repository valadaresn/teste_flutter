// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'dart:io';

// // Inicialização do plugin de notificações
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Future<void> initNotifications() async {
//   const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//   const initializationSettings = InitializationSettings(android: androidInit);

//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onDidReceiveNotificationResponse: (details) {
//       // Handle notification tap
//     },
//   );

//   // Request notification permissions for Android 13+
//   if (Platform.isAndroid) {
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestNotificationsPermission();
//   }
// }

// // Ponto de entrada do aplicativo Flutter
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initNotifications();
//   runApp(const MyApp());
// }

// // Widget principal do aplicativo - Define temas e configurações globais
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Task Manager',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.indigo,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.indigo,
//           brightness: Brightness.light,
//         ),
//         useMaterial3: true,
//         fontFamily: 'Poppins',
//       ),
//       home: const TaskScreen(),
//     );
//   }
// }

// // Classe que define a estrutura de uma tarefa - Modelo de dados
// class Task {
//   final String id;
//   final String title;
//   final String? description;
//   bool isCompleted;
//   final DateTime createdAt;
//   bool isPomodoroActive;
//   int pomodoroTime;
//   String?
//   selectedPomodoroLabel; // Novo campo para armazenar o rótulo do tempo selecionado

//   // Construtor da classe Task com parâmetros
//   Task({
//     required this.id,
//     required this.title,
//     this.description,
//     this.isCompleted = false,
//     required this.createdAt,
//     this.isPomodoroActive = false,
//     this.pomodoroTime = 25 * 60, // 25 minutos por padrão
//     this.selectedPomodoroLabel, // Inicialmente nulo
//   });
// }

// // Widget Stateful que gerencia a tela de tarefas
// class TaskScreen extends StatefulWidget {
//   const TaskScreen({Key? key}) : super(key: key);

//   @override
//   State<TaskScreen> createState() => _TaskScreenState();
// }

// // Classe de estado que contém os dados mutáveis e a lógica da UI
// class _TaskScreenState extends State<TaskScreen> {
//   // Lista de tarefas de exemplo para iniciar o app
//   final List<Task> _tasks = [
//     Task(
//       id: '1',
//       title: 'Fazer compras',
//       description: 'Comprar leite, pão e ovos',
//       createdAt: DateTime.now().subtract(const Duration(days: 1)),
//     ),
//     Task(
//       id: '2',
//       title: 'Estudar Flutter',
//       description: 'Revisar widgets básicos e state management',
//       createdAt: DateTime.now().subtract(const Duration(hours: 3)),
//     ),
//     Task(
//       id: '3',
//       title: 'Fazer exercícios',
//       createdAt: DateTime.now().subtract(const Duration(hours: 5)),
//     ),
//   ];

//   // Lista de opções de tempo para o pomodoro
//   final List<Map<String, dynamic>> _pomodoroOptions = [
//     {'title': '3 segundos (teste)', 'value': 3},
//     {'title': '5 minutos', 'value': 5 * 60},
//     {'title': '15 minutos', 'value': 15 * 60},
//     {'title': '25 minutos', 'value': 25 * 60},
//     {'title': '30 minutos', 'value': 30 * 60},
//   ];

//   // Mapa para armazenar os timers de cada tarefa
//   final Map<String, Timer> _timers = {};

//   // Controladores para os campos de texto do formulário
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descController = TextEditingController();

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descController.dispose();
//     _timers.forEach((_, timer) => timer.cancel());
//     super.dispose();
//   }

//   // Método para exibir o modal de adição de tarefa
//   void _addTask() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//             left: 16,
//             right: 16,
//             top: 16,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Nova Tarefa',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Título',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _descController,
//                 decoration: const InputDecoration(
//                   labelText: 'Descrição (opcional)',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_titleController.text.trim().isNotEmpty) {
//                       setState(() {
//                         _tasks.add(
//                           Task(
//                             id: DateTime.now().toString(),
//                             title: _titleController.text.trim(),
//                             description:
//                                 _descController.text.trim().isNotEmpty
//                                     ? _descController.text.trim()
//                                     : null,
//                             createdAt: DateTime.now(),
//                           ),
//                         );
//                       });
//                       _titleController.clear();
//                       _descController.clear();
//                       Navigator.pop(context);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Adicionar'),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Método para alternar o status de conclusão da tarefa
//   void _toggleTaskCompletion(String id) {
//     setState(() {
//       final taskIndex = _tasks.indexWhere((task) => task.id == id);
//       if (taskIndex != -1) {
//         _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
//       }
//     });
//   }

//   // Método para excluir uma tarefa da lista
//   void _deleteTask(String id) {
//     if (_timers.containsKey(id)) {
//       _timers[id]?.cancel();
//       _timers.remove(id);
//     }

//     setState(() {
//       _tasks.removeWhere((task) => task.id == id);
//     });
//   }

//   // Método para mostrar uma notificação do sistema Android
//   Future<void> _showNotification(String title, String body) async {
//     const androidDetails = AndroidNotificationDetails(
//       'pomodoro_channel',
//       'Pomodoro Notifications',
//       channelDescription: 'Notificações de conclusão do pomodoro',
//       importance: Importance.max,
//       priority: Priority.high,
//       enableVibration: true,
//       playSound: true,
//       icon: '@mipmap/ic_launcher',
//       largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
//       enableLights: true,
//       color: Colors.green,
//       ledColor: Colors.green,
//       ledOnMs: 1000,
//       ledOffMs: 500,
//     );

//     const notificationDetails = NotificationDetails(android: androidDetails);

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       notificationDetails,
//       payload: 'pomodoro_completed',
//     );
//   }

//   // Método para iniciar ou parar o pomodoro de uma tarefa
//   void _startPomodoro(String id) {
//     final taskIndex = _tasks.indexWhere((task) => task.id == id);
//     if (taskIndex == -1) return;

//     final task = _tasks[taskIndex];

//     // Se já existe um timer ativo para esta tarefa, cancela-o
//     if (_timers.containsKey(id)) {
//       _timers[id]?.cancel();
//       _timers.remove(id);

//       setState(() {
//         task.isPomodoroActive = false;
//       });
//       return;
//     }

//     // Inicia novo timer com o tempo configurado para a tarefa
//     setState(() {
//       task.isPomodoroActive = true;
//     });

//     // Cria um timer que dispara a cada segundo
//     _timers[id] = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         // Quando o tempo acaba, cancela o timer e marca como inativo
//         if (timer.tick >= task.pomodoroTime) {
//           timer.cancel();
//           _timers.remove(id);
//           task.isPomodoroActive = false;

//           // Mostra notificação do sistema Android (funciona em segundo plano)
//           _showNotification(
//             'Pomodoro Concluído',
//             '${task.title} - Tempo finalizado!',
//           );
//         }
//       });
//     });
//   }

//   // Método para formatar o tempo restante do pomodoro (mm:ss)
//   String _formatPomodoroTime(String id) {
//     final taskIndex = _tasks.indexWhere((task) => task.id == id);
//     if (taskIndex == -1) return "";

//     final task = _tasks[taskIndex];
//     final timer = _timers[id];

//     if (timer == null) return "";

//     final secondsRemaining = task.pomodoroTime - timer.tick;
//     final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
//     final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');

//     return "$minutes:$seconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text(
//           'Minhas Tarefas',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.sort),
//             onPressed: () {
//               // Implementar ordenação (funcionalidade futura)
//             },
//           ),
//         ],
//       ),
//       body:
//           _tasks.isEmpty
//               ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.check_circle_outline,
//                       size: 80,
//                       color: Colors.grey[400],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Nenhuma tarefa pendente',
//                       style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                     ),
//                     const SizedBox(height: 24),
//                     ElevatedButton.icon(
//                       onPressed: _addTask,
//                       icon: const Icon(Icons.add),
//                       label: const Text('Adicionar tarefa'),
//                     ),
//                   ],
//                 ),
//               )
//               : ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: _tasks.length,
//                 itemBuilder: (context, index) {
//                   final task = _tasks[index];
//                   return Dismissible(
//                     key: Key(task.id),
//                     background: Container(
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       alignment: Alignment.centerRight,
//                       child: const Icon(Icons.delete, color: Colors.white),
//                     ),
//                     direction: DismissDirection.endToStart,
//                     onDismissed: (_) => _deleteTask(task.id),
//                     child: Card(
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       elevation: 1,
//                       color: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: IntrinsicHeight(
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             // Checkbox à esquerda
//                             Padding(
//                               padding: const EdgeInsets.only(left: 8.0),
//                               child: Checkbox(
//                                 value: task.isCompleted,
//                                 onChanged:
//                                     (_) => _toggleTaskCompletion(task.id),
//                                 shape: const CircleBorder(),
//                                 activeColor:
//                                     Theme.of(context).colorScheme.primary,
//                               ),
//                             ),

//                             // Conteúdo central (título, descrição e tempo selecionado)
//                             Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 12.0,
//                                   horizontal: 8.0,
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       task.title,
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w500,
//                                         fontSize: 16,
//                                         decoration:
//                                             task.isCompleted
//                                                 ? TextDecoration.lineThrough
//                                                 : null,
//                                         color:
//                                             task.isCompleted
//                                                 ? Colors.grey
//                                                 : Colors.black87,
//                                       ),
//                                     ),
//                                     if (task.description != null)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                           top: 4.0,
//                                         ),
//                                         child: Text(
//                                           task.description!,
//                                           style: TextStyle(
//                                             color: Colors.grey[600],
//                                             decoration:
//                                                 task.isCompleted
//                                                     ? TextDecoration.lineThrough
//                                                     : null,
//                                           ),
//                                         ),
//                                       ),
//                                     // Exibe o tempo selecionado se houver
//                                     if (task.selectedPomodoroLabel != null &&
//                                         !task.isPomodoroActive)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                           top: 4.0,
//                                         ),
//                                         child: Text(
//                                           'Tempo: ${task.selectedPomodoroLabel}',
//                                           style: TextStyle(
//                                             color: Colors.green[600],
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ),

//                             // Área de controles à direita (tempo, menu e play)
//                             Row(
//                               mainAxisSize: MainAxisSize.min,
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 // Exibe o tempo restante se o pomodoro estiver ativo
//                                 if (task.isPomodoroActive)
//                                   Padding(
//                                     padding: const EdgeInsets.only(right: 8.0),
//                                     child: Text(
//                                       _formatPomodoroTime(task.id),
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         color:
//                                             Theme.of(
//                                               context,
//                                             ).colorScheme.primary,
//                                       ),
//                                     ),
//                                   ),

//                                 // Botão de menu de opções do pomodoro (PopupMenuButton)
//                                 PopupMenuButton<int>(
//                                   // Abre o menu centralizado na tela
//                                   position: PopupMenuPosition.under,
//                                   color:
//                                       Colors.white, // Fundo branco para o menu
//                                   elevation: 4, // Adiciona sombra
//                                   tooltip: 'Configurar pomodoro',
//                                   icon: const Icon(Icons.more_vert),
//                                   onSelected: (value) {
//                                     setState(() {
//                                       // Encontra o item selecionado no menu
//                                       final selected = _pomodoroOptions.firstWhere(
//                                         (option) => option['value'] == value,
//                                         orElse:
//                                             () =>
//                                                 _pomodoroOptions[3], // Default para 25 min
//                                       );

//                                       // Atualiza o tempo do pomodoro e o rótulo selecionado
//                                       task.pomodoroTime = value;
//                                       task.selectedPomodoroLabel =
//                                           selected['title'] as String;
//                                     });
//                                   },
//                                   itemBuilder: (context) {
//                                     return _pomodoroOptions.map((option) {
//                                       return PopupMenuItem<int>(
//                                         value: option['value'] as int,
//                                         child: Text(option['title'] as String),
//                                       );
//                                     }).toList();
//                                   },
//                                 ),

//                                 // Botão play para o pomodoro
//                                 Padding(
//                                   padding: const EdgeInsets.only(right: 8.0),
//                                   child: IconButton(
//                                     icon: Icon(
//                                       task.isPomodoroActive
//                                           ? Icons.pause
//                                           : Icons.play_arrow,
//                                       color: Colors.green,
//                                       size: 24,
//                                     ),
//                                     onPressed: () => _startPomodoro(task.id),
//                                     tooltip:
//                                         task.isPomodoroActive
//                                             ? 'Pausar pomodoro'
//                                             : 'Iniciar pomodoro',
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addTask,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
