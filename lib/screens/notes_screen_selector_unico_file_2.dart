// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../components/generic_selector_list.dart';
// import 'diary_screen/controllers/notes_controller.dart';
// import '../models/note.dart';

// class NotesScreenSelector extends StatefulWidget {
//   const NotesScreenSelector({Key? key}) : super(key: key);

//   @override
//   State<NotesScreenSelector> createState() => _NotesScreenSelectorState();
// }

// class _NotesScreenSelectorState extends State<NotesScreenSelector> {
//   int _rebuildCount = 0;

//   // Criar o controller como uma variável de instância
//   late NotesController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = NotesController();
//   }

//   @override
//   void dispose() {
//     _controller.dispose(); // Importante para evitar memory leaks
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//       value: _controller, // Usar o controller existente em vez de criar um novo
//       child: Consumer<NotesController>(
//         builder: (context, controller, _) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Notas com Selector'),
//               actions: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   alignment: Alignment.center,
//                   child: Text(
//                     'Rebuilds: $_rebuildCount',
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.refresh),
//                   tooltip: 'Forçar rebuild',
//                   onPressed: () => setState(() => _rebuildCount++),
//                 ),
//               ],
//             ),
//             body:
//                 controller.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : controller.error != null
//                     ? Center(child: Text('Erro: ${controller.error}'))
//                     : _buildContent(
//                       controller,
//                     ), // Passar controller diretamente
//             floatingActionButton: FloatingActionButton(
//               onPressed: () => _addNewNote(context),
//               tooltip: 'Nova Nota',
//               child: const Icon(Icons.add),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Modificar para receber o controller diretamente
//   Widget _buildContent(NotesController controller) {
//     return Column(
//       children: [
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(12),
//           color: Colors.green.withOpacity(0.1),
//           child: const Text(
//             'Notas usando GenericSelectorList para isolamento.\n'
//             'Clique em qualquer nota para editar.',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14),
//           ),
//         ),

//         controller.notes.isEmpty
//             ? const Expanded(
//               child: Center(
//                 child: Text('Nenhuma nota encontrada. Adicione uma nota.'),
//               ),
//             )
//             : Expanded(
//               child: GenericSelectorList<NotesController, Note>(
//                 listSelector: (ctrl) => ctrl.notes,
//                 itemById: (ctrl, id) => ctrl.getNoteById(id),
//                 idExtractor: (note) => note.id,
//                 itemBuilder: (context, note) {
//                   // Cores fixas para todas as notas
//                   const cardColor = Colors.white;
//                   const textColor = Colors.black;

//                   return Card(
//                     margin: const EdgeInsets.only(
//                       bottom: 12,
//                       left: 8,
//                       right: 8,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     // Sempre cor branca para o fundo
//                     color: cardColor,
//                     elevation: 2,
//                     child: InkWell(
//                       onTap: () => _editNote(context, note),
//                       // Cor do efeito splash ao tocar
//                       splashColor:
//                           note.tags.isNotEmpty
//                               ? _controller
//                                   .getTagColor(note.tags.first)
//                                   .withOpacity(0.3)
//                               : null,
//                       borderRadius: BorderRadius.circular(8),
//                       child: Container(
//                         decoration:
//                             note.tags.isNotEmpty
//                                 ? BoxDecoration(
//                                   border: Border(
//                                     left: BorderSide(
//                                       color: _controller.getTagColor(
//                                         note.tags.first,
//                                       ),
//                                       width: 5,
//                                     ),
//                                   ),
//                                 )
//                                 : null,
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       note.title.isEmpty
//                                           ? 'Sem título'
//                                           : note.title,
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                         // Destacar título se for importante
//                                         color:
//                                             note.tags.contains('Importante')
//                                                 ? Colors.red.shade700
//                                                 : textColor,
//                                       ),
//                                     ),
//                                   ),
//                                   Text(
//                                     '${note.dateTime.day}/${note.dateTime.month}/${note.dateTime.year}',
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 12),
//                               Text(
//                                 note.content,
//                                 maxLines: 3,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(color: Colors.black87),
//                               ),
//                               if (note.tags.isNotEmpty) ...[
//                                 const SizedBox(height: 12),
//                                 Wrap(
//                                   spacing: 4,
//                                   runSpacing: 4,
//                                   children:
//                                       note.tags
//                                           .map((tag) => _buildTagChip(tag))
//                                           .toList(),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//       ],
//     );
//   }

//   // Chip para exibir tags - usar o _controller diretamente
//   Widget _buildTagChip(String tag) {
//     final tagColor = _controller.getTagColor(tag);

//     return Chip(
//       label: Text(
//         tag,
//         style: TextStyle(fontSize: 10, color: _contrastColor(tagColor)),
//       ),
//       backgroundColor: tagColor,
//       visualDensity: VisualDensity.compact,
//       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       padding: EdgeInsets.zero,
//     );
//   }

//   // Determina a cor do texto baseado na cor de fundo
//   Color _contrastColor(Color backgroundColor) {
//     final luminance = backgroundColor.computeLuminance();
//     return luminance > 0.5 ? Colors.black : Colors.white;
//   }

//   Future<void> _editNote(BuildContext context, Note note) async {
//     final titleController = TextEditingController(text: note.title);
//     final contentController = TextEditingController(text: note.content);

//     // Lista de tags já selecionadas para essa nota
//     final selectedTags = List<String>.from(note.tags);

//     final result = await showDialog<Map<String, dynamic>>(
//       context: context,
//       builder:
//           (context) => StatefulBuilder(
//             builder:
//                 (context, setState) => AlertDialog(
//                   title: const Text('Editar Nota'),
//                   content: SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         TextField(
//                           controller: titleController,
//                           decoration: const InputDecoration(
//                             labelText: 'Título',
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         TextField(
//                           controller: contentController,
//                           decoration: const InputDecoration(
//                             labelText: 'Conteúdo',
//                           ),
//                           maxLines: 5,
//                         ),
//                         const SizedBox(height: 16),
//                         const Text('Tags:'),
//                         const SizedBox(height: 8),
//                         Wrap(
//                           spacing: 8,
//                           children:
//                               _controller.suggestedTags.map((tag) {
//                                 final tagColor = _controller.getTagColor(tag);
//                                 return FilterChip(
//                                   label: Text(
//                                     tag,
//                                     style: TextStyle(
//                                       color:
//                                           selectedTags.contains(tag)
//                                               ? _contrastColor(tagColor)
//                                               : null,
//                                     ),
//                                   ),
//                                   backgroundColor: tagColor.withOpacity(0.2),
//                                   selectedColor: tagColor,
//                                   checkmarkColor: _contrastColor(tagColor),
//                                   selected: selectedTags.contains(tag),
//                                   onSelected: (selected) {
//                                     setState(() {
//                                       if (selected) {
//                                         selectedTags.add(tag);
//                                       } else {
//                                         selectedTags.remove(tag);
//                                       }
//                                     });
//                                   },
//                                 );
//                               }).toList(),
//                         ),
//                       ],
//                     ),
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('Cancelar'),
//                     ),
//                     TextButton(
//                       onPressed:
//                           () => Navigator.pop(context, {
//                             'title': titleController.text,
//                             'content': contentController.text,
//                             'tags': selectedTags,
//                           }),
//                       child: const Text('Salvar'),
//                     ),
//                   ],
//                 ),
//           ),
//     );

//     if (result == null) return;

//     try {
//       await _controller.updateNote(
//         note.id,
//         result['title'],
//         result['content'],
//         result['tags'],
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Nota atualizada com sucesso!')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
//       }
//     }
//   }

//   Future<void> _addNewNote(BuildContext context) async {
//     final titleController = TextEditingController();
//     final contentController = TextEditingController();

//     // Lista de tags selecionadas para a nova nota
//     final selectedTags = <String>[];

//     final result = await showDialog<Map<String, dynamic>>(
//       context: context,
//       builder:
//           (context) => StatefulBuilder(
//             builder:
//                 (context, setState) => AlertDialog(
//                   title: const Text('Nova Nota'),
//                   content: SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         TextField(
//                           controller: titleController,
//                           decoration: const InputDecoration(
//                             labelText: 'Título',
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         TextField(
//                           controller: contentController,
//                           decoration: const InputDecoration(
//                             labelText: 'Conteúdo',
//                           ),
//                           maxLines: 5,
//                         ),
//                         const SizedBox(height: 16),
//                         const Text('Tags:'),
//                         const SizedBox(height: 8),
//                         Wrap(
//                           spacing: 8,
//                           children:
//                               _controller.suggestedTags.map((tag) {
//                                 final tagColor = _controller.getTagColor(tag);
//                                 return FilterChip(
//                                   label: Text(
//                                     tag,
//                                     style: TextStyle(
//                                       color:
//                                           selectedTags.contains(tag)
//                                               ? _contrastColor(tagColor)
//                                               : null,
//                                     ),
//                                   ),
//                                   backgroundColor: tagColor.withOpacity(0.2),
//                                   selectedColor: tagColor,
//                                   checkmarkColor: _contrastColor(tagColor),
//                                   selected: selectedTags.contains(tag),
//                                   onSelected: (selected) {
//                                     setState(() {
//                                       if (selected) {
//                                         selectedTags.add(tag);
//                                       } else {
//                                         selectedTags.remove(tag);
//                                       }
//                                     });
//                                   },
//                                 );
//                               }).toList(),
//                         ),
//                       ],
//                     ),
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('Cancelar'),
//                     ),
//                     TextButton(
//                       onPressed:
//                           () => Navigator.pop(context, {
//                             'title': titleController.text,
//                             'content': contentController.text,
//                             'tags': selectedTags,
//                           }),
//                       child: const Text('Salvar'),
//                     ),
//                   ],
//                 ),
//           ),
//     );

//     if (result == null) return;

//     try {
//       await _controller.addNote(
//         result['title'],
//         result['content'],
//         result['tags'],
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Nota adicionada com sucesso!')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Erro ao adicionar nota: $e')));
//       }
//     }
//   }
// }
