// import 'package:flutter/material.dart';
// import 'modular_card.dart';

// /// 📝 **DiaryCard** - Card simplificado para entradas de diário
// ///
// /// **FILOSOFIA:** Simplicidade total usando ModularCard com widgets diretos
// /// **SEM MÓDULOS:** Toda lógica inline, apenas widgets simples nos slots
// /// **RESPONSABILIDADE:** Só renderização, estado fica no consumidor
// class DiaryCard extends StatelessWidget {
//   const DiaryCard({
//     super.key,
//     this.title,
//     required this.content,
//     required this.mood,
//     required this.dateTime,
//     this.isFavorite = false,
//     this.showFavorite = true,
//     this.onTap,
//     this.onToggleFavorite,
//     this.isSelected = false,
//     this.maxLines = 2,
//   });

//   /// Título opcional da entrada
//   final String? title;
  
//   /// Conteúdo da entrada do diário
//   final String content;
  
//   /// Emoji do humor (mood)
//   final String mood;
  
//   /// Data/hora da entrada
//   final DateTime dateTime;
  
//   /// Se está marcado como favorito
//   final bool isFavorite;
  
//   /// Se deve mostrar o ícone de favorito
//   final bool showFavorite;
  
//   /// Callback para tap no card inteiro
//   final VoidCallback? onTap;
  
//   /// Callback para toggle do favorito
//   final Function(bool)? onToggleFavorite;
  
//   /// Se o card está selecionado
//   final bool isSelected;
  
//   /// Número máximo de linhas para o conteúdo
//   final int maxLines;

//   @override
//   Widget build(BuildContext context) {
//     return ModularCard(
//       onTap: onTap,
//       backgroundColor: isSelected 
//           ? const Color(0xFFFFF3E0)  // Fundo laranja claro quando selecionado
//           : Colors.white,
      
//       // 😊 Emoji com fundo colorido (lado esquerdo)
//       leading: Container(
//         width: 32,
//         height: 32,
//         decoration: BoxDecoration(
//           color: _getMoodColor(mood),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Center(
//           child: Text(
//             mood.isEmpty ? '📝' : mood,
//             style: const TextStyle(fontSize: 18),
//           ),
//         ),
//       ),
      
//       // 📝 Conteúdo principal (título tem prioridade se existir)
//       content: Text(
//         title?.isNotEmpty == true ? title! : content,
//         maxLines: maxLines,
//         overflow: TextOverflow.ellipsis,
//         style: TextStyle(
//           fontSize: title?.isNotEmpty == true ? 16 : 14,
//           fontWeight: title?.isNotEmpty == true ? FontWeight.w600 : FontWeight.normal,
//           height: 1.3,
//         ),
//       ),
      
//       // 🕐 Rodapé com hora e favorito
//       footer: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Hora
//           TimeLabel(
//             dateTime: dateTime,
//             format: 'HH:mm',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//               height: 1.0,
//             ),
//           ),
          
//           // Favorito (condicional)
//           if (showFavorite || isFavorite)
//             FavoriteIcon(
//               isFavorite: isFavorite,
//               onToggle: onToggleFavorite,
//               size: 16,
//             ),
//         ],
//       ),
//     );
//   }

//   /// 🎨 Retorna cor de fundo baseada no emoji do mood
//   Color _getMoodColor(String mood) {
//     switch (mood) {
//       // Feliz/Positivo
//       case '😊': 
//       case '😄': 
//       case '🙂': 
//       case '😁': 
//       case '🥰': 
//         return Colors.green.withOpacity(0.15);
      
//       // Triste/Negativo  
//       case '😢': 
//       case '😭': 
//       case '😞': 
//       case '😔': 
//       case '🥺': 
//         return Colors.blue.withOpacity(0.15);
      
//       // Raiva/Irritado
//       case '😡': 
//       case '😠': 
//       case '🤬': 
//       case '😤': 
//         return Colors.red.withOpacity(0.15);
      
//       // Cansado/Sonolento
//       case '😴': 
//       case '😪': 
//       case '🥱': 
//       case '😑': 
//         return Colors.purple.withOpacity(0.15);
      
//       // Ansioso/Preocupado
//       case '😰': 
//       case '😥': 
//       case '😓': 
//       case '😵': 
//         return Colors.orange.withOpacity(0.15);
      
//       // Surpreso/Animado
//       case '😲': 
//       case '🤩': 
//       case '😍': 
//       case '🥳': 
//         return Colors.yellow.withOpacity(0.15);
      
//       // Neutro/Padrão
//       default: 
//         return Colors.grey.withOpacity(0.15);
//     }
//   }
// }

// /// 🏭 **Factory para casos específicos** (opcional)
// class DiaryCardFactory {
//   /// Card sem favorito
//   static DiaryCard withoutFavorite({
//     Key? key,
//     String? title,
//     required String content,
//     required String mood,
//     required DateTime dateTime,
//     VoidCallback? onTap,
//     bool isSelected = false,
//     int maxLines = 2,
//   }) {
//     return DiaryCard(
//       key: key,
//       title: title,
//       content: content,
//       mood: mood,
//       dateTime: dateTime,
//       showFavorite: false,
//       onTap: onTap,
//       isSelected: isSelected,
//       maxLines: maxLines,
//     );
//   }

//   /// Card compacto (1 linha)
//   static DiaryCard compact({
//     Key? key,
//     String? title,
//     required String content,
//     required String mood,
//     required DateTime dateTime,
//     bool isFavorite = false,
//     bool showFavorite = true,
//     VoidCallback? onTap,
//     Function(bool)? onToggleFavorite,
//     bool isSelected = false,
//   }) {
//     return DiaryCard(
//       key: key,
//       title: title,
//       content: content,
//       mood: mood,
//       dateTime: dateTime,
//       isFavorite: isFavorite,
//       showFavorite: showFavorite,
//       onTap: onTap,
//       onToggleFavorite: onToggleFavorite,
//       isSelected: isSelected,
//       maxLines: 1,
//     );
//   }
// }