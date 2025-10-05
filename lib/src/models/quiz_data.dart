import 'question.dart';
import 'topic.dart';

class QuizData {
  final List<Topic> topics;
  final List<Question> generalQuestions;
  final Map<String, List<Question>> stateQuestions;

  QuizData({
    required this.topics,
    required this.generalQuestions,
    required this.stateQuestions,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) {
    final topics = (json['topics'] as List<dynamic>?)
            ?.map((e) => Topic.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final generalQuestions = (json['generalQuestions'] as List<dynamic>?)
            ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final rawState = json['stateQuestions'] as Map<String, dynamic>? ?? {};
    final stateQuestions = <String, List<Question>>{};
    rawState.forEach((key, value) {
      stateQuestions[key] = (value as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList();
    });

    return QuizData(
      topics: topics,
      generalQuestions: generalQuestions,
      stateQuestions: stateQuestions,
    );
  }
}
