// Atualize seu main.dart para incluir a nova tela

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:teste_flutter/features/habit_screen/habit_screen.dart';
import 'package:teste_flutter/features/note_screen/notes_screen.dart';
import 'package:teste_flutter/features/task_management/screens/task_management_screen.dart';
import 'package:teste_flutter/features/task_management/controllers/task_controller.dart';
import 'package:teste_flutter/features/task_management/themes/theme_provider.dart';
import 'package:teste_flutter/features/log_screen/controllers/log_controller.dart';
import 'package:teste_flutter/widgets/navigation/vertical_navigation_bar.dart';
import 'screens/task_screen/task_screen.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initNotifications();

  // Inicializa o Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskController()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LogController()),
      ],
      child: MaterialApp(
        title: 'Teste Flutter',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
        locale: const Locale('pt', 'BR'),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    TaskScreen(),
    //DiaryScreen(),
    // DiaryScreenOptimized(), // Nova tela otimizada
    // NotesScreen(),
    NotesScreen(),
    HabitsScreen(),
    TaskManagementScreen(),
    //HelloWorldScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Configurar integração entre controllers após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔵 Main.dart - addPostFrameCallback executado');
      final taskController = Provider.of<TaskController>(
        context,
        listen: false,
      );
      final logController = Provider.of<LogController>(context, listen: false);

      debugPrint('🔵 Main.dart - taskController: $taskController');
      debugPrint('🔵 Main.dart - logController: $logController');

      // Conectar LogController ao TaskController para salvar tempo acumulado
      logController.setTaskController(taskController);
      debugPrint('🔵 Main.dart - setTaskController chamado');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Detectar se é tela grande (desktop/tablet)
    final isLargeScreen = MediaQuery.of(context).size.width > 768;

    if (isLargeScreen) {
      // Layout para tela grande com navegação vertical
      return Scaffold(
        body: Row(
          children: [
            // Barra de navegação vertical
            VerticalNavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            // Conteúdo principal
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _screens),
            ),
          ],
        ),
      );
    } else {
      // Layout para tela pequena com navegação inferior
      return Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: themeProvider.getNavigationBarColor(
                context,
                listColor: Colors.blue, // Cor padrão para lista
              ),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.task_alt),
                  label: 'Tarefas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.note),
                  label: 'NotasSele',
                ),
                NavigationDestination(
                  icon: Icon(Icons.fitness_center),
                  label: 'Habitos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.task_alt),
                  label: 'Tarefas+',
                ),
                NavigationDestination(
                  icon: Icon(Icons.dashboard_customize),
                  label: 'TaskNew',
                ),
              ],
            );
          },
        ),
      );
    }
  }
}
