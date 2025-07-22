/// Source model representing a source of information
class Source {
  /// Constructor for Source
  Source({
    required this.id,
    required this.title,
    required this.url,
  });

  /// Id
  final int id;

  /// Title of the source
  final String title;

  /// URL of the source
  final String url;
}

/// ChatEntry model representing a chat entry with a prompt, answer, and sources
class ChatEntry {
  /// Constructor for ChatEntry
  ChatEntry({
    required this.prompt,
    required this.answers,
    required this.sources,
  });

  /// Prompt for the chat entry
  final String prompt;

  /// Answer for the chat entry
  final List<String> answers;

  /// List of sources associated with the chat entry
  final List<Source> sources;
}
