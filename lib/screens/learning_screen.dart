import 'package:flutter/material.dart';
import 'package:citizenship_app/models/question.dart';

class LearningScreen extends StatefulWidget {
  final String selectedLanguage;
  final List<Question> questions;

  const LearningScreen({
    Key? key,
    required this.selectedLanguage,
    required this.questions,
  }) : super(key: key);

  @override
  _LearningScreenState createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  int _currentIndex = 0;
  String? _selectedOption;

  void _onOptionSelected(String option) {
    setState(() {
      _selectedOption = option;
    });

    // TODO: Add logic for correct/incorrect answer and spaced repetition
  }

  String _getQuestionText(Question question, String language) {
    switch (language) {
      case 'de':
        return question.question_de;
      case 'en':
        return question.question_en;
      case 'es':
        return question.question_es;
      case 'fr':
        return question.question_fr;
      case 'el':
        return question.question_el;
      case 'it':
        return question.question_it;
      case 'pl':
        return question.question_pl;
      case 'ru':
        return question.question_ru;
      case 'hu':
        return question.question_hu;
      case 'cs':
        return question.question_cs;
      case 'tr':
        return question.question_tr;
      case 'ar':
        return question.question_ar;
      default:
        return question.question_en;
    }
  }

  List<String> _getOptions(Question question, String language) {
    switch (language) {
      case 'de':
        return question.options_de;
      case 'en':
        return question.options_en;
      case 'es':
        return question.options_es;
      case 'fr':
        return question.options_fr;
      case 'el':
        return question.options_el;
      case 'it':
        return question.options_it;
      case 'pl':
        return question.options_pl;
      case 'ru':
        return question.options_ru;
      case 'hu':
        return question.options_hu;
      case 'cs':
        return question.options_cs;
      case 'tr':
        return question.options_tr;
      case 'ar':
        return question.options_ar;
      default:
        return question.options_en;
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];
    final questionText = _getQuestionText(question, widget.selectedLanguage);
    final options = _getOptions(question, widget.selectedLanguage);
    final options_de = _getOptions(question, 'de');

    return Scaffold(
      backgroundColor: const Color(0xFF10182A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10182A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.questions.length}',
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.questions.length,
            backgroundColor: const Color(0xFF3A4256),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${question.id}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              question.question_de,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              questionText,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 40),
            ...List.generate(options.length, (index) {
              final isSelected = _selectedOption == options_de[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildOptionButton(
                  context,
                  option_de: options_de[index],
                  option_lang: options[index],
                  isSelected: isSelected,
                  onTap: () => _onOptionSelected(options_de[index]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required String option_de,
    required String option_lang,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF232B3E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.greenAccent : const Color(0xFF3A4256),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              option_de,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (option_lang.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                option_lang,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
