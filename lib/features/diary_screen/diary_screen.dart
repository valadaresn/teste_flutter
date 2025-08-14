import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'diary_controller.dart' as NewDiary;
import '../../models/diary_entry.dart';
import 'widgets/diary_entries_list.dart';
import 'widgets/diary_detail_panel.dart';
import '../task_management/widgets/tasks/detail/diary/task_diary_entry_form.dart';

/// **DiaryScreen** - Tela dedicada do diário
///
/// Tela standalone para gerenciamento de entradas de diário
/// com fundo rosado suave e components dedicados
///
/// Agora usando o novo sistema:
/// - NewDiary.DiaryController com Provider
/// - DiaryEntriesList com GenericSelectorList
/// - Evita piscar da tela conforme instrucoes_lista.txt
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewDiary.DiaryController(),
      child: Consumer<NewDiary.DiaryController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFFCF0F0),
            appBar: _buildAppBar(controller),
            body: _buildBody(controller),
          );
        },
      ),
    );
  }

  /// Constrói a AppBar com navegação de datas
  PreferredSizeWidget _buildAppBar(NewDiary.DiaryController controller) {
    return AppBar(
      backgroundColor: const Color(0xFFF8E8E8),
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.book, color: Colors.pinkAccent, size: 24),
          const SizedBox(width: 8),
          const Text(
            'Diário',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),

          // Navegação de data
          Row(
            children: [
              // Seta para dia anterior
              IconButton(
                onPressed: _previousDay,
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                color: Colors.grey.shade700,
              ),

              // Data selecionada (clicável para abrir calendário)
              GestureDetector(
                onTap: _showDatePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
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
            '${controller.getFilteredEntries().length}',
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
  Widget _buildBody(NewDiary.DiaryController controller) {
    // 🔥 APLICAR FILTRO DE DATA APÓS O BUILD
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setDateFilter(_selectedDate);
    });

    return Column(
      children: [
        // Lista de entradas (ocupa a maior parte da tela)
        Expanded(
          child:
              controller.getFilteredEntries().isEmpty
                  ? _buildEmptyState()
                  : _buildEntriesList(),
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
              TaskDiaryEntryForm(onSubmit: _addDiaryEntry),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói estado vazio quando não há entradas
  Widget _buildEmptyState() {
    return Container(
      color: const Color(0xFFFCF0F0), // Mesmo fundo rosado da tela
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

  /// Constrói a lista de entradas usando DiaryEntriesList com GenericSelectorList
  Widget _buildEntriesList() {
    return Container(
      color: const Color(0xFFFCF0F0), // Mesmo fundo rosado da tela
      child: DiaryEntriesList(
        onEditEntry: _editDiaryEntry,
        onDeleteEntry: _deleteDiaryEntry,
        onToggleFavorite: _toggleFavorite,
      ),
    );
  }

  /// Adiciona nova entrada de diário na data selecionada
  Future<void> _addDiaryEntry(String content, String mood) async {
    final controller = Provider.of<NewDiary.DiaryController>(
      context,
      listen: false,
    );

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
        title: null, // TaskDiaryEntryForm não fornece título
        content: content,
        mood: mood,
        dateTime: entryDateTime,
        tags: [],
        isFavorite: false,
      );

      // Salvar via novo controller
      await controller.addEntry(newEntry);
      _showSnackBar('📝 Entrada adicionada com sucesso!', isError: false);
    } catch (e) {
      debugPrint('❌ Erro ao adicionar entrada: $e');
      _showSnackBar('❌ Erro ao adicionar entrada', isError: true);
    }
  }

  /// Edita entrada existente
  Future<void> _editDiaryEntry(DiaryEntry entry) async {
    final controller = Provider.of<NewDiary.DiaryController>(
      context,
      listen: false,
    );

    // 🎯 USAR O NOVO PAINEL DE DETALHES
    await DiaryDetailPanel.showAuto(
      context: context,
      entry: entry,
      controller: controller,
      onDeleted: () {
        _showSnackBar('🗑️ Entrada excluída!', isError: false);
      },
      onUpdated: () {
        _showSnackBar('✅ Entrada atualizada!', isError: false);
      },
    );
  }

  /// Exclui entrada de diário
  Future<void> _deleteDiaryEntry(String entryId) async {
    final controller = Provider.of<NewDiary.DiaryController>(
      context,
      listen: false,
    );

    try {
      await controller.deleteEntry(entryId);
      _showSnackBar('🗑️ Entrada excluída com sucesso!', isError: false);
    } catch (e) {
      debugPrint('❌ Erro ao excluir entrada: $e');
      _showSnackBar('❌ Erro ao excluir entrada', isError: true);
    }
  }

  /// Toggle favorito de uma entrada
  Future<void> _toggleFavorite(DiaryEntry entry, bool isFavorite) async {
    final controller = Provider.of<NewDiary.DiaryController>(
      context,
      listen: false,
    );

    try {
      await controller.toggleFavorite(entry.id, isFavorite);
      final message =
          isFavorite
              ? '⭐ Adicionado aos favoritos'
              : '☆ Removido dos favoritos';
      _showSnackBar(message, isError: false);
    } catch (e) {
      debugPrint('❌ Erro ao alterar favorito: $e');
      _showSnackBar('❌ Erro ao alterar favorito', isError: true);
    }
  }

  /// Navega para o dia anterior
  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  /// Navega para o próximo dia
  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  /// Abre o seletor de data
  Future<void> _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  /// Formata a data selecionada para exibição
  String _formatSelectedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    if (selected.isAtSameMomentAs(today)) {
      return 'Hoje';
    } else if (selected.isAtSameMomentAs(
      today.subtract(const Duration(days: 1)),
    )) {
      return 'Ontem';
    } else if (selected.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Amanhã';
    } else {
      // Formato: "Seg, 15 Jan"
      const meses = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ];
      const diasSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

      final diaSemana = diasSemana[_selectedDate.weekday % 7];
      final mes = meses[_selectedDate.month - 1];

      return '$diaSemana, ${_selectedDate.day} $mes';
    }
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
