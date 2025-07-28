import 'dart:convert';

import 'package:nigerian_igbo/app/data/config/logger.dart';

/// HtmlCleaner is a class that provides methods to clean and sanitize HTML content.
class HtmlCleaner {
  /// Cleans the HTML content by removing unnecessary characters and formatting.
  static String clean(String value) {
    String rawData = value;

    // Remove surrounding quotes
    rawData = rawData.replaceAll(RegExp(r'^"+|"+$'), '');
    rawData = rawData.replaceFirst(RegExp(r'^(n|\n)(?=\s*<)'), '');

    // Clean the content
    rawData = _cleanHtmlResponse(rawData);

    return rawData;
  }

  /// Specifically for cleaning HTML content from ai_response
  static String cleanHtmlContent(String input) {
    try {
      String cleaned = input;

      // If it's a JSON-encoded string, decode it
      if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
        cleaned = json.decode(cleaned) as String;
      }

      // Apply manual cleaning
      cleaned = _manualClean(cleaned);

      return cleaned;
    } catch (e) {
      logE('HtmlCleaner: Error cleaning HTML content: $e');
      return _manualClean(input);
    }
  }

  /// Cleans the HTML response by removing unnecessary characters and formatting.
  static String _cleanHtmlResponse(String input) {
    try {
      final String trimmed = input.trim();

      // If already a valid JSON array or object, return as is
      if ((trimmed.startsWith('[') && trimmed.endsWith(']')) ||
          (trimmed.startsWith('{') && trimmed.endsWith('}'))) {
        return trimmed;
      }

      // If it's a double-encoded JSON string, decode it once
      if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
          (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
        return json.decode(trimmed) as String;
      }

      return _manualClean(trimmed);
    } on Exception catch (e) {
      logE('HtmlCleaner: Error cleaning HTML response: $e');
      return _manualClean(input);
    }
  }

  static String _manualClean(String input) => input
          .replaceAll(r'n\\n', '\n')
          .replaceAll(r'\\n', '\n')
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\\t', '\t')
          .replaceAll(r'\t', '\t')
          .replaceAll(r'\"', '"')
          .replaceAllMapped(RegExp(r'\\(?!n|t|")'), (_) => '')
          .replaceAllMapped(
        RegExp(r'style=([^\s"<>;]+(?:\s[^\s"<>;]+)*);?'),
        (Match match) {
          final String? value = match.group(1);
          return 'style="$value"';
        },
      ).replaceAllMapped(
        RegExp(r'\.(?=[A-Z])'),
        (match) => '. ',
      );
}
