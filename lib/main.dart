// Atualize seu main.dart para incluir a nova tela

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:teste_flutter/features/habit_screen/habit_screen.dart';
//import 'package:teste_flutter/screens/hello_world_screen.dart';
//import 'package:teste_flutter/screens/notes_screen.dart';
import 'package:teste_flutter/features/note_screen/notes_screen.dart';
import 'package:teste_flutter/features/task_management/screens/task_management_screen.dart';
import 'package:teste_flutter/features/task_management/controllers/task_controller.dart';
import 'package:teste_flutter/features/task_management/themes/theme_provider.dart';
import 'screens/task_screen/task_screen.dart';
//import 'screens/diary_screen/diary_screen.dart';
//import 'screens/diary_screen/diary_screen_optimized.dart'; // Nova tela
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
  const MyApp({super.key});  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskController()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: MaterialApp(
        title: 'Teste Flutter',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en', 'US'),
        ],
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.task_alt), label: 'Tarefas'),

          // //NavigationDestination(icon: Icon(Icons.book), label: 'Diário Local'),
          // NavigationDestination(
          //   icon: Icon(Icons.bolt),
          //   label: 'Diário Otimizado',
          // ),

          //NavigationDestination(icon: Icon(Icons.note), label: 'Notas'),
          NavigationDestination(icon: Icon(Icons.note), label: 'NotasSele'),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Habitos',
          ),
          NavigationDestination(icon: Icon(Icons.task_alt), label: 'Tarefas+'),

          // ignore_for_file: lines_longer_than_80_chars
          // format-ignore
          //   NavigationDestination(
          //     icon: Icon(Icons.emoji_emotions),
          //     label: 'Hello World',
          //   ), // format-ignore
        ],
      ),
    );
  }
}
