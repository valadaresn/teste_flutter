import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../screens/diary_screen/diary_controller.dart';
import '../../models/diary_entry.dart';
import 'widgets/diary_entry_card.dart';
import 'widgets/diary_entry_form.dart';

/// **DiaryScreen** - Tela dedicada do diário
///
/// Tela standalone para gerenciamento de entradas de diário
/// com fundo rosado suave e components dedicados
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late DiaryController _diaryController;
  List<DiaryEntry> _entries = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _diaryController = DiaryController();
    _loadDiaryEntries();
  }

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  /// Carrega todas as entradas de diário filtradas por data
  Future<void> _loadDiaryEntries() async {
    try {
      setState(() => _isLoading = true);

      // Carregar entradas via controller
      await _diaryController.loadEntries();

      // Acessar entradas do controller
      final allEntries = _diaryController.entries;

      // Filtrar por data selecionada
      final filteredEntries =
          allEntries.where((entry) {
            final entryDate = DateTime(
              entry.dateTime.year,
              entry.dateTime.month,
              entry.dateTime.day,
            );
            final selectedDay = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
            );
            return entryDate.isAtSameMomentAs(selectedDay);
          }).toList();

      // Ordenar por hora (mais recente primeiro)
      filteredEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      setState(() {
        _entries = filteredEntries;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Erro ao carregar entradas de diário: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Adiciona nova entrada de diário na data selecionada
  Future<void> _addDiaryEntry(
    String content,
    String mood, {
    String? title,
  }) async {
    try {
      // Criar nova entrada com data/hora atual ou da data selecionada
      final now = DateTime.now();
      final entryDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        now.hour,
        now.minute,
        now.second,
      );

      final newEntry = DiaryEntry(
        id: const Uuid().v4(),
        title: title,
        content: content,
        mood: mood,
        dateTime: entryDateTime,
        tags: [],
        isFavorite: false,
      );

      // Salvar no Firebase
      final success = await _diaryController.addDiaryEntry(newEntry);

      if (success) {
        // Adicionar à lista local e atualizar UI
        setState(() {
          _entries.insert(0, newEntry); // Mais recente primeiro
        });

        _showSnackBar('📝 Entrada adicionada com sucesso!', isError: false);
      } else {
        _showSnackBar('❌ Erro ao adicionar entrada', isError: true);
      }
    } catch (e) {
      debugPrint('❌ Erro ao adicionar entrada: $e');
      _showSnackBar('❌ Erro ao adicionar entrada', isError: true);
    }
  }

  /// Edita entrada existente
  Future<void> _editDiaryEntry(DiaryEntry entry) async {
    // Por enquanto, apenas log - implementar edição completa depois
    debugPrint('🔄 Editando entrada: ${entry.id}');
    _showSnackBar('✏️ Edição em desenvolvimento', isError: false);
  }

  /// Exclui entrada de diário
  Future<void> _deleteDiaryEntry(String entryId) async {
    try {
      final success = await _diaryController.deleteEntry(entryId);

      if (success) {
        setState(() {
          _entries.removeWhere((entry) => entry.id == entryId);
        });
        _showSnackBar('🗑️ Entrada excluída', isError: false);
      } else {
        _showSnackBar('❌ Erro ao excluir entrada', isError: true);
      }
    } catch (e) {
      debugPrint('❌ Erro ao excluir entrada: $e');
      _showSnackBar('❌ Erro ao excluir entrada', isError: true);
    }
  }

  /// Alterna status de favorito
  Future<void> _toggleFavorite(DiaryEntry entry, bool isFavorite) async {
    try {
      final success = await _diaryController.toggleFavorite(
        entry.id,
        isFavorite,
      );

      if (success) {
        _showSnackBar(
          isFavorite
              ? '⭐ Adicionado aos favoritos'
              : '💔 Removido dos favoritos',
          isError: false,
        );
      } else {
        _showSnackBar('❌ Erro ao atualizar favorito', isError: true);
      }
    } catch (e) {
      debugPrint('❌ Erro ao alterar favorito: $e');
      _showSnackBar('❌ Erro ao atualizar favorito', isError: true);
    }
  }

  /// Navega para o dia anterior
  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _loadDiaryEntries();
  }

  /// Navega para o próximo dia
  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _loadDiaryEntries();
  }

  /// Formata a data selecionada para exibição
  String _formatSelectedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final difference = today.difference(selectedDay).inDays;

    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Ontem';
    } else if (difference == -1) {
      return 'Amanhã';
    } else {
      // Formato "22 jul"
      final months = [
        '',
        'jan',
        'fev',
        'mar',
        'abr',
        'mai',
        'jun',
        'jul',
        'ago',
        'set',
        'out',
        'nov',
        'dez',
      ];
      return '${_selectedDate.day} ${months[_selectedDate.month]}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF0F0), // Fundo mais rosado
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Constrói a AppBar com título, seletor de data e contador
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(
        0xFFFCF0F0,
      ), // Mesmo fundo da tela (mais rosado)
      elevation: 0,
      title: Row(
        children: [
          // Título
          Text(
            'Diário',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(width: 16),

          // Seletor de data
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seta para dia anterior
                IconButton(
                  onPressed: _previousDay,
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade700,
                ),

                // Data atual
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Text(
                    _formatSelectedDate(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),

                // Seta para próximo dia
                IconButton(
                  onPressed: _nextDay,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Contador de entradas
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${_entries.length}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  /// Constrói o corpo da tela
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.pinkAccent),
      );
    }

    return Column(
      children: [
        // Lista de entradas (ocupa a maior parte da tela)
        Expanded(
          child: _entries.isEmpty ? _buildEmptyState() : _buildEntriesList(),
        ),

        // Formulário fixo no bottom para nova entrada
        Container(
          color: const Color(0xFFFCF0F0), // Fundo mais rosado
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Linha divisória sutil
              Container(
                height: 1,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.only(bottom: 12),
              ),
              DiaryEntryForm(onSubmit: _addDiaryEntry),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói estado vazio quando não há entradas
  Widget _buildEmptyState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nenhuma entrada para ${_formatSelectedDate().toLowerCase()}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione uma nova entrada abaixo',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a lista de entradas de diário
  Widget _buildEntriesList() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(
          12,
        ), // Padding reduzido para menos espaço branco
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];

          return DiaryEntryCard(
            entry: entry,
            onEdit: _editDiaryEntry,
            onDelete: () => _deleteDiaryEntry(entry.id),
            onToggleFavorite:
                (isFavorite) => _toggleFavorite(entry, isFavorite),
            isFavorite: _diaryController.favorites[entry.id] ?? false,
          );
        },
      ),
    );
  }

  /// Mostra SnackBar para feedback
  void _showSnackBar(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade600 : Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
