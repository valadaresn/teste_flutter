import '../models/task.dart';

final List<Task> sampleTasks = [
  //--------------------------
  // Tarefas do projeto Pessoal
  //--------------------------

  // Lista: Tarefas Diárias
  Task(
    id: 'task_1',
    title: 'Comprar mantimentos',
    description: 'Frutas, legumes, proteínas',
    projectId: 'personal',
    taskListId: 'personal_daily',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    dueDate: DateTime.now().add(const Duration(days: 1)),
  ),
  Task(
    id: 'task_2',
    title: 'Pagar contas',
    description: 'Luz, água e internet',
    projectId: 'personal',
    taskListId: 'personal_daily',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    dueDate: DateTime.now(),
  ),
  Task(
    id: 'task_3',
    title: 'Revisar calendário da semana',
    projectId: 'personal',
    taskListId: 'personal_daily',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    dueDate: DateTime.now().add(const Duration(days: 1)),
  ),

  // Lista: Casa
  Task(
    id: 'task_4',
    title: 'Limpar o quarto',
    description: 'Organizar armário e gavetas',
    projectId: 'personal',
    taskListId: 'personal_home',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    dueDate: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Task(
    id: 'task_5',
    title: 'Consertar a torneira',
    projectId: 'personal',
    taskListId: 'personal_home',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    dueDate: DateTime.now(),
  ),
  Task(
    id: 'task_6',
    title: 'Organizar despensa',
    projectId: 'personal',
    taskListId: 'personal_home',
    createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    dueDate: DateTime.now().add(const Duration(days: 2)),
  ),

  // Lista: Saúde
  Task(
    id: 'task_7',
    title: 'Fazer exercícios',
    description: '30 minutos de cardio',
    projectId: 'personal',
    taskListId: 'personal_health',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    dueDate: DateTime.now(),
    isPomodoroActive: false,
    selectedPomodoroLabel: '30 minutos',
    pomodoroTime: 30 * 60,
  ),
  Task(
    id: 'task_8',
    title: 'Agendar consulta médica',
    projectId: 'personal',
    taskListId: 'personal_health',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    dueDate: DateTime.now().add(const Duration(days: 1)),
  ),
  Task(
    id: 'task_9',
    title: 'Planejar refeições da semana',
    description: 'Foco em alimentos saudáveis',
    projectId: 'personal',
    taskListId: 'personal_health',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    dueDate: DateTime.now().add(const Duration(days: 2)),
  ),

  //--------------------------
  // Tarefas do projeto Trabalho
  //--------------------------

  // Lista: Sprint Atual
  Task(
    id: 'task_10',
    title: 'Implementar nova feature',
    description: 'Adicionar suporte a temas escuros',
    projectId: 'work',
    taskListId: 'work_current',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    selectedPomodoroLabel: '25 minutos',
    pomodoroTime: 25 * 60,
    dueDate: DateTime.now(),
  ),
  Task(
    id: 'task_11',
    title: 'Corrigir bugs no módulo de usuários',
    description: 'Issues #142 e #158',
    projectId: 'work',
    taskListId: 'work_current',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    dueDate: DateTime.now().add(const Duration(days: 1)),
  ),
  Task(
    id: 'task_12',
    title: 'Refatorar código legado',
    projectId: 'work',
    taskListId: 'work_current',
    createdAt: DateTime.now().subtract(const Duration(hours: 36)),
    selectedPomodoroLabel: '25 minutos',
    pomodoroTime: 25 * 60,
    dueDate: DateTime.now().add(const Duration(days: 2)),
  ),

  // Lista: Backlog
  Task(
    id: 'task_13',
    title: 'Revisar backlog',
    description: 'Priorizar tarefas para o próximo sprint',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    projectId: 'work',
    taskListId: 'work_backlog',
    dueDate: DateTime.now().add(const Duration(days: 1)),
  ),
  Task(
    id: 'task_14',
    title: 'Investigar solução de cache',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    projectId: 'work',
    taskListId: 'work_backlog',
    dueDate: DateTime.now().add(const Duration(days: 3)),
  ),
  Task(
    id: 'task_15',
    title: 'Analisar métricas de desempenho',
    description: 'Verificar pontos de melhoria no app',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    projectId: 'work',
    taskListId: 'work_backlog',
    dueDate: DateTime.now().add(const Duration(days: 5)),
  ),

  // Lista: Reuniões
  Task(
    id: 'task_16',
    title: 'Daily standup',
    description: 'Discussão sobre o andamento da sprint',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    projectId: 'work',
    taskListId: 'work_meetings',
    dueDate: DateTime.now(),
    isPomodoroActive: false,
    selectedPomodoroLabel: '15 minutos',
    pomodoroTime: 15 * 60,
  ),
  Task(
    id: 'task_17',
    title: 'Reunião com cliente',
    description: 'Apresentação de novos requisitos',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    projectId: 'work',
    taskListId: 'work_meetings',
    dueDate: DateTime.now().add(const Duration(days: 1)),
  ),
  Task(
    id: 'task_18',
    title: 'Revisão de sprint',
    createdAt: DateTime.now().subtract(const Duration(hours: 16)),
    projectId: 'work',
    taskListId: 'work_meetings',
    dueDate: DateTime.now().add(const Duration(days: 3)),
  ),

  //--------------------------
  // Tarefas do projeto Estudos
  //--------------------------

  // Lista: Flutter
  Task(
    id: 'task_19',
    title: 'Exercícios Flutter',
    description: 'Completar módulo de estado',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    projectId: 'study',
    taskListId: 'study_flutter',
    dueDate: DateTime.now(),
    selectedPomodoroLabel: '25 minutos',
    pomodoroTime: 25 * 60,
  ),
  Task(
    id: 'task_20',
    title: 'Estudar gerenciamento de estado',
    description: 'Riverpod, Provider e Bloc',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    projectId: 'study',
    taskListId: 'study_flutter',
    dueDate: DateTime.now().add(const Duration(days: 1)),
  ),
  Task(
    id: 'task_21',
    title: 'Desenvolver app de exemplo',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    projectId: 'study',
    taskListId: 'study_flutter',
    dueDate: DateTime.now().add(const Duration(days: 4)),
  ),

  // Lista: Inglês
  Task(
    id: 'task_22',
    title: 'Revisar inglês',
    description: 'Vocabulário técnico',
    createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    projectId: 'study',
    taskListId: 'study_english',
    dueDate: DateTime.now(),
  ),
  Task(
    id: 'task_23',
    title: 'Praticar conversação',
    projectId: 'study',
    taskListId: 'study_english',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    dueDate: DateTime.now().add(const Duration(days: 1)),
  ),
  Task(
    id: 'task_24',
    title: 'Assistir série em inglês',
    description: 'Sem legendas',
    projectId: 'study',
    taskListId: 'study_english',
    createdAt: DateTime.now().subtract(const Duration(hours: 15)),
    dueDate: DateTime.now().add(const Duration(days: 2)),
  ),

  // Lista: Livros
  Task(
    id: 'task_25',
    title: 'Ler capítulo do livro',
    description: 'Clean Architecture',
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    projectId: 'study',
    taskListId: 'study_books',
    dueDate: DateTime.now().add(const Duration(days: 1)),
  ),
  Task(
    id: 'task_26',
    title: 'Resumir último capítulo lido',
    projectId: 'study',
    taskListId: 'study_books',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    dueDate: DateTime.now(),
    selectedPomodoroLabel: '25 minutos',
    pomodoroTime: 25 * 60,
  ),
  Task(
    id: 'task_27',
    title: 'Comprar novo livro sobre Flutter',
    projectId: 'study',
    taskListId: 'study_books',
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    dueDate: DateTime.now().add(const Duration(days: 5)),
  ),
];
