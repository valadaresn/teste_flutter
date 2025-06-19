import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_controller.dart';
import 'habit_model.dart';
import 'widgets/habit_edit_form.dart';
import 'widgets/habit_edit_panel.dart';
import 'widgets/habit_edit_screen.dart';
import 'widgets/habit_list.dart';
import 'widgets/habit_search_widget.dart';
import 'widgets/habit_filter_widget.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late HabitController _controller;
  Habit? _selectedHabit;

  @override
  void initState() {
    super.initState();
    _controller = HabitController();
    _controller.addListener(_handleControllerChanges);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanges);
    _controller.dispose();
    super.dispose();
  }

  void _handleControllerChanges() {
    if (!mounted) return;

    // Se o hábito selecionado for excluído, limpa a seleção
    if (_selectedHabit != null &&
        !_controller.habits.any((h) => h.id == _selectedHabit!.id)) {
      setState(() {
        _selectedHabit = null;
      });
    }

    // Mostrar mensagem de sucesso
    if (_controller.successMessage != null) {
      _showSnackBar(_controller.successMessage!, isError: false);
      _controller.clearMessages();
    }

    // Mostrar mensagem de erro
    if (_controller.error != null && !_controller.isLoading) {
      _showSnackBar(_controller.error!, isError: true);
      _controller.clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<HabitController>(
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
      title: const Text('Hábitos'),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _buildFilterButton(
                'Ativos',
                'active',
                Icons.visibility,
                _controller.selectedFilterTags.contains('active'),
              ),
              const SizedBox(width: 8),
              _buildFilterButton(
                'Hoje',
                'today',
                Icons.today,
                _controller.selectedFilterTags.contains('today'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(
    String label,
    String tag,
    IconData icon,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => _controller.toggleFilterTag(tag),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(HabitController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return Column(
        children: [
          Expanded(
            child: HabitList(
              controller: controller,
              onHabitTap: _handleHabitTap,
              selectedHabitId: null,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: HabitList(
                  controller: controller,
                  onHabitTap: _handleHabitTap,
                  selectedHabitId: _selectedHabit?.id,
                ),
              ),
            ],
          ),
        ),
        // ✅ MUDANÇA: Animação mais rápida (150ms como MS To Do)
        AnimatedContainer(
          duration: const Duration(
            milliseconds: 10,
          ), // ← Era 300ms, agora 150ms
          curve: Curves.easeInOut, // ✅ Curva mais suave
          width:
              _selectedHabit != null
                  ? MediaQuery.of(context).size.width * 0.35
                  : 0,
          child:
              _selectedHabit != null
                  ? HabitEditPanel(
                    habit: _selectedHabit!,
                    onSave: (updatedData) async {
                      await _updateHabit(_selectedHabit!, updatedData);
                      return Future<void>.value();
                    },
                    onClose: () {
                      setState(() {
                        _selectedHabit = null;
                      });
                    },
                    emojiOptions: _controller.emojiOptions,
                    colorOptions: _controller.colorOptions,
                    dayNames: _controller.dayNames,
                    dayLabels: _controller.dayLabels,
                  )
                  : null,
        ),
      ],
    );
  }

  FloatingActionButton _buildFAB() {
    return FloatingActionButton(
      onPressed: _addNewHabit,
      tooltip: 'Novo Hábito',
      child: const Icon(Icons.add),
    );
  }

  void _handleHabitTap(Habit habit) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => HabitEditScreen(
                habit: habit,
                onSave: (updatedData) async {
                  await _updateHabit(habit, updatedData);
                  Navigator.of(context).pop();
                  return Future<void>.value();
                },
                emojiOptions: _controller.emojiOptions,
                colorOptions: _controller.colorOptions,
                dayNames: _controller.dayNames,
                dayLabels: _controller.dayLabels,
              ),
        ),
      );
    } else {
      setState(() {
        if (_selectedHabit?.id == habit.id) {
          _selectedHabit = null;
        } else {
          _selectedHabit = habit;
        }
      });
    }
  }

  Future<void> _updateHabit(
    Habit habit,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final success = await _controller.updateHabitFromDialog(
        habit,
        updatedData,
      );

      if (success && mounted) {
        _showSnackBar('Hábito atualizado com sucesso!', isError: false);
        if (_selectedHabit?.id == habit.id) {
          setState(() {
            _selectedHabit = _controller.getHabitById(habit.id);
          });
        }
      }
      return Future<void>.value();
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao atualizar: $e', isError: true);
      }
      return Future<void>.value();
    }
  }

  Future<void> _addNewHabit() async {
    try {
      final isSmallScreen = MediaQuery.of(context).size.width < 600;

      if (isSmallScreen) {
        final result = await Navigator.of(context).push<Map<String, dynamic>>(
          MaterialPageRoute(
            builder:
                (context) => HabitEditScreen.forNewHabit(
                  onSave: (data) {
                    Navigator.of(context).pop(data);
                    return Future<void>.value();
                  },
                  emojiOptions: _controller.emojiOptions,
                  colorOptions: _controller.colorOptions,
                  dayNames: _controller.dayNames,
                  dayLabels: _controller.dayLabels,
                ),
          ),
        );

        if (result != null) {
          await _saveNewHabit(result);
        }
      } else {
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder:
              (context) => Dialog(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.8,
                  padding: const EdgeInsets.all(16),
                  child: HabitEditPanel.forNewHabit(
                    onSave: (data) {
                      Navigator.of(context).pop(data);
                      return Future<void>.value();
                    },
                    onClose: () {
                      Navigator.of(context).pop();
                    },
                    emojiOptions: _controller.emojiOptions,
                    colorOptions: _controller.colorOptions,
                    dayNames: _controller.dayNames,
                    dayLabels: _controller.dayLabels,
                  ),
                ),
              ),
        );

        if (result != null) {
          await _saveNewHabit(result);
        }
      }
      return Future<void>.value();
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao criar hábito: $e', isError: true);
      }
      return Future<void>.value();
    }
  }

  Future<void> _saveNewHabit(Map<String, dynamic> data) async {
    try {
      final success = await _controller.addHabitFromDialog(data);

      if (success && mounted) {
        _showSnackBar('Hábito adicionado com sucesso!', isError: false);
      }
      return Future<void>.value();
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao adicionar hábito: $e', isError: true);
      }
      return Future<void>.value();
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red[600] : Colors.green[600],
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: isError ? 4 : 2),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
}
