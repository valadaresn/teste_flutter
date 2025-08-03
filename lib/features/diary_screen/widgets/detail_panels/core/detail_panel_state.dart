import 'package:flutter/material.dart';
import '../../../../../models/diary_entry.dart';
import '../../../../../screens/diary_screen/diary_controller.dart';
import '../utils/detail_panel_constants.dart';
import '../utils/detail_panel_helpers.dart';

/// **DetailPanelStateMixin** - Mixin para gerenciar estado comum dos painéis
///
/// Centraliza o gerenciamento de estado compartilhado entre painéis mobile e desktop:
/// - Controllers de texto e foco
/// - Estados de salvamento e alterações
/// - Lista de moods disponíveis
/// - Métodos de inicialização e dispose
mixin DetailPanelStateMixin<T extends StatefulWidget> on State<T> {
  // 🎮 Controllers e FocusNodes
  late TextEditingController contentController;
  late FocusNode contentFocusNode;

  // 📊 Estados da entrada
  late String selectedMood;
  late bool isFavorite;

  // 🔄 Estados de operação
  bool isSaving = false;
  bool hasUnsavedChanges = false;
  String originalContent = '';

  // 😊 Lista de moods disponíveis
  List<String> get availableMoods => DetailPanelConstants.defaultMoods;

  // 📝 Entry e Controller (devem ser fornecidos pela implementação)
  DiaryEntry get entry;
  DiaryController get controller;

  // 🎯 Callbacks (devem ser fornecidos pela implementação)
  VoidCallback? get onDeleted;
  VoidCallback? get onUpdated;

  /// 🚀 Inicializa o estado comum do painel
  void initializePanelState() {
    contentController = TextEditingController(text: entry.content);
    contentFocusNode = FocusNode();
    selectedMood = entry.mood;
    isFavorite = controller.favorites[entry.id] ?? entry.isFavorite;
    originalContent = entry.content;

    // Listener para mudanças de foco
    contentFocusNode.addListener(onFocusChange);
  }

  /// 🧹 Limpa recursos do painel
  void disposePanelState() {
    contentFocusNode.removeListener(onFocusChange);
    contentFocusNode.dispose();
    contentController.dispose();
  }

  /// 🔍 Detecta mudanças de foco e salva quando necessário
  void onFocusChange() {
    debugPrint(
      '🔍 onFocusChange: hasFocus=${contentFocusNode.hasFocus}, hasUnsavedChanges=$hasUnsavedChanges',
    );

    if (!contentFocusNode.hasFocus && hasUnsavedChanges) {
      debugPrint('🔄 Campo perdeu foco, salvando alterações...');
      saveChanges();
    }

    // Detectar se há mudanças no conteúdo
    final currentContent = contentController.text;
    final contentChanged = DetailPanelHelpers.hasContentChanged(
      originalContent,
      currentContent,
    );

    debugPrint(
      '🔍 Conteúdo atual: "${currentContent.length > 50 ? currentContent.substring(0, 50) + "..." : currentContent}"',
    );
    debugPrint(
      '🔍 Conteúdo original: "${originalContent.length > 50 ? originalContent.substring(0, 50) + "..." : originalContent}"',
    );
    debugPrint('🔍 Conteúdo mudou: $contentChanged');

    if (contentChanged && !hasUnsavedChanges) {
      debugPrint('🔄 Marcando como tendo mudanças não salvas');
      setState(() => hasUnsavedChanges = true);
    }
  }

  /// 💾 Salva alterações quando há mudanças pendentes
  Future<void> saveChanges() async {
    if (!hasUnsavedChanges) {
      debugPrint('💾 saveChanges: Não há mudanças para salvar');
      return;
    }

    debugPrint('💾 saveChanges: Iniciando salvamento...');
    setState(() => isSaving = true);

    try {
      final updateData = DetailPanelHelpers.createUpdateData(
        content: contentController.text,
        mood: selectedMood,
        isFavorite: isFavorite,
      );

      debugPrint('💾 Dados para atualizar: $updateData');

      final success = await controller.updateEntry(entry, updateData);

      if (success) {
        setState(() {
          hasUnsavedChanges = false;
          isSaving = false;
          originalContent = contentController.text.trim();
        });
        onUpdated?.call();
        debugPrint(
          '✅ Alterações salvas com sucesso. Novo conteúdo original: "$originalContent"',
        );
      } else {
        setState(() => isSaving = false);
        debugPrint('❌ Falha ao salvar alterações');
        _showErrorMessage('❌ Erro ao salvar alterações');
      }
    } catch (e) {
      setState(() => isSaving = false);
      debugPrint('❌ Erro ao salvar entrada: $e');
      _showErrorMessage('❌ Erro ao salvar alterações');
    }
  }

  /// 🎭 Altera o mood e salva imediatamente
  void changeMood(String newMood) {
    setState(() {
      selectedMood = newMood;
      hasUnsavedChanges = true;
    });
    saveChanges();
  }

  /// ⭐ Alterna favorito e salva imediatamente
  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      hasUnsavedChanges = true;
    });
    saveChanges();
  }

  /// 🗑️ Confirma e executa exclusão da entrada
  Future<void> confirmDelete() async {
    final shouldDelete = await _showDeleteConfirmation();

    if (shouldDelete == true) {
      try {
        final success = await controller.deleteEntry(entry.id);
        if (success) {
          onDeleted?.call();
          _closePanel();
          _showSuccessMessage('🗑️ Entrada excluída');
        } else {
          _showErrorMessage('❌ Erro ao excluir entrada');
        }
      } catch (e) {
        debugPrint('❌ Erro ao excluir entrada: $e');
        _showErrorMessage('❌ Erro ao excluir entrada');
      }
    }
  }

  /// ❓ Mostra diálogo de confirmação de exclusão
  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Excluir entrada'),
            content: const Text(
              'Tem certeza que deseja excluir esta entrada do diário?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  /// ❌ Mostra mensagem de erro
  void _showErrorMessage(String message) {
    DetailPanelHelpers.showSnackBar(context, message, isError: true);
  }

  /// ✅ Mostra mensagem de sucesso
  void _showSuccessMessage(String message) {
    DetailPanelHelpers.showSnackBar(context, message, isError: false);
  }

  /// 🚪 Fecha o painel (deve ser implementado pela classe filha)
  void _closePanel() {
    // Implementação específica para mobile/desktop
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}
