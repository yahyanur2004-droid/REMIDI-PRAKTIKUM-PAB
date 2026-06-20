import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/favorites.dart';

class FavoritesPage extends StatelessWidget {
  static const routeName = '/favorites';
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Please log in to view favorites'),
          ],
        ),
      );
    }

    final favService = FavoritesService();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: favService.favoritesStream(user.uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('You have no favorite articles yet'),
              ],
            ),
          );
        }
        final docs = snap.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final d = docs[idx];
            final data = d.data();
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                leading: const Icon(Icons.favorite, color: Colors.indigo),
                title: Text(
                  data['title'] ?? 'Untitled',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: data['newsSite'] != null
                    ? Text(data['newsSite'])
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => favService.removeFavorite(d.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
