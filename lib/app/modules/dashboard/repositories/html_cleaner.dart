import 'dart:convert';
import 'package:html/dom.dart';
import 'package:nigerian_igbo/app/data/config/logger.dart';
import 'package:html/parser.dart' as html_parser;

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
        (Match match) => '. ',
      );

  /// Converts HTML input to plain text by removing all HTML tags and entities.
  static String toPlainText(String htmlInput) {
    try {
      final Document document = html_parser.parse(htmlInput);
      final StringBuffer buffer = StringBuffer();

      void walk(Node node) {
        if (node is Text) {
          buffer.write(node.text.trim());
        } else if (node is Element) {
          switch (node.localName) {
            case 'h1':
            case 'h2':
            case 'h3':
              buffer.write('\n\n${node.text.trim().toUpperCase()}\n');
              break;
            case 'p':
              buffer.write('\n${node.text.trim()}\n');
              break;
            case 'li':
              buffer.write('\n• ${node.text.trim()}');
              break;
            case 'br':
              buffer.write('\n');
              break;
            default:
              node.nodes.forEach(walk);
          }
        }
      }

      walk(document.body ?? Element.tag('body'));
      return buffer.toString().replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    } catch (e) {
      logE('HtmlCleaner: Error parsing HTML for TTS: $e');
      return htmlInput;
    }
  }}
