import 'package:flutter/material.dart';
import '../analytics/progress_repository.dart';
import '../widgets/exam_result_indicator.dart';
import '../data/question_repository.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<_ProgressData> _future;
  bool includePractice = true;
  bool includeExam = true;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProgressData> _load() async {
    await ProgressRepository.instance.init();
    final repo = QuestionRepository();
    await repo.init();
  final overall = await ProgressRepository.instance.overallStats(includePractice: includePractice, includeExam: includeExam);
  final daily = await ProgressRepository.instance.dailyAccuracy(includePractice: includePractice, includeExam: includeExam);
  final state = await ProgressRepository.instance.stateStats(includePractice: includePractice, includeExam: includeExam);
  final rawTopicStats = await ProgressRepository.instance.topicAccuracy(includePractice: includePractice, includeExam: includeExam);
  final passRate = includeExam ? await ProgressRepository.instance.examPassRate() : 0.0;
  final exams = includeExam ? await ProgressRepository.instance.examResults(limit: 5) : <ExamResult>[];
    final titles = {for (final t in repo.topics) if (t.id != 'state') t.id: t.title};
    final rawMap = {for (final s in rawTopicStats) s.topicId: s};
    final normalized = <TopicStat>[];
    for (final t in repo.topics) {
      if (t.id == 'state') continue; // exclude state from per-topic list; handled separately
      final s = rawMap[t.id];
      if (s != null) {
        normalized.add(s);
      } else {
        normalized.add(TopicStat(topicId: t.id, correct: 0, total: 0));
      }
    }
    // Append any topics not known to repository (fallback)
    for (final entry in rawMap.entries) {
      if (!titles.containsKey(entry.key) && entry.key != 'state') {
        normalized.add(entry.value);
      }
    }
    return _ProgressData(overall: overall, state: state, daily: daily, topics: normalized, topicTitles: titles, passRate: passRate, exams: exams);
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analyse')),
      body: FutureBuilder<_ProgressData>(
        future: _future,
        builder: (ctx, snap) {
          if (!snap.hasData) {
            if (snap.hasError) return Center(child: Text('Fehler: ${snap.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                width: double.infinity,
                child: Builder(builder: (context) {
                  final selected = <String>{}
                    ..addAll(includePractice ? ['practice'] : const [])
                    ..addAll(includeExam ? ['exam'] : const []);
                  return SegmentedButton<String>(
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(value: 'practice', label: Text('Lernen/Quiz')),
                      ButtonSegment<String>(value: 'exam', label: Text('Prüfung')),
                    ],
                    selected: selected,
                    multiSelectionEnabled: true,
                    showSelectedIcon: false,
                    onSelectionChanged: (newSel) {
                      includePractice = newSel.contains('practice');
                      includeExam = newSel.contains('exam');
                      _refresh();
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              _KpiRow(overall: data.overall),
              const SizedBox(height: 16),
              _Section('Gesamtgenauigkeit', _OverallProgressBar(stat: data.overall)),
              const SizedBox(height: 24),
              Builder(builder: (context) {
                final extendedTitles = Map<String, String>.from(data.topicTitles);
                extendedTitles['__state__'] = 'Bundesland-Fragen';
                final extendedStats = List<TopicStat>.from(data.topics)
                  ..add(TopicStat(topicId: '__state__', correct: data.state.correct, total: data.state.total));
                return _Section('Genauigkeit je Thema', _TopicProgressList(stats: extendedStats, titles: extendedTitles));
              }),
              const SizedBox(height: 24),
              if (includeExam) ...[
                _Section('Bestehensquote Prüfungen', _PassRateBar(rate: data.passRate)),
                const SizedBox(height: 16),
                _Section('Letzte Prüfungen', _ExamList(exams: data.exams)),
              ],
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section(this.title, this.child);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _KpiRow extends StatelessWidget {
  final OverallStat overall;
  const _KpiRow({required this.overall});

  @override
  Widget build(BuildContext context) {
    String time(int ms) {
      if (ms < 1000) return '${ms}ms';
      final s = (ms / 1000).toStringAsFixed(1);
      return '$s s';
    }
    return SizedBox(
      height: 120,
      child: Row(children: [
        Expanded(child: _KpiCard(label: 'Fragen bearbeitet', value: '${overall.total}')),
        const SizedBox(width: 12),
        Expanded(child: _KpiCard(label: 'Ø Zeit', value: time(overall.avgTimeMs))),
      ]),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  const _KpiCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverallProgressBar extends StatelessWidget {
  final OverallStat stat;
  const _OverallProgressBar({required this.stat});
  @override
  Widget build(BuildContext context) {
    final accuracy = stat.accuracy.clamp(0.0, 1.0);
    final pct = (accuracy * 100).toStringAsFixed(0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Insgesamt', style: Theme.of(context).textTheme.labelLarge)),
                Text('$pct%'),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: accuracy.isNaN ? 0 : accuracy,
                minHeight: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicProgressList extends StatelessWidget {
  final List<TopicStat> stats;
  final Map<String, String> titles;
  const _TopicProgressList({required this.stats, required this.titles});
  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Noch keine Daten', style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }
    return Column(
      children: [
        ...stats.map((s) {
          final accuracy = s.accuracy.clamp(0.0, 1.0);
          final pct = (accuracy * 100).toStringAsFixed(0);
          final title = titles[s.topicId] ?? s.topicId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Text('$pct%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: accuracy.isNaN ? 0 : accuracy,
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ProgressData {
  final OverallStat overall;
  final OverallStat state;
  final List<DailyStat> daily;
  final List<TopicStat> topics;
  final Map<String, String> topicTitles;
  final double passRate;
  final List<ExamResult> exams;
  _ProgressData({
    required this.overall,
    required this.state,
    required this.daily,
    required this.topics,
    required this.topicTitles,
    required this.passRate,
    required this.exams,
  });
}

class _PassRateBar extends StatelessWidget {
  final double rate;
  const _PassRateBar({required this.rate});
  @override
  Widget build(BuildContext context) {
    final pct = (rate.clamp(0.0, 1.0) * 100).toStringAsFixed(0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Pass-Rate', style: Theme.of(context).textTheme.labelLarge)),
                Text('$pct%'),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: rate.isNaN ? 0 : rate.clamp(0.0, 1.0),
                minHeight: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamList extends StatelessWidget {
  final List<ExamResult> exams;
  const _ExamList({required this.exams});
  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Noch keine Prüfungen', style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }
    return Column(
      children: exams.map((e) {
        final date = e.startedAt;
        final title = '${date.day}.${date.month}.${date.year}';
        final subtitle = e.completed
            ? '${e.correct}/${e.total} • ${(e.durationMs / 60000).toStringAsFixed(1)} min'
            : 'nicht abgeschlossen';
        return Card(
          child: ListTile(
            leading: ExamResultIcon(correct: e.correct),
            title: Text(title),
            subtitle: Text(subtitle),
          ),
        );
      }).toList(),
    );
  }
}
