enum AppTheme { classic, glass, modern }

// Enum para estilos do painel de lista
enum ListPanelStyle {
  compact, // Estilo atual - minimalista com animações
  decorated, // Estilo moderno - containers coloridos para emojis
}

// Enum para estilos de cards de tarefas
enum CardStyle {
  dynamic, // Estilo atual - muda com a lista selecionada
  clean, // Estilo minimalista - cor de fundo constante
}

// Constantes de design para estilos de lista
class ListStyleConstants {
  // Estilo Compacto
  static const double compactEmojiSize = 18.0;
  static const bool compactDense = true;
  static const double compactBorderWidth = 4.0;

  // Estilo Decorado
  static const double decoratedEmojiContainerSize = 40.0;
  static const bool decoratedDense = false;
  static const double decoratedContainerRadius = 8.0;
  static const double decoratedEmojiSize = 20.0;
}

extension AppThemeExtension on AppTheme {
  String get name {
    switch (this) {
      case AppTheme.classic:
        return 'Classic';
      case AppTheme.glass:
        return 'Glass';
      case AppTheme.modern:
        return 'Modern';
    }
  }

  String get description {
    switch (this) {
      case AppTheme.classic:
        return 'Cards sólidos com seleção glass';
      case AppTheme.glass:
        return 'Todos os cards com efeito vidro';
      case AppTheme.modern:
        return 'Cards elevados com sombras';
    }
  }
}
