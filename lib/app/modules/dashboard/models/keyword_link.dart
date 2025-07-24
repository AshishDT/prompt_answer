/// Key word link
class KeywordLink {
  /// Constructor for KeywordLink
  KeywordLink({
     this.keyword,
     this.url,
  });

  /// Creates a copy of the KeywordLink with modified properties
  factory KeywordLink.fromJson(Map<String, dynamic> json) => KeywordLink(
        keyword: json['keyword'] ?? '',
        url: json['url'] ?? '',
      );

  /// Keyword and URL
  final String? keyword;

  /// URL associated with the keyword
  final String? url;
}
