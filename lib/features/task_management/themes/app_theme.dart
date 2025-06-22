enum AppTheme {
  classic,
  glass,
  modern,
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
