import 'package:flutter/material.dart';
import 'dart:async';
import '../notes_controller.dart';
import '../note_model.dart';
import 'tag_quick_selector.dart';

class NoteEditPanel extends StatefulWidget {
  final Note? note; // ✅ MUDANÇA: Opcional para permitir criação de nova nota
  final NotesController controller;
  final VoidCallback onClose;
  final VoidCallback onNoteUpdated;
  final List<String>? initialTags; // ✅ NOVO: Tags iniciais para nova nota
  final Function(Note)? onNoteCreated; // ✅ NOVO: Callback quando nota é criada

  const NoteEditPanel({
    Key? key,
    this.note, // ✅ MUDANÇA: Opcional
    required this.controller,
    required this.onClose,
    required this.onNoteUpdated,
    this.initialTags, // ✅ NOVO: Opcional
    this.onNoteCreated, // ✅ NOVO: Opcional
  }) : super(key: key);

  @override
  State<NoteEditPanel> createState() => _NoteEditPanelState();
}

class _NoteEditPanelState extends State<NoteEditPanel> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<String> _newNoteTags = []; // ✅ NOVO: Tags para nova nota
  bool get _isNewNote => widget.note == null; // ✅ NOVO: Verifica se é nova nota
  bool _isSaving = false; // ✅ NOVO: Controle para evitar salvamentos múltiplos
  Note? _createdNote; // ✅ NOVO: Nota criada para evitar duplicações
  Timer? _saveTimer; // ✅ NOVO: Timer para debounce do auto-save

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );

    // ✅ NOVO: Inicializa tags para nova nota com as tags selecionadas no filtro
    if (_isNewNote && widget.initialTags != null) {
      _newNoteTags = List.from(widget.initialTags!);
    }

    // ✅ REMOVIDO: Auto-save listeners para evitar custos Firebase
    // Agora só salva quando perde o foco
  }

  @override
  void didUpdateWidget(NoteEditPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ CORRIGIDO: Só atualiza quando realmente muda de nota
    if (oldWidget.note?.id != widget.note?.id) {
      _titleController.text = widget.note?.title ?? '';
      _contentController.text = widget.note?.content ?? '';

      if (_isNewNote && widget.initialTags != null) {
        _newNoteTags = List.from(widget.initialTags!);
      } else {
        _newNoteTags = widget.note?.tags ?? [];
      }

      _createdNote = null; // Reseta nota criada ao mudar
      _isSaving = false;
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel(); // ✅ Cancela timer se houver
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 📱 CORREÇÃO: Largura e estilo responsivos
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return SafeArea(
      child: Container(
        width: isMobile ? double.infinity : 400.0, // 📱 Mobile: 100% da tela
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              isMobile
                  ? null // 📱 Mobile: sem borda esquerda
                  : Border(
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ), // 🖥️ Desktop: com borda
          boxShadow:
              isMobile
                  ? null // 📱 Mobile: sem sombra
                  : [
                    // 🖥️ Desktop: com sombra
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(-2, 0),
                    ),
                  ],
        ),
        child: Column(
          children: [
            _PanelHeader(
              titleController: _titleController,
              onClose: _handleClose,
              onTitleSave: _saveNote,
              isNewNote: _isNewNote, // ✅ NOVO: Passa informação se é nova nota
            ),
            Expanded(
              child: _PanelContent(
                contentController: _contentController,
                onContentSave: _saveNote,
                isNewNote:
                    _isNewNote, // ✅ NOVO: Passa informação se é nova nota
              ),
            ),
            _PanelFooter(
              note: widget.note,
              controller: widget.controller,
              onTagsUpdated: widget.onNoteUpdated,
              onDeleteNote: _deleteNote,
              isNewNote: _isNewNote, // ✅ NOVO: Passa informação se é nova nota
              onTagsChanged:
                  _updateNoteTags, // ✅ NOVO: Callback para mudança de tags
              selectedTags:
                  _isNewNote
                      ? _newNoteTags
                      : (widget.note?.tags ?? []), // ✅ NOVO: Tags corretas
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleClose() async {
    // ✅ NOVO: Salva antes de fechar se há conteúdo
    _saveTimer?.cancel(); // Cancela timer pendente
    await _saveNote(); // Força salvamento final
    widget.onClose();
  }

  Future<void> _saveNote() async {
    // ✅ NOVO: Evita salvamentos múltiplos
    if (_isSaving) return;

    // ✅ MUDANÇA: Lógica do OneNote - primeira linha vira título
    final content = _contentController.text.trim();
    String title = _titleController.text.trim();
    String finalContent = content;

    // Se não há título definido e há conteúdo, primeira linha vira título
    if (title.isEmpty && content.isNotEmpty) {
      final lines = content.split('\n');
      if (lines.isNotEmpty && lines.first.trim().isNotEmpty) {
        title = lines.first.trim();
        // Remove a primeira linha do conteúdo se ela virou título
        if (lines.length > 1) {
          finalContent = lines.skip(1).join('\n').trim();
        } else {
          finalContent = '';
        }
      }
    }

    // Só cria/salva se há pelo menos título OU conteúdo
    if (title.isEmpty && finalContent.isEmpty) {
      return; // Não salva nota completamente vazia
    }

    // ✅ NOVO: Se já foi criada uma nota, não cria novamente
    if (_isNewNote && _createdNote != null) {
      // Atualiza a nota já criada em vez de criar nova
      await _updateExistingNote(_createdNote!);
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isNewNote) {
        // ✅ MUDANÇA: Usar título extraído e conteúdo ajustado
        final success = await widget.controller.addNoteFromDialog({
          'title': title.isEmpty ? 'Nova nota' : title,
          'content': finalContent,
          'tags': _newNoteTags,
        });

        if (success) {
          // ✅ NOVO: Busca a nota recém-criada para evitar duplicações futuras
          final notes = widget.controller.notes;

          // Busca a nota mais recente que coincide com título e conteúdo
          final matchingNotes =
              notes
                  .where(
                    (note) =>
                        note.title == (title.isEmpty ? 'Nova nota' : title) &&
                        note.content == finalContent,
                  )
                  .toList();

          if (matchingNotes.isNotEmpty) {
            matchingNotes.sort((a, b) => b.dateTime.compareTo(a.dateTime));
            _createdNote = matchingNotes.first;

            // ✅ NOVO: Atualiza os controllers com os valores finais
            _titleController.text = _createdNote!.title;
            _contentController.text = _createdNote!.content;

            // ✅ NOVO: Notifica o pai para selecionar a nota criada
            widget.onNoteCreated?.call(_createdNote!);
          }

          widget.onNoteUpdated();
        } else {
          // Silencioso - sem snackbar
        }
      } else {
        await _updateExistingNote(widget.note!);
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// ✅ NOVO: Método auxiliar para atualizar nota existente
  Future<void> _updateExistingNote(Note note) async {
    final updatedNote = note.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );

    final success = await widget.controller.updateNoteFromDialog(note, {
      'title': updatedNote.title,
      'content': updatedNote.content,
      'tags': updatedNote.tags,
    });

    if (success) {
      widget.onNoteUpdated();
    } else {
      // Silencioso - sem snackbar
    }
  }

  Future<void> _deleteNote() async {
    if (_isNewNote) {
      // ✅ NOVO: Se é nova nota, apenas fecha o painel
      widget.onClose();
      return;
    }

    final confirmed = await _showDeleteConfirmDialog();
    if (confirmed == true) {
      final success = await widget.controller.deleteNote(widget.note!.id);
      if (success) {
        widget.onNoteUpdated();
        widget.onClose();
      } else {
        // Silencioso - sem snackbar
      }
    }
  }

  /// ✅ NOVO: Método para atualizar tags da nota
  Future<void> _updateNoteTags(List<String> newTags) async {
    if (_isNewNote) {
      // ✅ CORREÇÃO: Para novas notas, armazena localmente
      setState(() {
        _newNoteTags = newTags;
      });
      return;
    }

    final updatedNote = widget.note!.copyWith(tags: newTags);

    final success = await widget.controller.updateNoteFromDialog(widget.note!, {
      'title': updatedNote.title,
      'content': updatedNote.content,
      'tags': updatedNote.tags,
    });

    if (success) {
      widget.onNoteUpdated();
    }
  }

  Future<bool?> _showDeleteConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Excluir Nota'),
            content: const Text(
              'Tem certeza que deseja excluir esta nota?\n\nEsta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

// ✅ CLASSE PRIVADA: Cabeçalho do painel
class _PanelHeader extends StatelessWidget {
  final TextEditingController titleController;
  final VoidCallback onClose;
  final VoidCallback onTitleSave;
  final bool isNewNote; // ✅ NOVO: Indica se é nova nota

  const _PanelHeader({
    required this.titleController,
    required this.onClose,
    required this.onTitleSave,
    required this.isNewNote, // ✅ NOVO
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'Fechar painel',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    isNewNote ? 'Título da nova nota...' : 'Título da nota...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 1,
              onEditingComplete: () {
                // ✅ CORRIGIDO: Salva sempre que sair do foco
                onTitleSave();
              },
              onTapOutside: (_) {
                // ✅ CORRIGIDO: Salva sempre que sair do foco
                onTitleSave();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ CLASSE PRIVADA: Conteúdo principal do painel
class _PanelContent extends StatelessWidget {
  final TextEditingController contentController;
  final VoidCallback onContentSave;
  final bool isNewNote; // ✅ NOVO: Indica se é nova nota

  const _PanelContent({
    required this.contentController,
    required this.onContentSave,
    required this.isNewNote, // ✅ NOVO
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: contentController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[300]!, width: 1),
            ),
            contentPadding: const EdgeInsets.all(16),
            hintText:
                isNewNote
                    ? 'Digite o conteúdo da nova nota...'
                    : 'Digite o conteúdo da nota...',
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
          style: const TextStyle(fontSize: 14, height: 1.4),
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          onEditingComplete: () {
            // ✅ CORRIGIDO: Salva sempre que sair do foco
            onContentSave();
          },
          onTapOutside: (_) {
            // ✅ CORRIGIDO: Salva sempre que sair do foco
            onContentSave();
          },
        ),
      ),
    );
  }
}

// ✅ CLASSE PRIVADA: Rodapé com ações
class _PanelFooter extends StatelessWidget {
  final Note? note; // ✅ MUDANÇA: Opcional
  final NotesController controller;
  final VoidCallback onTagsUpdated;
  final VoidCallback onDeleteNote;
  final bool isNewNote; // ✅ NOVO: Indica se é nova nota
  final Function(List<String>)
  onTagsChanged; // ✅ NOVO: Callback para mudança de tags
  final List<String> selectedTags; // ✅ NOVO: Tags selecionadas (para nova nota)

  const _PanelFooter({
    this.note, // ✅ MUDANÇA: Opcional
    required this.controller,
    required this.onTagsUpdated,
    required this.onDeleteNote,
    required this.isNewNote, // ✅ NOVO
    required this.onTagsChanged, // ✅ NOVO
    required this.selectedTags, // ✅ NOVO
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          // Seletor de tags - sem bordas, apenas ícone + texto
          TagQuickSelector(
            selectedTags: selectedTags, // ✅ CORREÇÃO: Usa tags corretas
            controller: controller,
            isNewNote: isNewNote,
            onTagsChanged: onTagsChanged,
          ),
          const SizedBox(width: 16),

          // Botão excluir nota / cancelar criação - também sem bordas para consistência
          GestureDetector(
            onTap: onDeleteNote,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isNewNote ? Icons.close : Icons.delete,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  isNewNote ? 'Cancelar' : 'Excluir',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
