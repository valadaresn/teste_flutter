// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/diary_entry.dart';

// class FirebaseEntriesRepository {
//   final FirebaseFirestore _firestore;
  
//   FirebaseEntriesRepository(this._firestore) {
//     // Configura cache local ilimitado do Firestore
//     _firestore.settings = const Settings(
//       persistenceEnabled: true,
//       cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
//     );
//   }

//   Stream<List<DiaryEntry>> getEntries({bool favoritesOnly = false}) {
//     var query = _firestore
//         .collection('entries')
//         .orderBy('dateTime', descending: true);

//     if (favoritesOnly) {
//       query = query.where('isFavorite', isEqualTo: true);
//     }

//     return query.snapshots().map((snapshot) => 
//       snapshot.docs.map((doc) => DiaryEntry.fromFirestore(doc)).toList()
//     );
//   }

//   Stream<List<DiaryEntry>> getEntriesByDate(String date) {
//     final dateTime = _parseDateKey(date);
    
//     return _firestore
//         .collection('entries')
//         .where('dateTime', 
//             isGreaterThanOrEqualTo: DateTime(dateTime.year, dateTime.month, dateTime.day),
//             isLessThan: DateTime(dateTime.year, dateTime.month, dateTime.day + 1))
//         .orderBy('dateTime', descending: true)
//         .snapshots()
//         .map((snapshot) => 
//           snapshot.docs.map((doc) => DiaryEntry.fromFirestore(doc)).toList()
//         );
//   }

//   Stream<List<DiaryEntry>> getEntriesByMood(String mood) {
//     return _firestore
//         .collection('entries')
//         .where('mood', isEqualTo: mood)
//         .orderBy('dateTime', descending: true)
//         .snapshots()
//         .map((snapshot) => 
//           snapshot.docs.map((doc) => DiaryEntry.fromFirestore(doc)).toList()
//         );
//   }

//   Stream<List<DiaryEntry>> getEntriesByTag(String tag) {
//     return _firestore
//         .collection('entries')
//         .where('tags', arrayContains: tag)
//         .orderBy('dateTime', descending: true)
//         .snapshots()
//         .map((snapshot) => 
//           snapshot.docs.map((doc) => DiaryEntry.fromFirestore(doc)).toList()
//         );
//   }

//   Future<void> addEntry(DiaryEntry entry) async {
//     await _firestore
//         .collection('entries')
//         .doc(entry.id)
//         .set(entry.toMap());
//   }

//   Future<void> updateEntry(DiaryEntry entry) async {
//     await _firestore
//         .collection('entries')
//         .doc(entry.id)
//         .update(entry.toMap());
//   }

//   Future<void> deleteEntry(String id) async {
//     await _firestore
//         .collection('entries')
//         .doc(id)
//         .delete();
//   }

//   Future<void> toggleFavorite(String id, bool value) async {
//     await _firestore
//         .collection('entries')
//         .doc(id)
//         .update({'isFavorite': value});
//   }

//   String formatDateKey(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final entryDate = DateTime(date.year, date.month, date.day);

//     if (entryDate == today) {
//       return 'Hoje';
//     } else if (entryDate == yesterday) {
//       return 'Ontem';
//     } else {
//       return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//     }
//   }

//   DateTime _parseDateKey(String dateKey) {
//     if (dateKey == 'Hoje') {
//       return DateTime.now();
//     } else if (dateKey == 'Ontem') {
//       return DateTime.now().subtract(const Duration(days: 1));
//     } else {
//       final parts = dateKey.split('/');
//       return DateTime(
//         int.parse(parts[2]), 
//         int.parse(parts[1]), 
//         int.parse(parts[0])
//       );
//     }
//   }
// }