import 'package:flutter/material.dart';
import '../services/api.dart';
import 'detail.dart';
import 'favorites.dart';
import 'notifications.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const HomePage({super.key, this.onToggleTheme, this.isDarkMode = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService();
  int _index = 0;
  int _selectedCategory = 0;
  static const List<String> categories = [
    'Trending',
    'SpaceX',
    'NASA',
    'Science',
  ];
  List<dynamic> _articles = [];
  bool _loading = true;
  final Set<String> _favorites = {}; // store article ids

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      final a = await _api.fetchArticles();
      if (!mounted) return;
      setState(() {
        _articles = a;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildHome(),
      const FavoritesPage(),
      const NotificationsPage(),
      const ProfilePage(),
    ];

    final navTitles = ['Home', 'Favorites', 'Notifications', 'Profile'];

    final theme = Theme.of(context);
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(navTitles[_index]),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          ),
        ],
      ),
      body: tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor:
            theme.navigationBarTheme.backgroundColor ??
            theme.colorScheme.surface,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_articles.isEmpty) return const Center(child: Text('No articles'));

    final query = categories[_selectedCategory].toLowerCase();
    final filteredArticles = _selectedCategory == 0
        ? _articles
        : _articles.where((article) {
            final title = (article['title'] ?? '').toString().toLowerCase();
            final newsSite = (article['newsSite'] ?? '')
                .toString()
                .toLowerCase();
            return title.contains(query) || newsSite.contains(query);
          }).toList();

    if (filteredArticles.isEmpty) {
      return Center(
        child: Text('No articles for ${categories[_selectedCategory]}'),
      );
    }

    final headline = filteredArticles.first;
    final rest = filteredArticles.skip(1).toList();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadArticles,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.indigo.shade50,
                      ),
                      child: Image.asset(
                        'assets/LOGO.jpg',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SpaceNews',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Latest space news for you',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(160),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildCategoryChips(categories, theme),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(DetailPage.routeName, arguments: headline),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: theme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withAlpha(31),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _buildNetworkImage(
                            headline['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  theme.colorScheme.surface.withAlpha(220),
                                  theme.colorScheme.surface.withAlpha(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withAlpha(220),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              headline['title'] ?? '',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // favorite button for headline
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              icon: Icon(
                                _isFavorited(headline)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorited(headline)
                                    ? Colors.red
                                    : Colors.white,
                              ),
                              onPressed: () =>
                                  setState(() => _toggleFavorite(headline)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Latest',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rest.length,
                itemBuilder: (context, idx) {
                  final item = rest[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      color: theme.cardColor,
                      shadowColor: theme.shadowColor.withAlpha(31),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(DetailPage.routeName, arguments: item),
                        child: Row(
                          children: [
                            if (item['imageUrl'] != null &&
                                item['imageUrl'].isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                                child: Stack(
                                  children: [
                                    _buildNetworkImage(
                                      item['imageUrl'],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: IconButton(
                                          iconSize: 20,
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            _isFavorited(item)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: _isFavorited(item)
                                                ? Colors.red
                                                : Colors.white,
                                          ),
                                          onPressed: () => setState(
                                            () => _toggleFavorite(item),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['newsSite'] ?? '',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withAlpha(174),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories, ThemeData theme) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = _selectedCategory == index;
          return ChoiceChip(
            label: Text(categories[index]),
            selected: selected,
            onSelected: (_) => setState(() => _selectedCategory = index),
            selectedColor: theme.colorScheme.primary,
            backgroundColor: theme.cardColor,
            labelStyle: TextStyle(
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNetworkImage(
    String? url, {
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    if (url == null || url.toString().trim().isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
      );
    }
    final str = url.toString();
    if (!str.startsWith('http')) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
      );
    }
    return Image.network(
      str,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Container(width: width, height: height, color: Colors.grey.shade200),
    );
  }

  String _articleId(dynamic article) {
    if (article == null) return '';
    if (article is Map && article['id'] != null)
      return article['id'].toString();
    if (article is Map && article['url'] != null)
      return article['url'].toString();
    return article.toString();
  }

  bool _isFavorited(dynamic article) {
    try {
      return _favorites.contains(_articleId(article));
    } catch (e) {
      return false;
    }
  }

  void _toggleFavorite(dynamic article) {
    try {
      final id = _articleId(article);
      if (id.isEmpty) return;
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    } catch (e) {
      // ignore
    }
  }
}
