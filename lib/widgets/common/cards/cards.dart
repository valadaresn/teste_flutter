/// 📦 Cards Package - Sistema de Cards Especializados
///
/// Arquitetura hierárquica baseada em composição:
/// - BaseCard: Núcleo comum com funcionalidades universais
/// - Cards Especializados: Extensões focadas em casos específicos
///
/// Benefícios desta abordagem:
/// ✅ Separação de responsabilidades
/// ✅ Menor complexidade individual
/// ✅ Maior flexibilidade
/// ✅ Melhor manutenibilidade
/// ✅ Bundle size otimizado
/// ✅ Curva de aprendizado reduzida

// Base Card - Núcleo comum
export 'base_card.dart';

// Cards Especializados
export 'task_card.dart'; // Para tarefas com checkbox e actions
export 'note_card_1.dart'; // Para notas com tags e borda lateral
export 'habit_card.dart'; // Para hábitos com animações e timer
export 'simple_card.dart'; // Para casos básicos e protótipos

// Card genérico (mantido para compatibilidade)
export 'app_card.dart';       // Card ultra-flexível (mais complexo)

/// 🎯 Guia de Uso:
/// 
/// ### Para Tarefas:
/// ```dart
/// TaskCard(
///   title: "Comprar leite",
///   isCompleted: false,
///   onToggleComplete: () {},
///   listColor: Colors.blue,
/// )
/// ```
/// 
/// ### Para Notas:
/// ```dart
/// NoteCard(
///   title: "Reunião",
///   content: "Discutir projeto",
///   tags: ["Trabalho", "Urgente"],
///   getTagColor: (tag) => Colors.red,
/// )
/// ```
/// 
/// ### Para Hábitos:
/// ```dart
/// HabitCard(
///   title: "Exercitar",
///   emoji: "🏃",
///   color: Colors.green,
///   isDoneToday: false,
///   onToggleCompletion: () {},
/// )
/// ```
/// 
/// ### Para Casos Simples:
/// ```dart
/// SimpleCard(
///   title: "Título",
///   content: "Conteúdo básico",
///   onTap: () {},
/// )
/// ```
/// 
/// ### Para Máxima Flexibilidade:
/// ```dart
/// AppCard(
///   // 50+ propriedades disponíveis
///   showCheckbox: true,
///   actions: [...],
///   secondaryInfo: [...],
/// )
/// ```