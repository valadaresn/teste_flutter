import 'package:flutter/material.dart';
import '../note_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final Color Function(String) getTagColor;
  final bool hasActiveFilters; // ✅ NOVO: Indica se há filtros ativos

  const NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.getTagColor,
    this.hasActiveFilters = false, // ✅ NOVO: Default false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const cardColor = Colors.white;
    const textColor = Colors.black;

    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: cardColor,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        splashColor:
            note.tags.isNotEmpty
                ? getTagColor(note.tags.first).withOpacity(0.3)
                : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration:
              note.tags.isNotEmpty
                  ? BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: getTagColor(note.tags.first),
                        width: 5,
                      ),
                    ),
                  )
                  : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildContent(),
                // ✅ MUDANÇA: Só mostra tags se NÃO houver filtros ativos
                if (note.tags.isNotEmpty && !hasActiveFilters) _buildTags(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            note.title.isEmpty ? 'Sem título' : note.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  note.tags.contains('Importante')
                      ? Colors.red.shade700
                      : Colors.black,
            ),
          ),
        ),
        Text(
          '${note.dateTime.day}/${note.dateTime.month}/${note.dateTime.year}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      note.content,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Colors.black87),
    );
  }

  Widget _buildTags() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: note.tags.map((tag) => _buildTagChip(tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    final tagColor = getTagColor(tag);
    final contrastColor = _getContrastColor(tagColor);

    return Chip(
      label: Text(tag, style: TextStyle(fontSize: 10, color: contrastColor)),
      backgroundColor: tagColor,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
