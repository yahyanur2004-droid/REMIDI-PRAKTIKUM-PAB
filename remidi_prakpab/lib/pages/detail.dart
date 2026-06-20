import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/favorites.dart';

class DetailPage extends StatefulWidget {
  static const routeName = '/detail';
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isFav = false;
  String? _favoriteDocId;
  final _favService = FavoritesService();
  Map<String, dynamic>? _article;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _article ??=
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (_article != null) {
      _loadFavoriteStatus();
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    final articleId = _article?['id']?.toString();
    if (user == null || articleId == null || articleId.isEmpty) return;
    final docId = await _favService.getFavoriteDocId(user.uid, articleId);
    if (!mounted) return;
    setState(() {
      _isFav = docId != null;
      _favoriteDocId = docId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final article =
        _article ??
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
        {};
    final image = article['imageUrl'] ?? '';
    final title = article['title'] ?? '';
    final summary = article['summary'] ?? '';
    final newsSite = article['newsSite'] ?? '';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          IconButton(
            icon: Icon(
              _isFav ? Icons.favorite : Icons.favorite_border,
              color: _isFav ? Colors.red : null,
            ),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please login to save favorites'),
                  ),
                );
                return;
              }
              final articleId = article['id']?.toString();
              if (articleId == null || articleId.isEmpty) return;

              if (_isFav && _favoriteDocId != null) {
                await _favService.removeFavorite(_favoriteDocId!);
                setState(() {
                  _isFav = false;
                  _favoriteDocId = null;
                });
                return;
              }

              final docId = await _favService.addFavorite(
                user.uid,
                articleId,
                title,
              );
              setState(() {
                _isFav = true;
                _favoriteDocId = docId;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.network(
                  image,
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 260,
                width: double.infinity,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported,
                  size: 72,
                  color: colorScheme.onSurface.withAlpha(153),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.source, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        newsSite,
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black12,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        summary.isNotEmpty ? summary : 'No summary available.',
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (article['publishedAt'] != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: colorScheme.onSurface.withAlpha(179),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          article['publishedAt'].toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
