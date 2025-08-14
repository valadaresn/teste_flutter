// lib/widgets/generic_selector_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Um widget genérico para listas reativas com Provider+Selector.
///
/// C: seu ChangeNotifier que expõe `List<T> entries`
/// T: seu modelo de item, que tem um identificador único
class GenericSelectorList<C extends ChangeNotifier, T> extends StatelessWidget {
  /// Função para extrair a lista completa do controller
  final List<T> Function(C controller) listSelector;

  /// Função para extrair um item pelo seu ID
  final T? Function(C controller, String id) itemById;

  /// Função para extrair o ID de cada item
  final String Function(T item) idExtractor;

  /// Constrói o widget de cada item
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// espaçamento entre itens
  final EdgeInsetsGeometry padding;
  final double spacing;

  const GenericSelectorList({
    Key? key,
    required this.listSelector,
    required this.itemById,
    required this.idExtractor,
    required this.itemBuilder,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<C>(
      builder: (context, controller, child) {
        final items = listSelector(controller);

        if (items.isEmpty) {
          return Center(child: Text('Nenhum item encontrado'));
        }

        return ListView.builder(
          padding: padding,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final id = idExtractor(items[index]);
            return Padding(
              padding: EdgeInsets.only(bottom: spacing),
              // Cada card só rebuilda quando muda THIS ID
              child: Selector<C, T?>(
                selector: (_, ctrl) => itemById(ctrl, id),
                shouldRebuild: (prev, next) => prev != next,
                builder: (context, entry, _) {
                  if (entry == null) return const SizedBox.shrink();
                  return itemBuilder(context, entry);
                },
              ),
            );
          },
        );
      },
    );
  }
}
