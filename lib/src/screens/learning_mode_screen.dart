import 'package:flutter/material.dart';

import '../data/question_repository.dart';
import '../models/question.dart';
import '../models/topic.dart';
import 'learning_session_screen.dart';

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
      await _repository.init();
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

  void _openSession({required List<Question> questions, required String title}) {
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine Fragen verfugbar.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LearningSessionScreen(questions: questions, title: title),
      ),
    );
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
        appBar: AppBar(title: const Text('Lernmodus')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Fehler beim Laden der Fragen.',
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
                  child: const Text('Erneut versuchen'),
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
      appBar: AppBar(title: const Text('Lernmodus')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Wahle einen Modus zum Lernen.', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Text('Allgemein', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildModeTile(
              icon: Icons.list_alt,
              title: 'Alle Fragen',
              subtitle: '${generalQuestions.length} Fragen',
              onTap: generalQuestions.isNotEmpty
                  ? () => _openSession(
                        questions: generalQuestions,
                        title: 'Alle Fragen',
                      )
                  : null,
            ),
            const SizedBox(height: 24),
            Text('Themen', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (topics.isEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Keine Themen verfugbar.'),
                ),
              )
            else
              ...topics.map((topic) {
                final questions = _repository.getQuestionsByTopic(topic.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildModeTile(
                    icon: Icons.category_outlined,
                    title: topic.title,
                    subtitle: '${questions.length} Fragen',
                    onTap: questions.isNotEmpty
                        ? () => _openSession(
                              questions: questions,
                              title: topic.title,
                            )
                        : null,
                  ),
                );
              }),
            const SizedBox(height: 24),
            Text('Bundesland', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (stateCode == null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Kein Bundesland ausgewahlt'),
                  subtitle: const Text(
                    'Wahle auf dem Home Screen ein Bundesland, um Landesfragen zu lernen.',
                  ),
                ),
              )
            else if (stateQuestions.isEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(widget.stateLabel ?? stateCode),
                  subtitle: const Text('Keine Landesfragen verfugbar.'),
                ),
              )
            else
              _buildModeTile(
                icon: Icons.flag_outlined,
                title: widget.stateLabel ?? stateCode,
                subtitle: '${stateQuestions.length} Fragen',
                onTap: () => _openSession(
                  questions: stateQuestions,
                  title: widget.stateLabel ?? stateCode,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
