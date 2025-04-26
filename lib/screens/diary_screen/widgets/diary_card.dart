import 'package:flutter/material.dart';
import '../../../models/diary_entry.dart';

class DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DiaryCard({super.key, required this.entry, this.onTap, this.onDelete});

  Color _getTimeBasedColor() {
    final hour = entry.dateTime.hour;
    if (hour >= 5 && hour < 12) {
      return Colors.amber.withAlpha(
        51,
      ); // Manhã - 0.2 opacity = 51 em alpha (255 * 0.2)
    } else if (hour >= 12 && hour < 18) {
      return Colors.blue.withAlpha(51); // Tarde
    } else {
      return Colors.deepPurple.withAlpha(51); // Noite
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getTimeBasedColor(),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${entry.dateTime.hour.toString().padLeft(2, '0')}:${entry.dateTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (entry.mood != null)
                    Text(entry.mood!, style: const TextStyle(fontSize: 20)),
                ],
              ),
              if (entry.title != null) ...[
                const SizedBox(height: 8),
                Text(
                  entry.title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children:
                      entry.tags
                          .map(
                            (tag) => Chip(
                              label: Text(
                                '#$tag',
                                style: const TextStyle(fontSize: 12),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
