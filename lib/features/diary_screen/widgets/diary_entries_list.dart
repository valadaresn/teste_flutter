import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/generic_selector_list.dart';
import '../../../models/diary_entry.dart';
import '../diary_controller.dart' as NewDiary;
import '../../../widgets/common/cards/diary_card.dart';

/// 📝 Lista de entradas de diário usando GenericSelectorList
///
/// Seguindo instruções críticas do docs/instrucoes_lista.txt:
/// - Usar GenericSelectorList para evitar piscar da tela
/// - Cada card só rebuilda quando muda seu item específico
class DiaryEntriesList extends StatelessWidget {
  final VoidCallback? onAddEntry;
  final Function(DiaryEntry)? onEditEntry;
  final Function(String)? onDeleteEntry;
  final Function(DiaryEntry, bool)? onToggleFavorite;

  const DiaryEntriesList({
    Key? key,
    this.onAddEntry,
    this.onEditEntry,
    this.onDeleteEntry,
    this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NewDiary.DiaryController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar entradas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.red.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Reconectar o stream
                    // O controller já fará isso automaticamente
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        // Usar GenericSelectorList para renderização otimizada
        return GenericSelectorList<NewDiary.DiaryController, DiaryEntry>(
          // Função para extrair a lista filtrada do controller
          listSelector: (controller) => controller.getFilteredEntries(),

          // Função para extrair um item pelo seu ID
          itemById: (controller, id) => controller.getDiaryEntryById(id),

          // Função para extrair o ID de cada item
          idExtractor: (entry) => entry.id,

          // Constrói o widget de cada item
          itemBuilder: (context, entry) {
            return Consumer<NewDiary.DiaryController>(
              builder: (context, controller, child) {
                return DiaryCard(
                  title: entry.title,
                  content: entry.content,
                  mood: entry.mood,
                  dateTime: entry.dateTime,
                  isFavorite: entry.isFavorite,
                  showFavorite: true,
                  isSelected: controller.selectedDiaryId == entry.id,
                  onTap: () {
                    controller.selectDiaryEntry(entry.id);
                    onEditEntry?.call(entry);
                  },
                  onToggleFavorite:
                      (isFavorite) => onToggleFavorite?.call(entry, isFavorite),
                );
              },
            );
          },

          // Configurações de layout
          padding: const EdgeInsets.all(16),
          spacing: 12.0,
        );
      },
    );
  }
}
