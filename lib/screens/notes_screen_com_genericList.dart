import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/firestore_isolated_components.dart';
import '../features/note_screen/note_model.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final String _collectionPath = 'notas';
  int _rebuildCount = 0;

  // Adicione esta chave global para acessar o estado da lista
  final GlobalKey<FirestoreIsolatedListState> _listKey =
      GlobalKey<FirestoreIsolatedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
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
            onPressed:
                () => setState(() {
                  _rebuildCount++;
                  // Também podemos recarregar a lista ao pressionar refresh
                  _listKey.currentState?.reloadIds();
                }),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.withOpacity(0.1),
            child: const Text(
              'Notas usando o componente FirestoreIsolatedList.\n'
              'Clique em qualquer nota para editar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: FirestoreIsolatedList<Note>(
              // Adicione a key aqui para acessar o estado
              key: _listKey,
              collectionPath: _collectionPath,
              queryBuilder:
                  (collection) =>
                      collection.orderBy('dateTime', descending: true),
              emptyBuilder: const Center(
                child: Text('Nenhuma nota encontrada. Adicione uma nota.'),
              ),
              itemBuilder: (context, docRef, id) {
                return IsolatedFirestoreItem(
                  key: ValueKey('note_$id'),
                  documentRef: docRef,
                  dataTransformer: (data) {
                    final processedData = Map<String, dynamic>.from(data);
                    if (data['dateTime'] is Timestamp) {
                      processedData['dateTime'] =
                          (data['dateTime'] as Timestamp)
                              .toDate()
                              .toIso8601String();
                    }
                    return processedData;
                  },
                  builder: (context, data, id) {
                    final note = Note.fromMap(data, id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _editNote(docRef, note),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title.isEmpty ? 'Sem título' : note.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${note.dateTime.day}/${note.dateTime.month}/${note.dateTime.year}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                note.content,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewNote,
        tooltip: 'Nova Nota',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _editNote(DocumentReference docRef, Note note) async {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar Nota'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Conteúdo'),
                  maxLines: 5,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(context, {
                      'title': titleController.text,
                      'content': contentController.text,
                    }),
                child: const Text('Salvar'),
              ),
            ],
          ),
    );

    if (result == null) return;

    try {
      await docRef.update({
        'title': result['title'],
        'content': result['content'],
        'dateTime': DateTime.now().toIso8601String(),
      });

      // Feedback para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nota atualizada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
      }
    }
  }

  Future<void> _addNewNote() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nova Nota'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Conteúdo'),
                  maxLines: 5,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(context, {
                      'title': titleController.text,
                      'content': contentController.text,
                    }),
                child: const Text('Salvar'),
              ),
            ],
          ),
    );

    if (result == null) return;

    try {
      await FirebaseFirestore.instance.collection(_collectionPath).add({
        'title': result['title'],
        'content': result['content'],
        'dateTime': DateTime.now().toIso8601String(),
      });

      // CORREÇÃO CRÍTICA: Recarrega a lista após adicionar um novo documento
      _listKey.currentState?.reloadIds();

      // Feedback para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nota adicionada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao adicionar nota: $e')));
      }
    }
  }
}
