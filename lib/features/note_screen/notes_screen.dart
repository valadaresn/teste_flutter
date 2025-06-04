import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notes_controller.dart';
import 'note_model.dart';
import 'widgets/note_dialog.dart';
import 'widgets/note_list.dart';
import 'widgets/search_widget.dart';
import 'widgets/tag_filter_widget.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  int _rebuildCount = 0;
  late NotesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotesController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<NotesController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: _buildBody(controller),
            floatingActionButton: _buildFAB(),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Notas com Selector'),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          child: Text(
            'Rebuilds: $_rebuildCount',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Forçar rebuild',
          onPressed: () => setState(() => _rebuildCount++),
        ),
      ],
    );
  }

  Widget _buildBody(NotesController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(child: Text('Erro: ${controller.error}'));
    }

    return Column(
      children: [
        _buildHeader(),
        TagFilterWidget(controller: controller), // ✅ ADICIONAR ESTA LINHA
        SearchWidget(controller: controller), // ✅ NOVO: Widget de busca
        Expanded(
          child: NotesList(controller: controller, onNoteTap: _editNote),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.green.withOpacity(0.1),
      child: const Text(
        'Notas usando GenericSelectorList para isolamento.\n'
        'Clique em qualquer nota para editar.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  FloatingActionButton _buildFAB() {
    return FloatingActionButton(
      onPressed: _addNewNote,
      tooltip: 'Nova Nota',
      child: const Icon(Icons.add),
    );
  }

  Future<void> _editNote(Note note) async {
    final result = await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) {
        return NoteDialog(
          title: 'Editar Nota',
          initialTitle: note.title,
          initialContent: note.content,
          initialTags: note.tags,
          availableTags: _controller.suggestedTags,
          getTagColor: _controller.getTagColor,
        );
      },
    );

    if (result == null) return;

    try {
      await _controller.updateNoteFromDialog(note, result);
      _showSnackBar('Nota atualizada com sucesso!');
    } catch (e) {
      _showSnackBar('Erro ao atualizar: $e');
    }
  }

  Future<void> _addNewNote() async {
    final result = await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) {
        return NoteDialog(
          title: 'Nova Nota',
          availableTags: _controller.suggestedTags,
          getTagColor: _controller.getTagColor,
        );
      },
    );

    if (result == null) return;

    try {
      await _controller.addNoteFromDialog(result);
      _showSnackBar('Nota adicionada com sucesso!');
    } catch (e) {
      _showSnackBar('Erro ao adicionar nota: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
