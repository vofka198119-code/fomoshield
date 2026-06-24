import 'package:dio/dio.dart';
import '../../core/utils/constants.dart';

/// Wikipedia REST API service for company history
class HistoryService {
  final Dio _dio;

  HistoryService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// Fetch company summary from Wikipedia
  /// Auto-detect language: prefer system lang, fallback to EN
  Future<Map<String, dynamic>?> fetchSummary(String companyName,
      {String? lang}) async {
    // Try specified language or EN
    final langs = lang != null ? [lang, 'en'] : ['en'];

    for (final l in langs) {
      try {
        final base = l == 'ru'
            ? AppConstants.wikiBaseRU
            : AppConstants.wikiBaseEN;
        final encoded = Uri.encodeComponent(companyName);
        final response = await _dio.get('$base/$encoded');

        if (response.statusCode == 200) {
          final data = Map<String, dynamic>.from(response.data);
          if (data['title'] != null && data['extract'] != null) {
            data['_lang'] = l;
            return data;
          }
        }
      } catch (_) {
        // Fallback to EN if RU fails
        if (l == 'ru') continue;
      }
    }
    return null;
  }

  /// Parse company DNA from Wikipedia extract
  static CompanyHistory parseHistory(Map<String, dynamic> wikiData) {
    final extract = wikiData['extract'] as String? ?? '';
    final title = wikiData['title'] as String? ?? '';
    final sourceUrl = wikiData['content_urls']?['desktop']?['page'] as String? ?? '';

    return CompanyHistory(
      companyName: title,
      summary: extract,
      sourceUrl: sourceUrl,
      foundedYear: _extractYear(extract, 'founded'),
      founders: _extractFounders(extract),
      description: extract.length > 500 ? '${extract.substring(0, 500)}...' : extract,
    );
  }

  static String? _extractYear(String text, String keyword) {
    final regex = RegExp('$keyword\\s+in\\s+(\\d{4})', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1);
  }

  static List<String> _extractFounders(String text) {
    final regex = RegExp('founded\\s+by\\s+([^.]+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    if (match == null) return [];
    return match.group(1)!.split(',').map((e) => e.trim()).toList();
  }
}

class CompanyHistory {
  final String companyName;
  final String summary;
  final String sourceUrl;
  final String? foundedYear;
  final List<String> founders;
  final String description;

  CompanyHistory({
    required this.companyName,
    required this.summary,
    required this.sourceUrl,
    this.foundedYear,
    this.founders = const [],
    this.description = '',
  });
}
