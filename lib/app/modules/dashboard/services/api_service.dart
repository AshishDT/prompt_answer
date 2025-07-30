import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Custom exception for API errors
class SearchApiException implements Exception {
  /// Constructor for SearchApiException
  SearchApiException(this.message, [this.original]);

  /// Message describing the error
  final String message;

  /// Optional original error object
  final Object? original;

  @override
  String toString() => 'SearchApiException: $message';
}

/// Service for interacting with the Search API
class SearchApiService {
  /// Constructor for initializing the SearchApiService
  SearchApiService() {
    if (!kIsWeb) {
      _dio = Dio();
    }
  }

  /// Base URL and API keys for the Search API
  static const String _baseUrl = 'https://stagingapi.search.com';
  static const String _apiKey = 'JiMmNjQ_OS43PSE,';
  static const String _auth = 'Iw,,';
  static const String _chatId = 'chat_6881d4beb6c0b';
  static const String _uid = 'YUlRZGNaMzRDVGx5ekg0TXgwSU5zQT09';

  Dio? _dio;

  /// Streams search results for the given prompt
  Future<Stream<List<int>>> searchStream(String prompt) async {
    if (prompt.trim().isEmpty) {
      throw ArgumentError('Prompt cannot be empty');
    }

    final String url = _buildSearchUrl(prompt.trim());

    try {
      if (kIsWeb) {
        return _searchStreamWeb(url);
      } else {
        return _searchStreamMobile(url);
      }
    } catch (e) {
      throw SearchApiException('Search stream failed: $e', e);
    }
  }

  /// Mobile/desktop streaming via Dio
  Future<Stream<List<int>>> _searchStreamMobile(String url) async {
    final Response<ResponseBody> response = await _dio!.get<ResponseBody>(
      url,
      options: Options(responseType: ResponseType.stream),
    );

    return response.data!.stream;
  }

  /// Web streaming using `http` package
  Future<Stream<List<int>>> _searchStreamWeb(String url) async {
    final http.Request request = http.Request('GET', Uri.parse(url));
    final http.StreamedResponse streamedResponse = await request.send();

    if (streamedResponse.statusCode != 200) {
      throw SearchApiException(
        'Web stream failed: ${streamedResponse.statusCode}',
      );
    }

    return streamedResponse.stream;
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
    if (!kIsWeb) {
      _dio?.close();
    }
  }
}
