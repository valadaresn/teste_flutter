import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notes_controller.dart';
import 'notes_provider.dart';
import 'note_model.dart';
import 'widgets/note_list.dart';
import 'widgets/search_widget.dart';
import 'widgets/tag_filter_widget.dart';
import 'widgets/tag_management_dialog.dart';
import 'widgets/note_edit_panel.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  bool _isSearchExpanded = false; // ✅ Estado inicial: busca oculta
  Note? _selectedNote; // ✅ NOVO: Nota selecionada para edição no painel lateral
  bool _isPanelOpen = false; // ✅ NOVO: Controla se o painel está aberto

  @override
  Widget build(BuildContext context) {
    // Watch do controller via provider
    final controller = ref.watch(notesControllerProvider);

    return Scaffold(
      body: SafeArea(child: _buildBody(controller)),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildBody(NotesController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(child: Text('Erro: ${controller.error}'));
    }

    // ✅ CORREÇÃO: Detectar se é mobile para usar layout adequado
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // ✅ NOVO: Layout com painel lateral quando há nota selecionada OU criando nova nota
    if (_isPanelOpen) {
      if (isMobile) {
        // 📱 Mobile: Navegação para tela cheia
        return NoteEditPanel(
          key: ValueKey(
            _selectedNote?.id ??
                'new_note_${DateTime.now().millisecondsSinceEpoch}',
          ),
          note: _selectedNote,
          controller: controller,
          initialTags:
              _selectedNote == null ? controller.selectedFilterTags : null,
          onClose:
              () => setState(() {
                _selectedNote = null;
                _isPanelOpen = false;
              }),
          onNoteUpdated: () {
            setState(() {});
          },
          onNoteCreated: (Note createdNote) {
            setState(() {
              _selectedNote = createdNote;
            });
          },
        );
      } else {
        // 🖥️ Desktop: Layout Row com painel lateral
        return Row(
          children: [
            // Lista de notas (lado esquerdo)
            Expanded(flex: 1, child: _buildMainContent()),
            // Painel de edição (lado direito)
            NoteEditPanel(
              key: ValueKey(
                _selectedNote?.id ??
                    'new_note_${DateTime.now().millisecondsSinceEpoch}',
              ),
              note: _selectedNote,
              controller: controller,
              initialTags:
                  _selectedNote == null ? controller.selectedFilterTags : null,
              onClose:
                  () => setState(() {
                    _selectedNote = null;
                    _isPanelOpen = false;
                  }),
              onNoteUpdated: () {
                setState(() {});
              },
              onNoteCreated: (Note createdNote) {
                setState(() {
                  _selectedNote = createdNote;
                });
              },
            ),
          ],
        );
      }
    }

    // Layout normal sem painel lateral
    return _buildMainContent();
  }

  /// ✅ NOVO: Conteúdo principal da tela (lista + filtros)
  Widget _buildMainContent() {
    return Column(
      children: [
        _buildNotesHeader(), // ✅ Linha 1 - Título "Notas" + Toggle busca
        TagFilterWidget(
          onTagSelected: _onTagSelected, // ✅ NOVO: Callback para seleção de tag
        ), // ✅ Linha 2 - Tags sempre visíveis
        if (_isSearchExpanded)
          _buildSearchSection(), // ✅ Linha 3 - Busca condicional
        Expanded(
          child: NotesList(
            onNoteTap: _openNoteInPanel,
            selectedNoteId:
                _selectedNote?.id, // ✅ NOVO: Passa ID da nota selecionada
          ),
        ), // ✅ Linha 4+ - Lista de notas
      ],
    );
  }

  /// Linha 1: "Notas" + ícone para expandir/colapsar busca
  Widget _buildNotesHeader() {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 0,
      ), // ✅ ZERO padding bottom
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Notas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ NOVO: Ícone de configurações para gerenciar tags
              GestureDetector(
                onTap: _openTagManagement,
                child: Icon(Icons.settings, color: Colors.grey[600], size: 20),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap:
                    () =>
                        setState(() => _isSearchExpanded = !_isSearchExpanded),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isSearchExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Busca',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Linha 3: Seção de busca - só aparece quando expandida
  Widget _buildSearchSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: SearchWidget(), // ✅ Só o widget de busca
    );
  }

  FloatingActionButton _buildFAB() {
    return FloatingActionButton(
      onPressed: _addNewNote,
      tooltip: 'Nova Nota',
      child: const Icon(Icons.add),
    );
  }

  /// ✅ NOVO: Abre nota no painel lateral
  void _openNoteInPanel(Note note) {
    setState(() {
      _selectedNote = note;
      _isPanelOpen = true;
    });
  }

  /// ✅ MUDANÇA: Cria nota instantaneamente como no OneNote
  Future<void> _addNewNote() async {
    final controller = ref.read(notesControllerProvider);

    // Criar nota vazia instantaneamente
    final success = await controller.addNoteFromDialog({
      'title': '',
      'content': '',
      'tags': controller.selectedFilterTags,
    });

    if (success) {
      // Buscar a nota recém-criada (a mais recente)
      final notes = controller.notes;
      if (notes.isNotEmpty) {
        final newNote = notes.first; // A mais recente fica no topo
        setState(() {
          _selectedNote = newNote;
          _isPanelOpen = true;
        });
      }
    }
  }

  /// ✅ NOVO: Callback quando uma tag é selecionada
  void _onTagSelected(String tag) {
    final controller = ref.read(notesControllerProvider);

    // Após mudança da tag, busca a primeira nota da lista filtrada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filteredNotes = controller.notes;

      if (filteredNotes.isNotEmpty) {
        // Seleciona a primeira nota da lista filtrada
        final firstNote = filteredNotes.first;
        setState(() {
          _selectedNote = firstNote;
          _isPanelOpen = true;
        });
      }
    });
  }

  /// ✅ NOVO: Abre o diálogo de gerenciamento de tags
  Future<void> _openTagManagement() async {
    await showDialog(
      context: context,
      builder:
          (context) => TagManagementDialog(
            controller: ref.read(notesControllerProvider),
            onTagUpdated: () {
              // Força atualização da UI quando tags são modificadas
              setState(() {});
            },
          ),
    );
  }
}
