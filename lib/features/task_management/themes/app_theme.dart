import 'package:flutter/material.dart';

// Enum para estilos de cards por tipo de visualização
enum TaskCardStyle {
  standard, // TaskItem - card detalhado
  compact, // TodayTaskItem - card minimalista
  modular, // TaskCard - card usando padrão slot simplificado
}

// Enum para tipos de visualização
enum ViewType {
  today, // Visualização Hoje
  allTasks, // Todas as Tarefas
  list, // Lista específica
}

// Enum para temas do painel lateral (sidebar)
enum SidebarTheme {
  defaultTheme, // Tema atual - colorido com emojis
  samsungNotes, // Tema Samsung Notes - minimalista e clean
}

// Enum para opções de cor de fundo
enum BackgroundColorStyle {
  listColor, // Usa a cor da lista selecionada (comportamento atual)
  samsungLight, // Cinza claro estilo Samsung Notes
  white, // Branco total
  systemTheme, // Usa a cor do tema do sistema
}

// Enum para estilo dos cards na guia Hoje
enum TodayCardStyle {
  withEmoji, // Estilo atual - mostra emoji da lista
  withColorBorder, // Novo estilo - borda colorida à esquerda
}

// Enum para cor da barra de navegação
enum NavigationBarColorStyle {
  systemTheme, // Usa a cor do tema do sistema
  samsungLight, // Cinza claro estilo Samsung Notes
  white, // Branco total
  listColor, // Usa a cor da lista selecionada
  dark, // Escuro/preto
}

// Enum para cor da sidebar
enum SidebarColorStyle {
  systemTheme, // Usa a cor do tema do sistema
  samsungLight, // Cinza claro estilo Samsung Notes
  white, // Branco total
  listColor, // Usa a cor da lista selecionada
  dark, // Escuro/preto
}

// Extensão para facilitar uso
extension TodayCardStyleExtension on TodayCardStyle {
  String get name {
    switch (this) {
      case TodayCardStyle.withEmoji:
        return 'Com Emoji';
      case TodayCardStyle.withColorBorder:
        return 'Com Borda Colorida';
    }
  }

  String get description {
    switch (this) {
      case TodayCardStyle.withEmoji:
        return 'Mostra o emoji da lista em cada tarefa';
      case TodayCardStyle.withColorBorder:
        return 'Mostra uma borda colorida à esquerda em cada tarefa';
    }
  }
}

// Extensão para NavigationBarColorStyle
extension NavigationBarColorStyleExtension on NavigationBarColorStyle {
  String get name {
    switch (this) {
      case NavigationBarColorStyle.systemTheme:
        return 'Tema do Sistema';
      case NavigationBarColorStyle.samsungLight:
        return 'Samsung Light';
      case NavigationBarColorStyle.white:
        return 'Branco';
      case NavigationBarColorStyle.listColor:
        return 'Cor da Lista';
      case NavigationBarColorStyle.dark:
        return 'Escuro';
    }
  }

  String get description {
    switch (this) {
      case NavigationBarColorStyle.systemTheme:
        return 'Segue o tema do sistema';
      case NavigationBarColorStyle.samsungLight:
        return 'Cinza claro estilo Samsung Notes';
      case NavigationBarColorStyle.white:
        return 'Fundo branco simples';
      case NavigationBarColorStyle.listColor:
        return 'Usa a cor da lista selecionada';
      case NavigationBarColorStyle.dark:
        return 'Fundo escuro/preto';
    }
  }
}

// Extensão para SidebarColorStyle
extension SidebarColorStyleExtension on SidebarColorStyle {
  String get name {
    switch (this) {
      case SidebarColorStyle.systemTheme:
        return 'Tema do Sistema';
      case SidebarColorStyle.samsungLight:
        return 'Samsung Light';
      case SidebarColorStyle.white:
        return 'Branco';
      case SidebarColorStyle.listColor:
        return 'Cor da Lista';
      case SidebarColorStyle.dark:
        return 'Escuro';
    }
  }

  String get description {
    switch (this) {
      case SidebarColorStyle.systemTheme:
        return 'Segue o tema do sistema';
      case SidebarColorStyle.samsungLight:
        return 'Cinza claro estilo Samsung Notes';
      case SidebarColorStyle.white:
        return 'Fundo branco simples';
      case SidebarColorStyle.listColor:
        return 'Usa a cor da lista selecionada';
      case SidebarColorStyle.dark:
        return 'Fundo escuro/preto';
    }
  }
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

extension SidebarThemeExtension on SidebarTheme {
  String get name {
    switch (this) {
      case SidebarTheme.defaultTheme:
        return 'Padrão';
      case SidebarTheme.samsungNotes:
        return 'Samsung Notes';
    }
  }

  String get description {
    switch (this) {
      case SidebarTheme.defaultTheme:
        return 'Painel colorido com emojis e elementos visuais';
      case SidebarTheme.samsungNotes:
        return 'Painel minimalista e clean estilo Samsung Notes';
    }
  }
}

// Extensão para nomes amigáveis de cor de fundo
extension BackgroundColorStyleExtension on BackgroundColorStyle {
  String get name {
    switch (this) {
      case BackgroundColorStyle.listColor:
        return 'Cor da Lista';
      case BackgroundColorStyle.samsungLight:
        return 'Samsung Notes';
      case BackgroundColorStyle.white:
        return 'Branco';
      case BackgroundColorStyle.systemTheme:
        return 'Tema do Sistema';
    }
  }

  String get description {
    switch (this) {
      case BackgroundColorStyle.listColor:
        return 'Usa a cor da lista selecionada como fundo';
      case BackgroundColorStyle.samsungLight:
        return 'Fundo cinza claro estilo Samsung Notes';
      case BackgroundColorStyle.white:
        return 'Fundo branco simples';
      case BackgroundColorStyle.systemTheme:
        return 'Segue o tema atual do sistema';
    }
  }
}

// Constante para a cor cinza claro do Samsung Notes (mais claro que o sidebar)
class SamsungNotesColors {
  static const Color backgroundColor = Color(
    0xFFFAFAFA,
  ); // Cinza muito claro para área principal
  static const Color sidebarColor = Color(
    0xFFF5F5F5,
  ); // Cinza um pouco mais escuro para sidebar
}
