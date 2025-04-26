import 'package:flutter/material.dart';
import '../../../models/diary_entry.dart';

abstract class DiaryViewBase extends StatelessWidget {
  final List<DiaryEntry> entries;
  final Function(DiaryEntry) onTap;
  final Function(String) onDelete;

  const DiaryViewBase({
    super.key,
    required this.entries,
    required this.onTap,
    required this.onDelete,
  });
}
