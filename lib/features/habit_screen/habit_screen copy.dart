import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Adicionado para o FilteringTextInputFormatter
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
  int _rebuildCount = 0;
  late HabitController _controller;
  Habit? _selectedHabit;

  // Cache do painel para evitar reconstrução
  Widget? _cachedEditPanel;
  String? _cachedHabitId;

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

    if (_selectedHabit != null &&
        !_controller.habits.any((h) => h.id == _selectedHabit!.id)) {
      setState(() {
        _selectedHabit = null;
        _cachedEditPanel = null;
        _cachedHabitId = null;
      });
    }

    if (_controller.successMessage != null) {
      _showSnackBar(_controller.successMessage!, isError: false);
      _controller.clearMessages();
    }

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

  Widget _buildBody(HabitController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return Column(
        children: [
          HabitFilterWidget(controller: controller),
          HabitSearchWidget(controller: controller),
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

    // Cache do painel de edição para evitar reconstrução completa a cada mudança
    if (_selectedHabit != null &&
        (_cachedHabitId != _selectedHabit!.id || _cachedEditPanel == null)) {
      _cachedHabitId = _selectedHabit!.id;
      _cachedEditPanel = HabitEditPanel(
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
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              HabitFilterWidget(controller: controller),
              HabitSearchWidget(controller: controller),
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
        // ✅ ALTERAÇÃO: SizedBox em vez de AnimatedContainer para exibição instantânea
        SizedBox(
          width:
              _selectedHabit != null
                  ? MediaQuery.of(context).size.width * 0.35
                  : 0,
          child: _selectedHabit != null ? _cachedEditPanel : null,
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
            // Invalidar cache quando o hábito é atualizado
            _cachedEditPanel = null;
            _cachedHabitId = null;
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
