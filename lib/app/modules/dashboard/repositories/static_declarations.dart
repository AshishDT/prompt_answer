// ignore_for_file: public_member_api_docs

import '../models/chat_model.dart';

/// Static declarations for the dashboard module.
class StaticDeclarations {
  static const String _rewardExplanation =
      'You’ll earn points based on the accuracy and completeness of your response.';

  static const String _imageGuideline =
      'Ensure the image is clear, relevant, and adheres to community guidelines.';

  static const String _textRequirement =
      'All answers must be well-written, free from grammatical errors, and factually correct.';

  static const String _bonusPoints =
      'Bonus points are awarded for including additional helpful information.';

  static const String _reviewPolicy =
      'Submitted content is reviewed and may be rejected if it violates platform policies.';

  static const String _originalityClause =
      'All answers must be your original work. Plagiarized content will be disqualified.';

  static const String _feedbackNotice =
      'Users can provide feedback on your answer, which may affect your reward.';

  static const String _evidenceEncouraged =
      'Supporting your answer with facts, examples, or evidence improves credibility.';

  static const String _reattemptInfo =
      'You can attempt this again after 24 hours if your submission is rejected.';

  static const String _mediaUsage =
      'Images or videos should not include watermarks or personal information.';

  /// Sample points answers
  static List<PointsAnswers> get samplePoints  => <PointsAnswers>[
    PointsAnswers(
      id: 1,
      point: 'Answer the question in detail.',
      declaration: StaticDeclarations._rewardExplanation,
    ),
    PointsAnswers(
      id: 2,
      point: 'Upload at least one supporting image.',
      declaration: StaticDeclarations._imageGuideline,
    ),
    PointsAnswers(
      id: 3,
      point: 'Make sure your text is original and well-structured.',
      declaration: StaticDeclarations._textRequirement,
    ),
    PointsAnswers(
      id: 4,
      point: 'Bonus points for additional helpful information.',
      declaration: StaticDeclarations._bonusPoints,
    ),
    PointsAnswers(
      id: 5,
      point: 'Content is reviewed and may be rejected if it violates policies.',
      declaration: StaticDeclarations._reviewPolicy,
    ),
    PointsAnswers(
      id: 6,
      point: 'All answers must be original work.',
      declaration: StaticDeclarations._originalityClause,
    ),
    PointsAnswers(
      id: 7,
      point: 'Users can provide feedback on your answer.',
      declaration: StaticDeclarations._feedbackNotice,
    ),
    PointsAnswers(
      id: 8,
      point: 'Supporting your answer with facts improves credibility.',
      declaration: StaticDeclarations._evidenceEncouraged,
    ),
    PointsAnswers(
      id: 9,
      point: 'You can reattempt after 24 hours if rejected.',
      declaration: StaticDeclarations._reattemptInfo,
    ),
    PointsAnswers(
      id: 10,
      point: 'Images or videos should not include watermarks.',
      declaration: StaticDeclarations._mediaUsage,
    ),
  ];
}
