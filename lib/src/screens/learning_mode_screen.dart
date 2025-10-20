import 'package:flutter/material.dart';

import '../data/question_repository.dart';
import '../models/question.dart';
import '../models/topic.dart';
import 'learning_session_screen.dart';
import '../../l10n/app_localizations.dart';

class LearningModeScreen extends StatefulWidget {
  final String? stateCode;
  final String? stateLabel;

  const LearningModeScreen({super.key, this.stateCode, this.stateLabel});

  @override
  State<LearningModeScreen> createState() => _LearningModeScreenState();
}

class _LearningModeScreenState extends State<LearningModeScreen> {
  final QuestionRepository _repository = QuestionRepository();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
  await _repository.init(languageCode: QuestionRepository.defaultLanguageCode);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _openSession({required List<Question> questions, required String title, String? stateCode}) {
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).no_questions)),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LearningSessionScreen(questions: questions, title: title, stateCode: stateCode),
      ),
    );
  }

  IconData _iconForTopicId(String id) {
    switch (id) {
      case 'democracy':
        // Democracy, voting, participation
        return Icons.how_to_vote; // changed from gavel to voting icon
      case 'history_responsibility':
        // History and responsibility
        return Icons.history_edu_outlined; // alternatives: museum_outlined
      case 'people_society':
        // People and society
        return Icons.groups_outlined; // alternatives: diversity_3_outlined
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildModeTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
        enabled: onTap != null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).learning_title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).error_loading_questions,
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
                  child: Text(AppLocalizations.of(context).retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final List<Question> generalQuestions = _repository.generalQuestions;
    final List<Topic> topics = _repository.topics;

    final stateCode = widget.stateCode;
    final List<Question> stateQuestions =
        stateCode != null ? _repository.getStateQuestions(stateCode) : const <Question>[];

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).learning_title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(AppLocalizations.of(context).learning_intro, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).learning_general, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildModeTile(
              icon: Icons.list_alt,
              title: AppLocalizations.of(context).learning_all_questions,
              subtitle: stateCode != null
                  ? AppLocalizations.of(context).questions_count(generalQuestions.length + stateQuestions.length)
                  : AppLocalizations.of(context).questions_count(generalQuestions.length),
              onTap: generalQuestions.isNotEmpty
                  ? () {
                      final combined = <Question>[];
                      combined.addAll(generalQuestions);
                      if (stateCode != null) combined.addAll(stateQuestions);
                      _openSession(questions: combined, title: AppLocalizations.of(context).learning_all_questions, stateCode: stateCode);
                    }
                  : null,
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context).learning_topics, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (topics.isEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(AppLocalizations.of(context).learning_no_topics),
                ),
              )
            else
              ...topics.where((t) => t.id != 'state').map((topic) {
                final questions = _repository.getQuestionsByTopic(topic.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildModeTile(
                    icon: _iconForTopicId(topic.id),
                    title: topic.title,
                    subtitle: AppLocalizations.of(context).questions_count(questions.length),
                    onTap: questions.isNotEmpty
                            ? () => _openSession(
                                  questions: questions,
                                  title: topic.title,
                                  stateCode: null,
                                )
                        : null,
                  ),
                );
              }),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context).learning_state, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (stateCode == null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(AppLocalizations.of(context).learning_no_state_selected),
                  subtitle: Text(AppLocalizations.of(context).learning_select_state_hint),
                ),
              )
            else if (stateQuestions.isEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(widget.stateLabel ?? stateCode),
                  subtitle: Text(AppLocalizations.of(context).learning_no_state_questions),
                ),
              )
            else
              _buildModeTile(
                icon: Icons.flag_outlined,
                title: widget.stateLabel ?? stateCode,
                subtitle: AppLocalizations.of(context).questions_count(stateQuestions.length),
                onTap: () => _openSession(
                  questions: stateQuestions,
                  title: widget.stateLabel ?? stateCode,
                  stateCode: stateCode,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
