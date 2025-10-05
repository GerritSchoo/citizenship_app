import '../models/question.dart';
import '../models/quiz_data.dart';
import '../models/topic.dart';
import 'question_loader.dart';

class QuestionRepository {
  static final QuestionRepository _instance = QuestionRepository._internal();
  factory QuestionRepository() => _instance;

  QuestionRepository._internal();

  List<Question> _generalQuestions = [];
  final Map<String, List<Question>> _stateQuestions = {};
  List<Topic> _topics = [];
  bool _isLoaded = false;

  Future<void> init() async {
    if (_isLoaded) return;

    final data = await QuestionLoader.loadJson();
    final quizData = QuizData.fromJson(data);

    _topics = quizData.topics;
    _generalQuestions = quizData.generalQuestions;
    _stateQuestions
      ..clear()
      ..addAll(quizData.stateQuestions);

    _isLoaded = true;
  }

  List<Question> get generalQuestions => _generalQuestions;

  List<Topic> get topics => _topics;

  List<Question> getQuestionsByTopic(String topicId) {
    return _generalQuestions.where((q) => q.topicId == topicId).toList();
  }

  List<Question> getStateQuestions(String stateCode) {
    return _stateQuestions[stateCode] ?? const <Question>[];
  }

  bool hasStateQuestions(String stateCode) {
    final list = _stateQuestions[stateCode];
    return list != null && list.isNotEmpty;
  }
}
