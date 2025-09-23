import 'package:flutter/material.dart';
import '../../../tokens/module_pos.dart';
import 'modular_card_1.dart';
import 'card_style.dart';
import 'modules/mood_module.dart';
import 'modules/diary_content_module.dart';
import 'modules/date_module.dart';

/// ModularDiaryCard - Card modular para entradas de diário
class ModularDiaryCard extends StatelessWidget {
  final String? title;
  final String content;
  final String mood;
  final DateTime dateTime;
  final bool isFavorite;
  final bool showFavorite;
  final VoidCallback? onTap;
  final Function(bool)? onToggleFavorite;
  final bool isSelected;

  const ModularDiaryCard({
    super.key,
    this.title,
    required this.content,
    required this.mood,
    required this.dateTime,
    this.isFavorite = false,
    this.showFavorite = true,
    this.onTap,
    this.onToggleFavorite,
    this.isSelected = false,
  });

  const ModularDiaryCard.withoutFavorite({
    super.key,
    this.title,
    required this.content,
    required this.mood,
    required this.dateTime,
    this.onTap,
    this.isSelected = false,
  }) : isFavorite = false,
       showFavorite = false,
       onToggleFavorite = null;

  @override
  Widget build(BuildContext context) {
    // 🎯 Estilo específico para diary cards - bem definido!
    final diaryStyle = CardStyles.diary.copyWith(
      elevation: 2.0, // Sombra específica para diary
      borderWidth: 1.0, // Borda sempre presente
      borderSelected: const Color.fromARGB(
        255,
        241,
        227,
        205,
      ), // Borda laranja quando selecionado
      borderUnselected: Colors.grey.shade200, // Borda cinza padrão
      padding: EdgeInsets.all(12), // Padding específico diary
      margin: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ), // Margin específica
      bgSelected: Color(0xFFFFF3E0), // Fundo laranja claro quando selecionado
      bgUnselected: Colors.white, // Fundo branco padrão
    );

    return ModularBaseCard(
      title: null, // Não usar título padrão
      content: null, // Não usar conteúdo padrão
      onTap: onTap,
      isSelected: isSelected,
      style: diaryStyle, // 🎯 Usa estilo específico de diary card
      modules: [
        // 😊 Emoji com cor de fundo (posição leading)
        MoodModuleFactory.withAutoColor(
          mood: mood,
          position: ModulePos.leading,
          size: 32,
          fontSize: 18,
        ),

        // 📝 Conteúdo do diary (posição content) - ALINHADO AO TOPO
        DiaryContentModuleFactory.content(
          title: title,
          content: content,
          maxLines: 2,
          padding: const EdgeInsets.only(top: 2.0), // SÓ TOPO
        ),

        // 🕐 Hora (posição footer) - ALINHADO AO BOTTOM
        DateModuleFactory.footer(
          date: dateTime,
          displayMode: DateDisplayMode.time,
          textColor: Colors.grey.shade600,
          textStyle: const TextStyle(fontSize: 12, height: 1.0),
        ),
      ],
    );
  }
}
