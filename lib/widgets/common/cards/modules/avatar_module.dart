import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// 👤 **AvatarModule** - Módulo de avatar/usuário para cards modulares
///
/// **FUNCIONALIDADE:**
/// - Avatar com imagem, iniciais ou ícone
/// - Formas diferentes (circle, rounded, square)
/// - Badge para notificações ou status
/// - Border customizável
/// - Callback para tap
///
/// **STATUS DE USO:**
/// ⚠️ SUBUTILIZADO - Usado apenas em CleanCardExamples
///
/// **POTENCIAL DE USO:**
/// - TaskCard (trailing) - para mostrar responsável pela tarefa
/// - NoteCard (leading) - para mostrar autor da nota
/// - DiaryCard (header-trailing) - para mostrar perfil do usuário
/// - HabitCard (trailing) - para mostrar parceiro de accountability
///
/// **POSIÇÕES COMUNS:**
/// - `leading`: Lado esquerdo do card (autor/responsável)
/// - `trailing`: Lado direito do card (participantes)
/// - `header-trailing`: Direita do cabeçalho (modo compacto)
///
/// **EXEMPLO DE USO:**
/// ```dart
/// AvatarModuleFactory.leading(
///   imageUrl: user.profileImage,
///   initials: user.initials,
///   radius: 20,
///   badge: AvatarBadge.online(),
///   onTap: () => showUserProfile(user),
/// )
/// ```

/// 👤 Módulo de Avatar para cards
class AvatarModule extends PositionableModule {
  final String? imageUrl;
  final String? initials;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double radius;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final Widget? badge; // Para badges/indicadores
  final AvatarShape shape;

  AvatarModule({
    required String position,
    this.imageUrl,
    this.initials,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.radius = 20.0,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
    this.badge,
    this.shape = AvatarShape.circle,
  }) : super(position);

  @override
  String get moduleId => 'avatar_${imageUrl ?? initials ?? icon.toString()}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.primary;
    final effectiveForegroundColor =
        foregroundColor ?? theme.colorScheme.onPrimary;
    final effectiveBorderColor = borderColor ?? theme.colorScheme.outline;

    Widget avatar = _buildAvatar(
      context,
      effectiveBackgroundColor,
      effectiveForegroundColor,
    );

    // Adicionar borda se necessário
    if (showBorder) {
      avatar = Container(
        decoration: BoxDecoration(
          shape:
              shape == AvatarShape.circle
                  ? BoxShape.circle
                  : BoxShape.rectangle,
          borderRadius:
              shape == AvatarShape.rounded
                  ? BorderRadius.circular(radius * 0.3)
                  : null,
          border: Border.all(color: effectiveBorderColor, width: borderWidth),
        ),
        child: Padding(padding: EdgeInsets.all(borderWidth), child: avatar),
      );
    }

    // Adicionar badge se necessário
    if (badge != null) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [avatar, Positioned(right: -4, top: -4, child: badge!)],
      );
    }

    // Adicionar onTap se necessário
    if (onTap != null) {
      avatar = InkWell(
        onTap: onTap,
        borderRadius:
            shape == AvatarShape.circle
                ? BorderRadius.circular(radius)
                : BorderRadius.circular(radius * 0.3),
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildAvatar(
    BuildContext context,
    Color backgroundColor,
    Color foregroundColor,
  ) {
    Widget child;

    // Determinar o conteúdo do avatar
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      child = _buildImageAvatar();
    } else if (initials != null && initials!.isNotEmpty) {
      child = _buildInitialsAvatar(foregroundColor);
    } else if (icon != null) {
      child = _buildIconAvatar(foregroundColor);
    } else {
      child = _buildDefaultAvatar(foregroundColor);
    }

    // Aplicar formato
    switch (shape) {
      case AvatarShape.circle:
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: child,
        );

      case AvatarShape.rounded:
        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radius * 0.3),
          ),
          child: Center(child: child),
        );

      case AvatarShape.square:
        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(color: backgroundColor),
          child: Center(child: child),
        );
    }
  }

  Widget _buildImageAvatar() {
    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar(Colors.white);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialsAvatar(Color foregroundColor) {
    return Text(
      initials!.toUpperCase(),
      style: TextStyle(
        color: foregroundColor,
        fontSize: radius * 0.6,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildIconAvatar(Color foregroundColor) {
    return Icon(icon, color: foregroundColor, size: radius * 0.8);
  }

  Widget _buildDefaultAvatar(Color foregroundColor) {
    return Icon(Icons.person, color: foregroundColor, size: radius * 0.8);
  }
}

/// 🎨 Formas do avatar
enum AvatarShape {
  circle, // Circular
  rounded, // Quadrado com bordas arredondadas
  square, // Quadrado
}

/// 🔔 Badge para avatar
class AvatarBadge extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double size;

  const AvatarBadge({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.error,
        shape: BoxShape.circle,
        border:
            borderColor != null
                ? Border.all(color: borderColor!, width: 1.5)
                : Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1.5,
                ),
      ),
      child: Center(child: child),
    );
  }

  /// Badge com número
  factory AvatarBadge.count(
    int count, {
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    double size = 16.0,
  }) {
    return AvatarBadge(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      size: size,
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Badge com ícone
  factory AvatarBadge.icon(
    IconData icon, {
    Color? backgroundColor,
    Color? iconColor,
    Color? borderColor,
    double size = 16.0,
  }) {
    return AvatarBadge(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      size: size,
      child: Icon(icon, color: iconColor ?? Colors.white, size: size * 0.6),
    );
  }

  /// Badge de status online
  factory AvatarBadge.online({Color? borderColor, double size = 12.0}) {
    return AvatarBadge(
      backgroundColor: Colors.green,
      borderColor: borderColor,
      size: size,
      child: const SizedBox(),
    );
  }

  /// Badge de status offline
  factory AvatarBadge.offline({Color? borderColor, double size = 12.0}) {
    return AvatarBadge(
      backgroundColor: Colors.grey,
      borderColor: borderColor,
      size: size,
      child: const SizedBox(),
    );
  }
}

/// 🎯 Factory para criar avatars em diferentes posições
class AvatarModuleFactory {
  /// Avatar na posição leading (esquerda)
  static AvatarModule leading({
    String? imageUrl,
    String? initials,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    double radius = 20.0,
    VoidCallback? onTap,
    bool showBorder = false,
    Color? borderColor,
    Widget? badge,
    AvatarShape shape = AvatarShape.circle,
  }) {
    return AvatarModule(
      position: 'leading',
      imageUrl: imageUrl,
      initials: initials,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      radius: radius,
      onTap: onTap,
      showBorder: showBorder,
      borderColor: borderColor,
      badge: badge,
      shape: shape,
    );
  }

  /// Avatar na posição trailing (direita)
  static AvatarModule trailing({
    String? imageUrl,
    String? initials,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    double radius = 16.0,
    VoidCallback? onTap,
    bool showBorder = false,
    Color? borderColor,
    Widget? badge,
    AvatarShape shape = AvatarShape.circle,
  }) {
    return AvatarModule(
      position: 'trailing',
      imageUrl: imageUrl,
      initials: initials,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      radius: radius,
      onTap: onTap,
      showBorder: showBorder,
      borderColor: borderColor,
      badge: badge,
      shape: shape,
    );
  }

  /// Avatar no header-trailing (direita do header)
  static AvatarModule headerTrailing({
    String? imageUrl,
    String? initials,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    double radius = 14.0,
    VoidCallback? onTap,
    bool showBorder = false,
    Color? borderColor,
    Widget? badge,
    AvatarShape shape = AvatarShape.circle,
  }) {
    return AvatarModule(
      position: 'header-trailing',
      imageUrl: imageUrl,
      initials: initials,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      radius: radius,
      onTap: onTap,
      showBorder: showBorder,
      borderColor: borderColor,
      badge: badge,
      shape: shape,
    );
  }
}
