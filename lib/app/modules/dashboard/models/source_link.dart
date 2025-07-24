/// Represents a source link with metadata
class SourceLink {
  /// SourceLink constructor
  SourceLink({
    this.title,
    this.url,
    this.description,
    this.favicon,
    this.pageTitle,
    this.domain,
  });

  /// Creates a copy of the SourceLink with modified properties
  factory SourceLink.fromJson(Map<String, dynamic> json) => SourceLink(
        title: json['title'] ?? '',
        url: json['url'] ?? '',
        description: json['description'] ?? '',
        favicon: json['favicon'] ?? '',
        pageTitle: json['page_title'] ?? '',
        domain: json['domain'] ?? '',
      );

  /// Title
  final String? title;

  /// URL of the source
  final String? url;

  /// Description of the source
  final String? description;

  /// Favicon URL of the source
  final String? favicon;

  /// Page title of the source
  final String? pageTitle;

  /// Domain of the source
  final String? domain;
}
