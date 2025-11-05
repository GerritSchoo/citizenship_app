import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TimerHighscore {
  final int correct;
  final int answered;
  final DateTime when;

  const TimerHighscore({required this.correct, required this.answered, required this.when});

  factory TimerHighscore.fromJson(Map<String, dynamic> json) => TimerHighscore(
        correct: (json['correct'] as num?)?.toInt() ?? 0,
        answered: (json['answered'] as num?)?.toInt() ?? 0,
        when: DateTime.fromMillisecondsSinceEpoch((json['when'] as num?)?.toInt() ?? 0),
      );

  Map<String, dynamic> toJson() => {
        'correct': correct,
        'answered': answered,
        'when': when.millisecondsSinceEpoch,
      };
}

class HighscoreStore {
  static const _prefsKey = 'timer_highscores_v1';
  HighscoreStore._();
  static final HighscoreStore instance = HighscoreStore._();

  Future<void> addTimerScore({required int correct, required int answered, DateTime? when, int keepTop = 10}) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_prefsKey) ?? const <String>[];
    final list = raw.map((s) => TimerHighscore.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
    list.add(TimerHighscore(correct: correct, answered: answered, when: when ?? DateTime.now()));
    // Sort by correct desc, then answered desc, then newest first
    list.sort((a, b) {
      final byCorrect = b.correct.compareTo(a.correct);
      if (byCorrect != 0) return byCorrect;
      final byAnswered = b.answered.compareTo(a.answered);
      if (byAnswered != 0) return byAnswered;
      return b.when.compareTo(a.when);
    });
    final trimmed = list.take(keepTop).toList();
    await p.setStringList(_prefsKey, trimmed.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<List<TimerHighscore>> topScores({int limit = 10}) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_prefsKey) ?? const <String>[];
    final list = raw.map((s) => TimerHighscore.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
    return list.take(limit).toList();
  }
}
