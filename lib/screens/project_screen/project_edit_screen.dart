import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../models/task_list.dart';

class ProjectEditScreen extends StatefulWidget {
  final Project? project;
  final Function(Project) onSave;
  final Function(String) onDelete;

  const ProjectEditScreen({
    super.key,
    this.project,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends State<ProjectEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _newListController = TextEditingController();

  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.work;
  List<TaskList> _lists = [];
  bool _isProcessing = false;

  // Opções disponíveis para cores e ícones
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
    Colors.brown,
  ];

  final List<IconData> _availableIcons = [
    Icons.work,
    Icons.person,
    Icons.home,
    Icons.school,
    Icons.shopping_cart,
    Icons.sports_soccer,
    Icons.favorite,
    Icons.beach_access,
    Icons.book,
    Icons.fitness_center,
    Icons.catching_pokemon,
    Icons.apartment,
    Icons.pending_actions,
    Icons.code,
    Icons.lightbulb,
    Icons.music_note,
    Icons.family_restroom,
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Se estamos editando, carregar os dados do projeto
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _selectedColor = widget.project!.color;
      _selectedIcon = widget.project!.icon;
      _lists = [...widget.project!.lists];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newListController.dispose();
    super.dispose();
  }

  void _addNewList() {
    final name = _newListController.text.trim();
    if (name.isEmpty) return;

    // Verificar se já existe uma lista com este nome
    if (_lists.any((list) => list.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Já existe uma lista com este nome'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _lists.add(
        TaskList(
          id: 'list_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
        ),
      );
      _newListController.clear();
    });
  }

  void _removeList(int index) {
    setState(() {
      _lists.removeAt(index);
    });
  }

  void _saveProject() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nome do projeto não pode ser vazio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final project = Project(
        id:
            widget.project?.id ??
            'project_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        color: _selectedColor,
        icon: _selectedIcon,
        lists: _lists,
        pendingTasks: widget.project?.pendingTasks ?? 0,
      );

      widget.onSave(project);
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Excluir projeto?'),
            content: Text(
              'Tem certeza que deseja excluir o projeto "${widget.project?.name}"? Esta ação não poderá ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fechar o diálogo
                  widget.onDelete(widget.project!.id);
                  Navigator.pop(context); // Fechar a tela de edição
                },
                child: const Text(
                  'EXCLUIR',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Projeto' : 'Novo Projeto'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _confirmDelete,
              tooltip: 'Excluir projeto',
            ),
          TextButton(
            onPressed: _isProcessing ? null : _saveProject,
            child:
                _isProcessing
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('SALVAR'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nome do projeto
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do projeto',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, informe um nome para o projeto';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Seletor de cores
            const Text(
              'Cor do projeto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    _availableColors.map((color) {
                      final isSelected = color.value == _selectedColor.value;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSelected 
                                ? [BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )] 
                                : null,
                          ),
                          child:
                              isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Seletor de ícones
            const Text(
              'Ícone do projeto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    _availableIcons.map((icon) {
                      final isSelected =
                          icon.codePoint == _selectedIcon.codePoint;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? _selectedColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? _selectedColor : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            size: 24,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Listas do projeto
            Row(
              children: [
                const Text(
                  'Listas do projeto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_lists.isNotEmpty)
                  Text(
                    '${_lists.length} ${_lists.length == 1 ? 'lista' : 'listas'}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Formulário para adicionar nova lista
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _newListController,
                    decoration: const InputDecoration(
                      hintText: 'Nome da nova lista',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _addNewList(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addNewList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de listas existentes
            if (_lists.isEmpty)
              Card(
                color: Colors.grey.shade100,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Nenhuma lista adicionada ainda',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _lists.length,
                itemBuilder: (context, index) {
                  final list = _lists[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(list.name),
                      leading: Icon(Icons.list, color: _selectedColor),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeList(index),
                        tooltip: 'Remover lista',
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
