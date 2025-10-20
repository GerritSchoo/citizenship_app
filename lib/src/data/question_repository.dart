import '../models/question.dart';
import '../models/quiz_data.dart';
import '../models/topic.dart';
import 'question_loader.dart';

class QuestionRepository {
  static final QuestionRepository _instance = QuestionRepository._internal();
  factory QuestionRepository() => _instance;

  QuestionRepository._internal();

  static String _defaultLanguageCode = 'de';
  static void setDefaultLanguage(String code) {
    _defaultLanguageCode = (code.isEmpty ? 'de' : code).toLowerCase();
  }
  static String get defaultLanguageCode => _defaultLanguageCode;

  List<Question> _generalQuestions = [];
  final Map<String, List<Question>> _stateQuestions = {};
  List<Topic> _topics = [];
  bool _isLoaded = false;
  String? _loadedLanguageCode; // 'de', 'en', ...

  Future<void> init({String? languageCode}) async {
    // If already loaded for the same language, skip
    final lang = (languageCode ?? _defaultLanguageCode).toLowerCase();
    if (_isLoaded && _loadedLanguageCode == lang) return;

    final data = await QuestionLoader.loadJson(languageCode: lang);
    final quizData = QuizData.fromJson(data);

    _topics = quizData.topics;
    _generalQuestions = quizData.generalQuestions;
    _stateQuestions
      ..clear()
      ..addAll(quizData.stateQuestions);

    _isLoaded = true;
    _loadedLanguageCode = lang;
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

  /// Force a reload on language change.
  Future<void> reloadForLanguage(String languageCode) async {
    _isLoaded = false;
    await init(languageCode: languageCode);
  }
}
