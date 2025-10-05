import 'package:flutter/foundation.dart';
import 'dart:math';

import '../data/question_repository.dart';
import '../models/question.dart';

/// Generic session controller for quizzes and learning sessions.
///
/// Responsibility:
/// - load questions (optionally shuffled)
/// - expose current index, selected index, loading/error state
/// - navigation (next/previous) and selection handling
class Controller extends ChangeNotifier {
  final QuestionRepository _repo;
  final String? stateCode;

  List<Question> questions = [];
  int currentIndex = 0;
  int? selectedIndex;
  bool isLoading = false;
  String? error;

  Controller({QuestionRepository? repository, this.stateCode}) : _repo = repository ?? QuestionRepository();

  /// Load questions. If [shuffle] is true the list will be shuffled.
  Future<void> load({bool shuffle = false}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _repo.init();

      final List<Question> source;
      if (stateCode != null && _repo.hasStateQuestions(stateCode!)) {
        source = _repo.getStateQuestions(stateCode!);
      } else {
        source = _repo.generalQuestions;
      }

      questions = List<Question>.from(source);
      if (shuffle) {
        questions.shuffle();
      }

      currentIndex = 0;
      selectedIndex = null;
    } catch (e) {
      error = e.toString();
      questions = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Build and load a mock exam: [generalCount] general questions + [stateCount] state questions.
  Future<void> loadMockExam({int generalCount = 30, int stateCount = 3, bool shuffle = true}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _repo.init();

      final general = List<Question>.from(_repo.generalQuestions);
      final stateQs = (stateCode != null && _repo.hasStateQuestions(stateCode!)) ? List<Question>.from(_repo.getStateQuestions(stateCode!)) : <Question>[];

      // Avoid duplicates by id
      final stateIds = stateQs.map((q) => q.id).toSet();
      general.removeWhere((q) => stateIds.contains(q.id));

      final rnd = Random();
      general.shuffle(rnd);
      stateQs.shuffle(rnd);

      final takeGeneral = min(generalCount, general.length);
      final takeState = min(stateCount, stateQs.length);

      final selected = <Question>[];
      selected.addAll(general.take(takeGeneral));
      selected.addAll(stateQs.take(takeState));

      // Fill if not enough questions
      final available = <Question>[];
      available.addAll(general.skip(takeGeneral));
      available.addAll(stateQs.skip(takeState));
      available.shuffle(rnd);
      while (selected.length < (generalCount + stateCount) && available.isNotEmpty) {
        final q = available.removeLast();
        if (!selected.any((s) => s.id == q.id)) selected.add(q);
      }

      if (shuffle) selected.shuffle(rnd);

      questions = selected;
      currentIndex = 0;
      selectedIndex = null;
    } catch (e) {
      error = e.toString();
      questions = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load general questions plus state questions (if stateCode set) into questions.
  Future<void> loadCombined({bool shuffle = false}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _repo.init();
      final List<Question> base = List<Question>.from(_repo.generalQuestions);
      if (stateCode != null && _repo.hasStateQuestions(stateCode!)) {
        base.addAll(_repo.getStateQuestions(stateCode!));
      }
      questions = base;
      if (shuffle) questions.shuffle();
      currentIndex = 0;
      selectedIndex = null;
    } catch (e) {
      error = e.toString();
      questions = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Initialize controller with an existing list of questions (no repo load).
  /// Useful for when a caller already prepared a list (e.g. learning sessions).
  void setQuestions(List<Question> items, {bool shuffle = false}) {
    questions = List<Question>.from(items);
    if (shuffle) questions.shuffle();
    currentIndex = 0;
    selectedIndex = null;
    notifyListeners();
  }

  /// Mark an answer as selected. Only the first selection is accepted.
  void select(int index) {
    if (selectedIndex == null) {
      selectedIndex = index;
      notifyListeners();
    }
  }

  /// Move to the next question and clear selection.
  void next() {
    if (currentIndex < questions.length - 1) {
      currentIndex += 1;
      selectedIndex = null;
      notifyListeners();
    }
  }

  /// Move to the previous question and clear selection.
  void previous() {
    if (currentIndex > 0) {
      currentIndex -= 1;
      selectedIndex = null;
      notifyListeners();
    }
  }

  /// Whether the current question is the last in the session.
  bool get isLast => currentIndex >= questions.length - 1;

  /// Simple user-facing position label.
  String positionLabel() => 'Frage ${currentIndex + 1} von ${questions.length}';
}

