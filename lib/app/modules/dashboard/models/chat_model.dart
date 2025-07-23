import 'package:flutter/cupertino.dart';

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
    this.key,
  });

  /// Prompt for the chat entry
  final String prompt;

  /// Answer for the chat entry
  final List<Answer> answers;

  /// List of sources associated with the chat entry
  final List<Source> sources;

  /// Optional key for the chat entry
  GlobalKey? key;
}

/// Answer
class Answer {
  /// Constructor for Answer
  Answer({
    required this.id,
    this.text,
    this.imageUrls,
    this.pointsAnswers,
  });

  /// Id of the answer
  final int id;

  /// Text of the answer
  final String? text;

  /// Optional image URL associated with the answer
  final List<String>? imageUrls;

  /// PointsAnswers associated with the answer
  final List<PointsAnswers>? pointsAnswers;
}

/// QuestionAnswers model representing a question with associated answers
class PointsAnswers {
  /// Constructor for Question
  PointsAnswers({
    required this.id,
    this.point,
    this.declaration,
  });

  /// Id of the question
  final int id;

  /// Text of the question
  final String? point;

  /// List of answers associated with the question
  final String? declaration;
}
