import 'package:dio/dio.dart';

/// Service for interacting with the Search API
class SearchApiService {
  /// Constructor for initializing the SearchApiService
  SearchApiService() {
    _dio = Dio();
  }

  /// Base URL and API keys for the Search API
  static const String _baseUrl = 'https://stagingapi.search.com';

  /// API keys and authentication details
  static const String _apiKey = 'JiMmNjQ_OS43PSE,';

  /// Authentication token and user details
  static const String _auth = 'Iw,,';

  /// Chat ID and user ID for the search context
  static const String _chatId = 'chat_6881d4beb6c0b';

  /// Unique identifier for the user session
  static const String _uid = 'YUlRZGNaMzRDVGx5ekg0TXgwSU5zQT09';

  /// Dio instance for making HTTP requests
  late final Dio _dio;

  /// Streams search results for the given prompt
  Future<Stream<List<int>>> searchStream(String prompt) async {
    if (prompt.trim().isEmpty) {
      throw ArgumentError('Prompt cannot be empty');
    }

    final String url = _buildSearchUrl(prompt.trim());

    try {
      final Response<ResponseBody> response = await _dio.get<ResponseBody>(
        url,
        options: Options(responseType: ResponseType.stream),
      );

      return response.data!.stream;
    } on DioException catch (e) {
      throw SearchApiException('API request failed: ${e.message}', e);
    }
  }

  /// Builds the complete search URL with all required parameters
  String _buildSearchUrl(String prompt) {
    final String encodedPrompt = Uri.encodeComponent(prompt);

    return '$_baseUrl/search'
        '?prompt=$encodedPrompt'
        '&nt=0'
        '&key=$_apiKey'
        '&auth=$_auth'
        '&sub='
        '&currentChatId=$_chatId'
        '&is_image='
        '&image_url='
        '&space_id='
        '&source_link_res=true'
        '&uid=$_uid';
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}

/// Custom exception for search API errors
class SearchApiException implements Exception {
  /// Constructor for SearchApiException
  const SearchApiException(this.message, [this.dioException]);

  /// Error message and optional DioException
  final String message;

  /// Optional DioException for more detailed error information
  final DioException? dioException;

  @override
  String toString() => 'SearchApiException: $message';
}
