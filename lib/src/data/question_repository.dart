import '../models/question.dart';
import 'question_loader.dart';

class QuestionRepository {
  static final QuestionRepository _instance = QuestionRepository._internal();
  factory QuestionRepository() => _instance;

  QuestionRepository._internal();

  List<Question> _generalQuestions = [];
  bool _isLoaded = false;

  Future<void> init() async {
    if (_isLoaded) return;

    final data = await QuestionLoader.loadJson();
    final List generalJson = data["generalQuestions"];

    _generalQuestions =
        generalJson.map((q) => Question.fromJson(q)).toList();

    _isLoaded = true;
  }

  List<Question> get generalQuestions => _generalQuestions;
}
