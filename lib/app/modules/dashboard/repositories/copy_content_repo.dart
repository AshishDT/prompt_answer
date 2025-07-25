import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

import '../models/chat_event.dart';
import '../models/source_link.dart';
import 'html_cleaner.dart';

/// Copy content repository interface.
class CopyContentRepo {
  /// Copy the content of a chat event to the clipboard.
  static void copy(ChatEventModel event) {
    final StringBuffer buffer = StringBuffer();

    final String htmlContent = HtmlCleaner.clean(event.html.toString());
    final String plainText = _htmlToPlainText(htmlContent);

    if (plainText.isNotEmpty) {
      buffer
        ..writeln('Content:')
        ..writeln(plainText)
        ..writeln();
    }

    if (event.sourceLinks.isNotEmpty) {
      buffer.writeln('Source Links:');
      for (int i = 0; i < event.sourceLinks.length; i++) {
        final SourceLink source = event.sourceLinks[i];
        buffer.writeln(
            '${i + 1}. ${source.title ?? 'No title'} - ${source.url ?? 'No URL'}');
      }
      buffer.writeln();
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  static String _htmlToPlainText(String htmlString) {
    if (htmlString.isEmpty) {
      return '';
    }

    try {
      final html_dom.Document document = html_parser.parse(htmlString);
      return document.body?.text ?? document.documentElement?.text ?? '';
    } on Exception {
      return _stripHtmlTags(htmlString);
    }
  }

  static String _stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) {
      return '';
    }

    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
