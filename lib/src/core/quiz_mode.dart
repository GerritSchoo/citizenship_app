import 'package:meta/meta.dart';

enum QuizMode { mistakes, topics, timer, state }

@immutable
class QuizConfig {
  final QuizMode mode;
  // For topics mode, list of selected topic IDs
  final List<String>? topicIds;
  // For mistakes mode, maximum number of questions to take
  final int? mistakeCount;
  // For timer mode, duration in seconds
  final int? timerSeconds;

  const QuizConfig._({
    required this.mode,
    this.topicIds,
    this.mistakeCount,
    this.timerSeconds,
  });

  factory QuizConfig.mistakes({int count = 20}) =>
      QuizConfig._(mode: QuizMode.mistakes, mistakeCount: count);

  factory QuizConfig.topics({required List<String> topicIds}) =>
      QuizConfig._(mode: QuizMode.topics, topicIds: List.unmodifiable(topicIds));

  factory QuizConfig.timer({int seconds = 120}) =>
      QuizConfig._(mode: QuizMode.timer, timerSeconds: seconds);

  factory QuizConfig.state() =>
    const QuizConfig._(mode: QuizMode.state);
}
