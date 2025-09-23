import 'package:flutter/material.dart';
import '../../../tokens/module_pos.dart';
import '../../../tokens/spacing.dart';
import '../../../utils/widget_mods.dart';
import 'modules/simple_left_border_module.dart';
import 'card_style.dart';

/// 🧩 Módulo base - interface para todos os módulos do card
abstract class CardModule {
  Widget build(BuildContext context, Map<String, dynamic> data);
  String get moduleId;
  ModulePos get position; // Agora type-safe com enum
}

/// 🎯 Módulo com posição definida - classe base para implementação
abstract class PositionableModule extends CardModule {
  @override
  final ModulePos position;
  PositionableModule(this.position);
}

/// 📱 ModularBaseCard - Card base modular com estrutura flexível.
///
/// Este card permite composição através de módulos que podem ser posicionados
/// em diferentes áreas: leading, header-trailing, content e footer.
/// Suporta também borda esquerda especial através do LeftBorderModule.
/// O objetivo é manter o `build` **linear** (como um índice), evitar
/// aninhamento profundo e concentrar o VISUAL no `CardStyle`.
class ModularBaseCard extends StatelessWidget {
  // === CONTEÚDO BÁSICO ===
  final String? title; // Título principal do card
  final String? subtitle; // Subtítulo (aparece abaixo do título)
  final String? content; // Texto de conteúdo principal
  final Widget? customContent; // Widget customizado para conteúdo complexo

  // === SISTEMA MODULAR ===
  final List<CardModule> modules; // Lista de módulos a serem renderizados
  final Map<String, dynamic> data; // Dados compartilhados entre módulos

  // === COMPORTAMENTO ===
  final bool isSelected; // Estado visual (selecionado ou não)
  final bool
  useIntrinsicHeight; // Igualar altura do leading com conteúdo (custo maior)
  final VoidCallback? onTap; // Callback para toque no card

  // === ESTILO ===
  final CardStyle style; // ÚNICO ponto de customização visual

  const ModularBaseCard({
    super.key,
    this.title,
    this.subtitle,
    this.content,
    this.customContent,
    this.modules = const [],
    this.data = const {},
    this.isSelected = false,
    this.useIntrinsicHeight = true,
    this.onTap,
    this.style = const CardStyle(),
  });

  @override
  Widget build(BuildContext context) {
    // Resolve estilo (tema + tokens + overrides)
    final s = style.resolve(context, isSelected: isSelected);

    // === PRÉ-PROCESSAMENTO - Otimização crucial para performance ===
    // Agrupa módulos por posição em uma única passada, evitando múltiplas iterações
    final leftBorder = _leftBorderModuleOrNull(modules);
    final grouped = _groupModulesExcludingLeft(modules, context);
    final leading = grouped[ModulePos.leading] ?? const <Widget>[];
    final headerTrailing =
        grouped[ModulePos.headerTrailing] ?? const <Widget>[];
    final contentMods = grouped[ModulePos.content] ?? const <Widget>[];
    final footer = grouped[ModulePos.footer] ?? const <Widget>[];

    // === ESTRUTURA PRINCIPAL - Build como índice visual completo ===
    final contentTree = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // === SEÇÃO LEADING ===
            // Módulos do lado esquerdo (ícones, avatars, indicadores)
            ...leading,
            if (leading.isNotEmpty) const SizedBox(width: Spacing.lg),

            // === SEÇÃO PRINCIPAL ===
            // Conteúdo principal expansível
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // === HEADER ===
                // Título + módulos header-trailing (badges, botões)
                if ((title != null && title!.isNotEmpty) ||
                    headerTrailing.isNotEmpty)
                  _headerRow(context, headerTrailing),

                // === SUBTITLE ===
                // Texto secundário abaixo do título
                if (subtitle != null) ...[
                  const SizedBox(height: Spacing.xs),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],

                // === CONTENT TEXT ===
                // Texto principal (overflow visível por padrão — módulos controlam seu próprio overflow)
                if (content != null) ...[
                  const SizedBox(height: Spacing.sm),
                  Text(
                    content!,
                    style: const TextStyle(fontSize: 14),
                    maxLines: null,
                    overflow: TextOverflow.visible,
                  ),
                ],

                // === CONTENT MODULES ===
                // Módulos da área de conteúdo (gráficos, imagens, etc.)
                if (contentMods.isNotEmpty) ...[
                  const SizedBox(height: Spacing.sm),
                  ...contentMods,
                ],

                // === CUSTOM CONTENT ===
                // Widget personalizado para casos complexos
                if (customContent != null) ...[
                  const SizedBox(height: Spacing.sm),
                  customContent!,
                ],

                // === FOOTER ===
                // Módulos do rodapé (ações, metadata, timestamps)
                if (footer.isNotEmpty) ...[
                  const SizedBox(height: Spacing.sm),
                  ...footer,
                ],
              ],
            ).expanded(), // Usa sua extensão para Expanded
          ],
        )
        .when(useIntrinsicHeight, (w) => IntrinsicHeight(child: w))
        .padding(s.padding); // Usa sua extensão para Padding

    // Borda externa + clipping. Sombra vem do Card.elevation (sem duplicar)
    final decorated = Container(
      decoration: BoxDecoration(
        borderRadius: s.radius,
        border: Border.all(color: s.borderColor, width: s.borderWidth),
      ),
      child: _wrapLeftBorder(
        br: s.radius,
        left: leftBorder,
        child: contentTree,
      ),
    ).clipRRect(s.radius);

    // Acessibilidade básica
    final semantics = Semantics(
      container: true,
      button: onTap != null,
      header: false,
      label: title,
      child: decorated.tappable(onTap),
    );

    return Container(
      margin: s.margin,
      child: Card(
        color: s.bg,
        elevation: s.elevation,
        shape: RoundedRectangleBorder(borderRadius: s.radius),
        child: semantics,
      ),
    );
  }

  /// === HELPER: HEADER ROW ===
  /// Constrói a linha do cabeçalho com título e módulos trailing
  Widget _headerRow(BuildContext c, List<Widget> headerTrailing) {
    final titleWidget =
        title == null
            ? const SizedBox.shrink()
            : Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis, // Evita overflow no título
            ).expanded();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        titleWidget,
        Flexible(
          child: OverflowBar(
            overflowSpacing: Spacing.sm,
            spacing: Spacing.sm,
            alignment: MainAxisAlignment.end,
            children: headerTrailing,
          ),
        ),
      ],
    );
  }

  /// === HELPER: LEFT BORDER ===
  /// Aplica decoração de borda esquerda se módulo presente
  /// IMPORTANTE: Fica dentro do clipping para respeitar border radius
  Widget _wrapLeftBorder({
    required Widget child,
    required BorderRadius br,
    LeftBorderModule? left,
  }) {
    if (left == null) return child;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: left.color, width: left.width)),
      ),
      child: child,
    );
  }

  /// === HELPER: BUSCA MÓDULO DE BORDA ESQUERDA ===
  /// Encontra o primeiro módulo de borda esquerda (deve ser único)
  static LeftBorderModule? _leftBorderModuleOrNull(List<CardModule> modules) {
    for (final m in modules) {
      if (m is LeftBorderModule) return m as LeftBorderModule;
    }
    return null;
  }

  /// === HELPER: AGRUPAMENTO DE MÓDULOS ===
  /// Otimização crucial: agrupa módulos por posição em uma única passada
  /// Evita múltiplas iterações na lista durante o build
  Map<ModulePos, List<Widget>> _groupModulesExcludingLeft(
    List<CardModule> modules,
    BuildContext context,
  ) {
    final map = <ModulePos, List<Widget>>{};
    for (final m in modules) {
      if (m is LeftBorderModule)
        continue; // Borda esquerda é tratada separadamente
      final wrapped = _wrapByPosition(m, context);
      (map[m.position] ??= <Widget>[]).add(wrapped);
    }
    return map;
  }

  /// === HELPER: WRAPPER POR POSIÇÃO ===
  /// Aplica padding específico baseado na posição do módulo
  /// Cada posição tem seu padrão de espaçamento
  Widget _wrapByPosition(CardModule m, BuildContext context) {
    final widget = m.build(context, data);
    switch (m.position) {
      case ModulePos.footer:
        // Footer modules: padding bottom para separar do conteúdo
        return widget.padOnly(b: Spacing.xs);
      case ModulePos.content:
        // Content modules: padding top para separar do texto
        return widget.padOnly(t: Spacing.sm);
      case ModulePos.leading:
      case ModulePos.headerTrailing:
        // Leading/header modules: sem padding implícito (controlado manualmente)
        return widget;
    }
  }
}
