import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// ⭐ **FavoriteModule** - Módulo de favorito com ícone interativo
///
/// **FUNCIONALIDADE:**
/// - Ícone de favorito (coração ou estrela) com animação
/// - Estados ativo/inativo com cores diferentes
/// - Callback para toggle de estado
/// - Opção de mostrar apenas quando ativo
/// - Animação suave de transição
///
/// **USADO POR:**
/// - DiaryCard (posição trailing) - para marcar entradas como favoritas
///
/// **ÍCONES DISPONÍVEIS:**
/// - `heart`: Coração (padrão para diário)
/// - `star`: Estrela (padrão para tasks)
/// - `bookmark`: Marcador
///
/// **POSIÇÕES COMUNS:**
/// - `trailing`: Lado direito do card (padrão)
/// - `header-trailing`: Direita do cabeçalho
///
/// **EXEMPLO DE USO:**
/// ```dart
/// FavoriteModuleFactory.heart(
///   isFavorite: entry.isFavorite,
///   onToggle: (value) => toggleFavorite(value),
///   showOnlyWhenActive: false,
/// )
/// ```
class FavoriteModule extends PositionableModule {
  final bool isFavorite;
  final Function(bool)? onToggle;
  final FavoriteIcon iconType;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final bool showOnlyWhenActive;
  final Duration animationDuration;

  FavoriteModule({
    required String position,
    required this.isFavorite,
    this.onToggle,
    this.iconType = FavoriteIcon.heart,
    this.activeColor,
    this.inactiveColor,
    this.size = 18,
    this.showOnlyWhenActive = false,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(position);

  @override
  String get moduleId => 'favorite_${isFavorite ? 'active' : 'inactive'}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    // Se showOnlyWhenActive for true e não estiver favorito, não mostra nada
    if (showOnlyWhenActive && !isFavorite) {
      return const SizedBox.shrink();
    }

    final effectiveActiveColor = activeColor ?? _getDefaultActiveColor();
    final effectiveInactiveColor = inactiveColor ?? Colors.grey.shade400;

    final activeIcon = _getActiveIcon();
    final inactiveIcon = _getInactiveIcon();

    return GestureDetector(
      onTap: onToggle != null ? () => onToggle!(!isFavorite) : null,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: AnimatedSwitcher(
          duration: animationDuration,
          child: Icon(
            isFavorite ? activeIcon : inactiveIcon,
            color: isFavorite ? effectiveActiveColor : effectiveInactiveColor,
            size: size,
            key: ValueKey(isFavorite),
          ),
        ),
      ),
    );
  }

  Color _getDefaultActiveColor() {
    switch (iconType) {
      case FavoriteIcon.heart:
        return Colors.red.shade600;
      case FavoriteIcon.star:
        return Colors.amber.shade600;
      case FavoriteIcon.bookmark:
        return Colors.blue.shade600;
    }
  }

  IconData _getActiveIcon() {
    switch (iconType) {
      case FavoriteIcon.heart:
        return Icons.favorite;
      case FavoriteIcon.star:
        return Icons.star;
      case FavoriteIcon.bookmark:
        return Icons.bookmark;
    }
  }

  IconData _getInactiveIcon() {
    switch (iconType) {
      case FavoriteIcon.heart:
        return Icons.favorite_border;
      case FavoriteIcon.star:
        return Icons.star_border;
      case FavoriteIcon.bookmark:
        return Icons.bookmark_border;
    }
  }
}

/// 💕 Tipos de ícone para favoritos
enum FavoriteIcon {
  heart, // Coração (padrão para diário)
  star, // Estrela (padrão para tasks)
  bookmark, // Marcador (padrão para notas)
}

/// 🎯 Factory para criar módulos de favorito
class FavoriteModuleFactory {
  /// Favorito com ícone de coração (ideal para diário)
  static FavoriteModule heart({
    required bool isFavorite,
    Function(bool)? onToggle,
    String position = 'trailing',
    Color? activeColor,
    Color? inactiveColor,
    double size = 18,
    bool showOnlyWhenActive = false,
  }) {
    return FavoriteModule(
      position: position,
      isFavorite: isFavorite,
      onToggle: onToggle,
      iconType: FavoriteIcon.heart,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      size: size,
      showOnlyWhenActive: showOnlyWhenActive,
    );
  }

  /// Favorito com ícone de estrela (ideal para tasks)
  static FavoriteModule star({
    required bool isFavorite,
    Function(bool)? onToggle,
    String position = 'trailing',
    Color? activeColor,
    Color? inactiveColor,
    double size = 18,
    bool showOnlyWhenActive = true,
  }) {
    return FavoriteModule(
      position: position,
      isFavorite: isFavorite,
      onToggle: onToggle,
      iconType: FavoriteIcon.star,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      size: size,
      showOnlyWhenActive: showOnlyWhenActive,
    );
  }

  /// Favorito com ícone de bookmark (ideal para notas)
  static FavoriteModule bookmark({
    required bool isFavorite,
    Function(bool)? onToggle,
    String position = 'trailing',
    Color? activeColor,
    Color? inactiveColor,
    double size = 18,
    bool showOnlyWhenActive = false,
  }) {
    return FavoriteModule(
      position: position,
      isFavorite: isFavorite,
      onToggle: onToggle,
      iconType: FavoriteIcon.bookmark,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      size: size,
      showOnlyWhenActive: showOnlyWhenActive,
    );
  }

  /// Favorito na posição trailing (padrão)
  static FavoriteModule trailing({
    required bool isFavorite,
    Function(bool)? onToggle,
    FavoriteIcon iconType = FavoriteIcon.heart,
    Color? activeColor,
    Color? inactiveColor,
    double size = 18,
    bool showOnlyWhenActive = false,
  }) {
    return FavoriteModule(
      position: 'trailing',
      isFavorite: isFavorite,
      onToggle: onToggle,
      iconType: iconType,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      size: size,
      showOnlyWhenActive: showOnlyWhenActive,
    );
  }

  /// Favorito na posição header-trailing (compacto)
  static FavoriteModule headerTrailing({
    required bool isFavorite,
    Function(bool)? onToggle,
    FavoriteIcon iconType = FavoriteIcon.star,
    Color? activeColor,
    Color? inactiveColor,
    double size = 16,
    bool showOnlyWhenActive = true,
  }) {
    return FavoriteModule(
      position: 'header-trailing',
      isFavorite: isFavorite,
      onToggle: onToggle,
      iconType: iconType,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      size: size,
      showOnlyWhenActive: showOnlyWhenActive,
    );
  }
}
