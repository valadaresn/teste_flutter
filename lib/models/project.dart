import 'package:flutter/material.dart';
import 'task_list.dart';

class Project {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final List<TaskList> lists;
  final int pendingTasks;

  const Project({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.lists,
    this.pendingTasks = 0,
  });
}
