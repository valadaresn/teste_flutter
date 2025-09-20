import 'package:flutter/material.dart';
import '../notes_controller.dart';

class TagManagementDialog extends StatefulWidget {
  final NotesController controller;
  final VoidCallback onTagUpdated;

  const TagManagementDialog({
    Key? key,
    required this.controller,
    required this.onTagUpdated,
  }) : super(key: key);

  @override
  State<TagManagementDialog> createState() => _TagManagementDialogState();
}

class _TagManagementDialogState extends State<TagManagementDialog> {
  final TextEditingController _newTagController = TextEditingController();
  final TextEditingController _editTagController = TextEditingController();
  String? _editingTag;

  @override
  void dispose() {
    _newTagController.dispose();
    _editTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogHeader(),
              const SizedBox(height: 16),
              _AddNewTagSection(
                controller: _newTagController,
                onAddTag: _addNewTag,
              ),
              const SizedBox(height: 20),
              const Text(
                'Tags Existentes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: _TagsList(
                  controller: widget.controller,
                  editingTag: _editingTag,
                  editController: _editTagController,
                  onStartEditing: _startEditing,
                  onSaveEdit: _saveEdit,
                  onCancelEdit: _cancelEdit,
                  onDeleteTag: _confirmDeleteTag,
                ),
              ),
              const SizedBox(height: 16),
              _DialogActions(),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewTag() async {
    final tagName = _newTagController.text.trim();
    if (tagName.isEmpty) return;

    if (widget.controller.suggestedTags.contains(tagName)) {
      _showError('Tag "$tagName" já existe');
      return;
    }

    final success = await widget.controller.addNewTag(tagName);
    if (success) {
      _newTagController.clear();
      widget.onTagUpdated();
      setState(() {});
      _showSuccess('Tag "$tagName" adicionada com sucesso');
    } else {
      _showError('Erro ao criar tag "$tagName"');
    }
  }

  void _startEditing(String tag) {
    setState(() {
      _editingTag = tag;
      _editTagController.text = tag;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingTag = null;
      _editTagController.clear();
    });
  }

  void _saveEdit(String oldTag) async {
    final newTagName = _editTagController.text.trim();
    if (newTagName.isEmpty) return;

    if (newTagName == oldTag) {
      _cancelEdit();
      return;
    }

    if (widget.controller.suggestedTags.contains(newTagName)) {
      _showError('Tag "$newTagName" já existe');
      return;
    }

    final success = await widget.controller.renameTag(oldTag, newTagName);
    if (success) {
      _cancelEdit();
      widget.onTagUpdated();
      setState(() {});
      _showSuccess('Tag renomeada para "$newTagName"');
    } else {
      _showError('Erro ao renomear tag');
    }
  }

  void _confirmDeleteTag(String tag) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Excluir Tag'),
            content: Text(
              'Tem certeza que deseja excluir a tag "$tag"?\n\nEsta ação removerá a tag de todas as notas.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteTag(tag);
                },
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _deleteTag(String tag) async {
    final success = await widget.controller.deleteTag(tag);
    if (success) {
      widget.onTagUpdated();
      setState(() {});
      _showSuccess('Tag "$tag" excluída com sucesso');
    } else {
      _showError('Erro ao excluir tag "$tag"');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}

// ✅ CLASSE PRIVADA: Cabeçalho do diálogo
class _DialogHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Gerenciar Tags',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

// ✅ CLASSE PRIVADA: Seção para adicionar nova tag
class _AddNewTagSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAddTag;

  const _AddNewTagSection({required this.controller, required this.onAddTag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adicionar Nova Tag',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Nome da nova tag...',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => onAddTag(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onAddTag,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Adicionar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ✅ CLASSE PRIVADA: Lista de tags existentes
class _TagsList extends StatelessWidget {
  final NotesController controller;
  final String? editingTag;
  final TextEditingController editController;
  final Function(String) onStartEditing;
  final Function(String) onSaveEdit;
  final VoidCallback onCancelEdit;
  final Function(String) onDeleteTag;

  const _TagsList({
    required this.controller,
    required this.editingTag,
    required this.editController,
    required this.onStartEditing,
    required this.onSaveEdit,
    required this.onCancelEdit,
    required this.onDeleteTag,
  });

  @override
  Widget build(BuildContext context) {
    final tags = controller.suggestedTags;

    if (tags.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma tag encontrada',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        final tagColor = controller.getTagColor(tag);
        final isEditing = editingTag == tag;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tagColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tagColor.withOpacity(0.3)),
          ),
          child:
              isEditing
                  ? _TagEditRow(
                    tag: tag,
                    tagColor: tagColor,
                    controller: editController,
                    onSave: () => onSaveEdit(tag),
                    onCancel: onCancelEdit,
                  )
                  : _TagDisplayRow(
                    tag: tag,
                    tagColor: tagColor,
                    onEdit: () => onStartEditing(tag),
                    onDelete: () => onDeleteTag(tag),
                  ),
        );
      },
    );
  }
}

// ✅ CLASSE PRIVADA: Linha de exibição da tag
class _TagDisplayRow extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TagDisplayRow({
    required this.tag,
    required this.tagColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            tag,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 18),
          tooltip: 'Editar tag',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
          tooltip: 'Excluir tag',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

// ✅ CLASSE PRIVADA: Linha de edição da tag
class _TagEditRow extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _TagEditRow({
    required this.tag,
    required this.tagColor,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            onSubmitted: (_) => onSave(),
            autofocus: true,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onSave,
          icon: const Icon(Icons.check, size: 18, color: Colors.green),
          tooltip: 'Salvar',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          onPressed: onCancel,
          icon: const Icon(Icons.close, size: 18, color: Colors.red),
          tooltip: 'Cancelar',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

// ✅ CLASSE PRIVADA: Ações do diálogo
class _DialogActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
