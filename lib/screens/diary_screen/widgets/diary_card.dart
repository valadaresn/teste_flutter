import 'package:flutter/material.dart';
import '../../../models/diary_entry.dart';
import '../diary_styles.dart';

enum DiaryCardLayout { standard, clean }

class DiaryCard extends StatefulWidget {
  final DiaryEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final DiaryCardLayout layout;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const DiaryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
    this.layout = DiaryCardLayout.standard,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  @override
  State<DiaryCard> createState() => _DiaryCardState();
}

class _DiaryCardState extends State<DiaryCard> {
  bool _isDetailsLoaded = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Apenas carrega os detalhes quando o widget está realmente visível
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return time;
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} $time';
  }

  Widget _buildDetails() {
    if (!_isVisible) return const SizedBox.shrink();

    if (!_isDetailsLoaded) {
      // Carrega os detalhes apenas quando necessário
      Future.microtask(() {
        if (mounted) {
          setState(() => _isDetailsLoaded = true);
        }
      });
      return const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.entry.title != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.entry.title!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          widget.entry.content,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        if (widget.entry.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children:
                widget.entry.tags
                    .map(
                      (tag) => Chip(
                        label: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        backgroundColor: Colors.white.withOpacity(0.3),
                      ),
                    )
                    .toList(),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.layout == DiaryCardLayout.clean) {
      return Card(
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                          widget.entry.title != null
                              ? Text(
                                widget.entry.title!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                              : Text(
                                widget.entry.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16),
                              ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(widget.entry.dateTime),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (widget.entry.title != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.entry.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Layout padrão
    return Container(
      margin: DiaryStyles.cardMargin,
      decoration: DiaryStyles.standardCardDecoration.copyWith(
        color: DiaryStyles.getMoodColor(widget.entry.mood),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: DiaryStyles.cardBorderRadius,
          child: Padding(
            padding: DiaryStyles.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatDateTime(widget.entry.dateTime),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (widget.entry.mood != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            widget.entry.mood!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        if (widget.onToggleFavorite != null)
                          IconButton(
                            icon: Icon(
                              widget.isFavorite
                                  ? Icons.star
                                  : Icons.star_border,
                              color:
                                  widget.isFavorite
                                      ? Colors.amber
                                      : Colors.grey,
                            ),
                            onPressed: widget.onToggleFavorite,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black54,
                          ),
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20),
                                      SizedBox(width: 8),
                                      Text('Excluir'),
                                    ],
                                  ),
                                ),
                              ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              widget.onTap?.call();
                            } else if (value == 'delete') {
                              widget.onDelete?.call();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                _buildDetails(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
