import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> favoritesStream(String uid) {
    return _db
        .collection('favorites')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String> addFavorite(String uid, String articleId, String title) async {
    final ref = await _db.collection('favorites').add({
      'uid': uid,
      'articleId': articleId,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<String?> getFavoriteDocId(String uid, String articleId) async {
    final snapshot = await _db
        .collection('favorites')
        .where('uid', isEqualTo: uid)
        .where('articleId', isEqualTo: articleId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
  }

  Future<void> removeFavorite(String docId) async {
    await _db.collection('favorites').doc(docId).delete();
  }
}
