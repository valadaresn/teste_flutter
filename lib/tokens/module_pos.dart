/// ==============================
///  MODULE POSITIONS - Enum global para posicionamento
/// ==============================
///
/// Enum type-safe para posicionamento de módulos em componentes modulares.
/// Evita strings mágicas e erros de runtime, fornecendo IntelliSense.
///
/// **Componentes que usam:**
/// - ModularBaseCard
/// - ModularListItem (futuro)
/// - ModularDialog (futuro)
/// - ModularPanel (futuro)
///
/// **Como usar:**
/// ```dart
/// // Em módulos
/// class MoodModule extends PositionableModule {
///   MoodModule({required ModulePos position, ...}) : super(position);
/// }
///
/// // Em factories
/// MoodModuleFactory.withAutoColor(
///   mood: "😊",
///   position: ModulePos.leading, // ✅ Type-safe
/// )
///
/// // Em switches
/// switch (module.position) {
///   case ModulePos.leading:
///     return widget.padOnly(r: Spacing.lg);
///   case ModulePos.content:
///     return widget.padOnly(t: Spacing.sm);
/// }
/// ```
enum ModulePos {
  /// 📍 **Leading** - Lado esquerdo do componente
  ///
  /// **Uso típico:**
  /// - Ícones, avatars, emojis
  /// - Indicadores visuais (status, tipo)
  /// - Checkboxes, radio buttons
  ///
  /// **Exemplos:**
  /// - 😊 Emoji de humor no diary card
  /// - 👤 Avatar no user card
  /// - ✅ Checkbox no task card
  leading,

  /// 📍 **Header Trailing** - Canto superior direito
  ///
  /// **Uso típico:**
  /// - Badges, notificações
  /// - Botões de ação (editar, deletar)
  /// - Timestamps, datas
  /// - Menu de contexto
  ///
  /// **Exemplos:**
  /// - ⭐ Botão favoritar
  /// - 🕐 Data/hora
  /// - ⚙️ Menu de ações
  headerTrailing,

  /// 📍 **Content** - Área principal de conteúdo
  ///
  /// **Uso típico:**
  /// - Gráficos, charts
  /// - Imagens, mídia
  /// - Formulários inline
  /// - Conteúdo rich (markdown, html)
  ///
  /// **Exemplos:**
  /// - 📊 Gráfico de progresso
  /// - 🖼️ Galeria de imagens
  /// - 📝 Editor de texto
  content,

  /// 📍 **Footer** - Rodapé do componente
  ///
  /// **Uso típico:**
  /// - Ações principais (salvar, enviar)
  /// - Metadados (criado em, modificado em)
  /// - Tags, categorias
  /// - Links, navegação
  ///
  /// **Exemplos:**
  /// - 💾 Botões de ação
  /// - 🏷️ Tags do item
  /// - 🕐 "Criado há 2 horas"
  footer,
}
