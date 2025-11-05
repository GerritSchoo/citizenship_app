import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

enum SessionMode { practice, exam }

class OverallStat {
  final int correct;
  final int total;
  final int avgTimeMs;
  const OverallStat({required this.correct, required this.total, required this.avgTimeMs});
  double get accuracy => total == 0 ? 0.0 : correct / total;
}

class DailyStat {
  final DateTime date;
  final int correct;
  final int total;
  const DailyStat({required this.date, required this.correct, required this.total});
  double get accuracy => total == 0 ? 0.0 : correct / total;
}

class TopicStat {
  final String topicId;
  final int correct;
  final int total;
  const TopicStat({required this.topicId, required this.correct, required this.total});
  double get accuracy => total == 0 ? 0.0 : correct / total;
}

class ExamResult {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int correct;
  final int total;
  final int durationMs;
  const ExamResult({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.correct,
    required this.total,
    required this.durationMs,
  });
  bool get completed => endedAt != null;
  bool get passed => correct >= 17; // Pass rule: 17+ correct answers
}

class ProgressRepository {
  ProgressRepository._();
  static final ProgressRepository instance = ProgressRepository._();

  Database? _db;
  bool get isAvailable => _db != null;
  // Notifies about initialization error message (null when ok)
  final ValueNotifier<String?> initError = ValueNotifier<String?>(null);

  Future<void> init() async {
    if (_db != null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dir.path, 'progress.db');
      _db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE attempts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              sessionId TEXT NOT NULL,
              timestamp INTEGER NOT NULL,
              questionId TEXT NOT NULL,
              topicId TEXT,
              isState INTEGER NOT NULL DEFAULT 0,
              mode TEXT NOT NULL,
              selectedIndex INTEGER,
              correctIndex INTEGER,
              isCorrect INTEGER NOT NULL,
              skipped INTEGER NOT NULL DEFAULT 0,
              timeToAnswerMs INTEGER NOT NULL
            );
          ''');
          await db.execute('''
            CREATE TABLE sessions (
              id TEXT PRIMARY KEY,
              mode TEXT NOT NULL,
              startedAt INTEGER NOT NULL,
              endedAt INTEGER,
              totalQuestions INTEGER NOT NULL,
              correctCount INTEGER NOT NULL DEFAULT 0,
              durationMs INTEGER NOT NULL DEFAULT 0
            );
          ''');
          await db.execute('''
            CREATE TABLE achievements (
              id TEXT PRIMARY KEY,
              unlockedAt INTEGER NOT NULL
            );
          ''');
        },
      );
      // Ensure achievements table exists when upgrading from older versions
      await _db!.execute('CREATE TABLE IF NOT EXISTS achievements (id TEXT PRIMARY KEY, unlockedAt INTEGER NOT NULL);');
      initError.value = null;
    } catch (e, st) {
      // If database init fails, leave _db as null. Callers should handle isAvailable.
      _db = null;
      initError.value = e.toString();
      // ignore: avoid_print
      print('[ProgressRepository] DB init failed: $e\n$st');
    }
  }

  Future<void> startSession({
    required String sessionId,
    required SessionMode mode,
    required int totalQuestions,
    DateTime? startedAt,
  }) async {
    final db = _db;
    if (db == null) return;
    await db.insert('sessions', {
      'id': sessionId,
      'mode': mode.name,
      'startedAt': (startedAt ?? DateTime.now()).millisecondsSinceEpoch,
      'totalQuestions': totalQuestions,
      'correctCount': 0,
      'durationMs': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> finishSession({
    required String sessionId,
    required int correctCount,
    required Duration duration,
    DateTime? endedAt,
  }) async {
    final db = _db;
    if (db == null) return;
    await db.update(
      'sessions',
      {
        'endedAt': (endedAt ?? DateTime.now()).millisecondsSinceEpoch,
        'correctCount': correctCount,
        'durationMs': duration.inMilliseconds,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> logAttempt({
    required String sessionId,
    required String questionId,
    String? topicId,
    required bool isState,
    required SessionMode mode,
    required int? selectedIndex,
    required int correctIndex,
    required bool isCorrect,
    required bool skipped,
    required int timeToAnswerMs,
    DateTime? timestamp,
  }) async {
    final db = _db;
    if (db == null) return;
    await db.insert('attempts', {
      'sessionId': sessionId,
      'timestamp': (timestamp ?? DateTime.now()).millisecondsSinceEpoch,
      'questionId': questionId,
      'topicId': topicId,
      'isState': isState ? 1 : 0,
      'mode': mode.name,
      'selectedIndex': selectedIndex,
      'correctIndex': correctIndex,
      'isCorrect': isCorrect ? 1 : 0,
      'skipped': skipped ? 1 : 0,
      'timeToAnswerMs': timeToAnswerMs,
    });
  }

  Future<void> clearAttemptsForSession(String sessionId) async {
    final db = _db;
    if (db == null) return;
    await db.delete('attempts', where: 'sessionId = ?', whereArgs: [sessionId]);
  }

  Future<int> sessionCorrectCount(String sessionId) async {
    final db = _db;
    if (db == null) return 0;
    final rows = await db.rawQuery(
      'SELECT SUM(isCorrect) as correct FROM attempts WHERE sessionId = ?',
      [sessionId],
    );
    return (rows.first['correct'] as int?) ?? 0;
  }

  Future<int> sessionAttemptCount(String sessionId) async {
    final db = _db;
    if (db == null) return 0;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) as total FROM attempts WHERE sessionId = ?',
      [sessionId],
    );
    return (rows.first['total'] as int?) ?? 0;
  }

  /// Returns distinct question IDs that were answered incorrectly in a given session.
  /// Ordered by last timestamp descending (most recently attempted first).
  Future<List<String>> sessionIncorrectQuestionIds(String sessionId) async {
    final db = _db;
    if (db == null) return const <String>[];
    final rows = await db.rawQuery(
      'SELECT questionId, MAX(timestamp) as ts FROM attempts WHERE sessionId = ? AND isCorrect = 0 GROUP BY questionId ORDER BY ts DESC',
      [sessionId],
    );
    return rows
        .map((r) => (r['questionId'] as String?) ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
  }

  Future<OverallStat> overallStats({bool includePractice = true, bool includeExam = true}) async {
    final db = _db;
    if (db == null) return const OverallStat(correct: 0, total: 0, avgTimeMs: 0);
    final modes = <String>[];
    if (includePractice) modes.add(SessionMode.practice.name);
    if (includeExam) modes.add(SessionMode.exam.name);
    final placeholders = List.filled(modes.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT SUM(isCorrect) as correct, COUNT(*) as total, CAST(AVG(timeToAnswerMs) AS INT) as avgMs FROM attempts WHERE mode IN ($placeholders)',
      modes,
    );
    final correct = (rows.first['correct'] as int?) ?? 0;
    final total = (rows.first['total'] as int?) ?? 0;
    final avgMs = (rows.first['avgMs'] as int?) ?? 0;
    return OverallStat(correct: correct, total: total, avgTimeMs: avgMs);
  }

  Future<OverallStat> stateStats({bool includePractice = true, bool includeExam = true}) async {
    final db = _db;
    if (db == null) return const OverallStat(correct: 0, total: 0, avgTimeMs: 0);
    final modes = <String>[];
    if (includePractice) modes.add(SessionMode.practice.name);
    if (includeExam) modes.add(SessionMode.exam.name);
    final placeholders = List.filled(modes.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT SUM(isCorrect) as correct, COUNT(*) as total, CAST(AVG(timeToAnswerMs) AS INT) as avgMs '
      'FROM attempts WHERE isState = 1 AND mode IN ($placeholders)',
      modes,
    );
    final correct = (rows.first['correct'] as int?) ?? 0;
    final total = (rows.first['total'] as int?) ?? 0;
    final avgMs = (rows.first['avgMs'] as int?) ?? 0;
    return OverallStat(correct: correct, total: total, avgTimeMs: avgMs);
  }

  Future<List<DailyStat>> dailyAccuracy({int days = 30, bool includePractice = true, bool includeExam = true}) async {
    final db = _db;
    if (db == null) return const <DailyStat>[];
    final modes = <String>[];
    if (includePractice) modes.add(SessionMode.practice.name);
    if (includeExam) modes.add(SessionMode.exam.name);
    final placeholders = List.filled(modes.length, '?').join(',');
    final rows = await db.rawQuery('''
      SELECT date(timestamp/1000, 'unixepoch') as d, SUM(isCorrect) as correct, COUNT(*) as total
      FROM attempts WHERE mode IN ($placeholders)
      GROUP BY d ORDER BY d ASC
    ''', modes);
    final all = rows.map((r) {
      final d = DateTime.parse(r['d'] as String);
      final correct = (r['correct'] as int?) ?? 0;
      final total = (r['total'] as int?) ?? 0;
      return DailyStat(date: d, correct: correct, total: total);
    }).toList();
    if (all.length > days) return all.sublist(all.length - days);
    return all;
  }

  Future<List<TopicStat>> topicAccuracy({bool includePractice = true, bool includeExam = true}) async {
    final db = _db;
    if (db == null) return const <TopicStat>[];
    final modes = <String>[];
    if (includePractice) modes.add(SessionMode.practice.name);
    if (includeExam) modes.add(SessionMode.exam.name);
    final placeholders = List.filled(modes.length, '?').join(',');
    final rows = await db.rawQuery('''
      SELECT topicId as t, SUM(isCorrect) as correct, COUNT(*) as total
      FROM attempts
      WHERE topicId IS NOT NULL
        AND isState = 0
        AND mode IN ($placeholders)
      GROUP BY topicId
      ORDER BY t ASC
    ''', modes);
    return rows.map((r) => TopicStat(
          topicId: (r['t'] as String?) ?? 'unknown',
          correct: (r['correct'] as int?) ?? 0,
          total: (r['total'] as int?) ?? 0,
        )).toList();
  }

  Future<List<ExamResult>> examResults({int limit = 5}) async {
    final db = _db;
    if (db == null) return const <ExamResult>[];
    final rows = await db.rawQuery('''
      SELECT id, startedAt, endedAt, correctCount, totalQuestions, durationMs
      FROM sessions WHERE mode = ?
      ORDER BY startedAt DESC
      LIMIT ?
    ''', [SessionMode.exam.name, limit]);
    return rows.map((r) => ExamResult(
      id: r['id'] as String,
      startedAt: DateTime.fromMillisecondsSinceEpoch((r['startedAt'] as int?) ?? 0),
      endedAt: (r['endedAt'] as int?) != null ? DateTime.fromMillisecondsSinceEpoch(r['endedAt'] as int) : null,
      correct: (r['correctCount'] as int?) ?? 0,
      total: (r['totalQuestions'] as int?) ?? 0,
      durationMs: (r['durationMs'] as int?) ?? 0,
    )).toList();
  }

  Future<double> examPassRate() async {
    final results = await examResults(limit: 1000);
    if (results.isEmpty) return 0.0;
    final passed = results.where((e) => e.completed && e.passed).length;
    final completed = results.where((e) => e.completed).length;
    if (completed == 0) return 0.0;
    return passed / completed;
  }

  Future<void> clearAll() async {
    // Best-effort: initialize if not yet initialized
    if (_db == null) {
      await init();
    }
    final db = _db;
    if (db == null) return;
    await db.transaction((txn) async {
      await txn.delete('attempts');
      await txn.delete('sessions');
    });
  }

  Future<void> clearByMode(SessionMode mode) async {
    if (_db == null) {
      await init();
    }
    final db = _db;
    if (db == null) return;
    final modeName = mode.name;
    await db.transaction((txn) async {
      await txn.delete('attempts', where: 'mode = ?', whereArgs: [modeName]);
      await txn.delete('sessions', where: 'mode = ?', whereArgs: [modeName]);
    });
  }

  Future<void> close() async {
    try {
      await _db?.close();
    } catch (_) {}
    _db = null;
  }

  // --- Helpers for quiz modes ---

  /// Returns distinct question IDs that were answered incorrectly in practice,
  /// ordered by most recently attempted, limited by [limit]. If storage is not
  /// available or none found, returns an empty list.
  Future<List<String>> recentlyIncorrectQuestionIds({int limit = 50}) async {
    final db = _db;
    if (db == null) return const <String>[];
    final rows = await db.rawQuery('''
      SELECT questionId, MAX(timestamp) as ts
      FROM attempts
      WHERE isCorrect = 0 AND mode = ?
      GROUP BY questionId
      ORDER BY ts DESC
      LIMIT ?
    ''', [SessionMode.practice.name, limit]);
    return rows.map((r) => (r['questionId'] as String?) ?? '').where((id) => id.isNotEmpty).toList();
  }

  // --- Achievements persistence ---

  Future<bool> isAchievementUnlocked(String id) async {
    final db = _db;
    if (db == null) return false;
    final rows = await db.query('achievements', columns: ['id'], where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isNotEmpty;
  }

  Future<void> unlockAchievement(String id, {DateTime? when}) async {
    final db = _db;
    if (db == null) return;
    await db.insert(
      'achievements',
      {
        'id': id,
        'unlockedAt': (when ?? DateTime.now()).millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<String>> unlockedAchievementIds() async {
    final db = _db;
    if (db == null) return const <String>[];
    final rows = await db.query('achievements', columns: ['id']);
    return rows.map((r) => r['id'] as String).toList();
  }
}
