import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  static const routeName = '/profile';
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/register', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 72,
              color: colorScheme.onSurface.withAlpha(115),
            ),
            const SizedBox(height: 16),
            Text(
              'Please log in to view your profile',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withAlpha(191),
              ),
            ),
          ],
        ),
      );
    }
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
    return StreamBuilder<DocumentSnapshot>(
      stream: doc,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snap.data?.data() as Map<String, dynamic>?;
        final name = data?['name'] ?? '';
        final email = data?['email'] ?? user.email ?? '';
        final instagram = data?['instagram'] ?? '';
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 12,
                  shadowColor: Colors.black12,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: colorScheme.primary.withAlpha(31),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.transparent,
                            child: Icon(
                              Icons.person,
                              size: 56,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          name,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withAlpha(179),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Instagram: ${instagram.isEmpty ? '-' : instagram}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 6,
                  shadowColor: Colors.black12,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.email,
                            color: colorScheme.primary,
                          ),
                          title: const Text('Email'),
                          subtitle: Text(email),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.person,
                            color: colorScheme.primary,
                          ),
                          title: const Text('Name'),
                          subtitle: Text(name),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.camera_alt,
                            color: colorScheme.primary,
                          ),
                          title: const Text('Instagram'),
                          subtitle: Text(instagram.isEmpty ? '-' : instagram),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _logout(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('Log Out'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
