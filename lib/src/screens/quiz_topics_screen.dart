import 'package:flutter/material.dart';

import '../data/question_repository.dart';
import '../models/question.dart';
import '../models/topic.dart';
import '../../l10n/app_localizations.dart';
import '../core/quiz_mode.dart';
import 'quiz_screen.dart';
import '../core/prefs.dart';
import '../data/states.dart';
import '../theme/app_theme.dart';

class QuizTopicsScreen extends StatefulWidget {
  const QuizTopicsScreen({super.key});

  @override
  State<QuizTopicsScreen> createState() => _QuizTopicsScreenState();
}

class _QuizTopicsScreenState extends State<QuizTopicsScreen> {
  final QuestionRepository _repository = QuestionRepository();
  bool _isLoading = true;
  String? _error;
  String? _stateCode;
  String? _stateLabel;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _repository.init(languageCode: QuestionRepository.defaultLanguageCode);
      final code = await AppPrefs.getSelectedState();
      String? label;
      if (code != null) {
        final match = states.firstWhere((s) => s['code'] == code, orElse: () => {});
        label = match['label'];
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = null;
        _stateCode = code;
        _stateLabel = label;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  IconData _iconForTopicId(String id) {
    switch (id) {
      case 'democracy':
        return Icons.how_to_vote;
      case 'history_responsibility':
        return Icons.history_edu_outlined;
      case 'people_society':
        return Icons.groups_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
        enabled: onTap != null,
      ),
    );
  }

  void _startTopics(List<String> topicIds) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(config: QuizConfig.topics(topicIds: topicIds)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quiz_mode_topics)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.error_loading_questions,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _loadData();
                  },
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<Question> generalQuestions = _repository.generalQuestions;
    final List<Topic> topics = _repository.topics.where((t) => t.id != 'state').toList();
    final stateCode = _stateCode;
    final List<Question> stateQuestions = stateCode != null ? _repository.getStateQuestions(stateCode) : const <Question>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quiz_mode_topics)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.learning_intro, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildTile(
              icon: Icons.list_alt,
              iconColor: colorScheme.primary,
              title: l10n.learning_all_questions,
              subtitle: l10n.questions_count(generalQuestions.length + stateQuestions.length),
              onTap: (generalQuestions.isNotEmpty || stateQuestions.isNotEmpty)
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const QuizScreen(), // combined: general + state (if selected)
                        ),
                      )
                  : null,
            ),
            const SizedBox(height: 24),
            Text(l10n.learning_topics, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (topics.isEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.learning_no_topics),
                ),
              )
            else ...topics.map((topic) {
              final count = _repository.getQuestionsByTopic(topic.id).length;
              final Color topicColor;
              switch (topic.id) {
                case 'democracy':
                  topicColor = colorScheme.primary;
                  break;
                case 'history_responsibility':
                  topicColor = colorScheme.secondary;
                  break;
                case 'people_society':
                  topicColor = colorScheme.tertiary;
                  break;
                default:
                  topicColor = colorScheme.primary;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTile(
                  icon: _iconForTopicId(topic.id),
                  iconColor: topicColor,
                  title: topic.title,
                  subtitle: l10n.questions_count(count),
                  onTap: count > 0 ? () => _startTopics([topic.id]) : null,
                ),
              );
            }),
            const SizedBox(height: 24),
            Text(l10n.learning_state, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (stateCode == null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(l10n.learning_no_state_selected),
                  subtitle: Text(l10n.learning_select_state_hint),
                ),
              )
            else if (stateQuestions.isEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(_stateLabel ?? stateCode),
                  subtitle: Text(l10n.learning_no_state_questions),
                ),
              )
            else
              _buildTile(
                icon: Icons.flag_outlined,
                iconColor: colorScheme.secondary,
                title: _stateLabel ?? stateCode,
                subtitle: l10n.questions_count(stateQuestions.length),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(config: QuizConfig.state()),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
