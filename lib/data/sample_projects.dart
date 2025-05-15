import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/task_list.dart';

final List<Project> sampleProjects = [
  Project(
    id: 'personal',
    name: 'Pessoal',
    color: Colors.blue,
    icon: Icons.person_outline,
    lists: [
      TaskList(id: 'personal_daily', name: 'Tarefas Diárias'),
      TaskList(id: 'personal_home', name: 'Casa'),
      TaskList(id: 'personal_health', name: 'Saúde'),
    ],
    pendingTasks: 3,
  ),
  Project(
    id: 'work',
    name: 'Trabalho',
    color: Colors.green,
    icon: Icons.work_outline,
    lists: [
      TaskList(id: 'work_current', name: 'Sprint Atual'),
      TaskList(id: 'work_backlog', name: 'Backlog'),
      TaskList(id: 'work_meetings', name: 'Reuniões'),
    ],
    pendingTasks: 3,
  ),
  Project(
    id: 'study',
    name: 'Estudos',
    color: Colors.purple,
    icon: Icons.school_outlined,
    lists: [
      TaskList(id: 'study_flutter', name: 'Flutter'),
      TaskList(id: 'study_english', name: 'Inglês'),
      TaskList(id: 'study_books', name: 'Livros'),
    ],
    pendingTasks: 3,
  ),
];
