import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const _base =
      'https://api.spaceflightnewsapi.net/v4/articles/?format=json&limit=20';

  Future<List<dynamic>> fetchArticles() async {
    final res = await http.get(Uri.parse(_base));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data is List<dynamic>) {
        return data;
      }
      if (data is Map<String, dynamic> && data['results'] is List<dynamic>) {
        return data['results'] as List<dynamic>;
      }
      throw Exception('Unexpected API response format');
    }
    throw Exception('Failed to fetch articles');
  }
}
