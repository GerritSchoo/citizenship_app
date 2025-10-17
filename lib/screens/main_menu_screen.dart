import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';
import 'learning_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final String selectedLanguage;
  final String selectedState;

  const MainMenuScreen({
    Key? key,
    required this.selectedLanguage,
    required this.selectedState,
  }) : super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  List<Question> _questions = [];

  // Translations for the screen content
  static const Map<String, Map<String, String>> translations = {
    'de': {
      'title': 'Einbürgerungstest',
      'subtitle_prefix': 'Trainer für',
      'learn_button': 'Lernen',
      'learn_button_subtitle': 'Karten',
      'quiz_button': 'Quiz',
      'exam_button': 'Probe-Prüfung',
      'progress_title': 'Dein Lernfortschritt',
      'progress_status': 'gemeistert',
    },
    'en': {
      'title': 'Citizenship Test',
      'subtitle_prefix': 'Trainer for',
      'learn_button': 'Learn',
      'learn_button_subtitle': 'cards',
      'quiz_button': 'Quiz',
      'exam_button': 'Mock Exam',
      'progress_title': 'Your Learning Progress',
      'progress_status': 'mastered',
    },
    'es': {
      'title': 'Test de Ciudadanía',
      'subtitle_prefix': 'Entrenador para',
      'learn_button': 'Aprender',
      'learn_button_subtitle': 'tarjetas',
      'quiz_button': 'Quiz',
      'exam_button': 'Examen de prueba',
      'progress_title': 'Tu Progreso de Aprendizaje',
      'progress_status': 'dominadas',
    },
    'fr': {
      'title': 'Test de Citoyenneté',
      'subtitle_prefix': 'Entraîneur pour',
      'learn_button': 'Apprendre',
      'learn_button_subtitle': 'cartes',
      'quiz_button': 'Quiz',
      'exam_button': 'Examen blanc',
      'progress_title': 'Votre Progression d\'Apprentissage',
      'progress_status': 'maîtrisé',
    },
    'el': {
      'title': 'Τεστ Ιθαγένειας',
      'subtitle_prefix': 'Εκπαιδευτής για',
      'learn_button': 'Μάθετε',
      'learn_button_subtitle': 'κάρτες',
      'quiz_button': 'Κουίζ',
      'exam_button': 'Δοκιμαστικό Τεστ',
      'progress_title': 'Η Πρόοδός σας',
      'progress_status': 'κατακτημένα',
    },
    'it': {
      'title': 'Test di Cittadinanza',
      'subtitle_prefix': 'Trainer per',
      'learn_button': 'Imparare',
      'learn_button_subtitle': 'carte',
      'quiz_button': 'Quiz',
      'exam_button': 'Esame di prova',
      'progress_title': 'I Tuoi Progressi di Apprendimento',
      'progress_status': 'padroneggiate',
    },
    'pl': {
      'title': 'Test na Obywatelstwo',
      'subtitle_prefix': 'Trener dla',
      'learn_button': 'Uczyć się',
      'learn_button_subtitle': 'karty',
      'quiz_button': 'Quiz',
      'exam_button': 'Egzamin próbny',
      'progress_title': 'Twoje Postępy w Nauce',
      'progress_status': 'opanowane',
    },
    'ru': {
      'title': 'Тест на гражданство',
      'subtitle_prefix': 'Тренер для',
      'learn_button': 'Учить',
      'learn_button_subtitle': 'карточки',
      'quiz_button': 'викторина',
      'exam_button': 'Пробный экзамен',
      'progress_title': 'Ваш Прогресс в Обучении',
      'progress_status': 'освоено',
    },
    'hu': {
      'title': 'Állampolgársági Teszt',
      'subtitle_prefix': 'Tréner',
      'learn_button': 'Tanulni',
      'learn_button_subtitle': 'kártyák',
      'quiz_button': 'Kvíz',
      'exam_button': 'Próbavizsga',
      'progress_title': 'Tanulási Folyamatod',
      'progress_status': 'elsajátítva',
    },
    'cs': {
      'title': 'Test Občanství',
      'subtitle_prefix': 'Trenér pro',
      'learn_button': 'Učit se',
      'learn_button_subtitle': 'karty',
      'quiz_button': 'Kvíz',
      'exam_button': 'Zkušební zkouška',
      'progress_title': 'Váš Pokrok v Učení',
      'progress_status': 'zvládnuto',
    },
    'tr': {
      'title': 'Vatandaşlık Testi',
      'subtitle_prefix': 'Eğitmen',
      'learn_button': 'Öğrenmek',
      'learn_button_subtitle': 'kartlar',
      'quiz_button': 'Sınav',
      'exam_button': 'Deneme Sınavı',
      'progress_title': 'Öğrenme İlerlemeniz',
      'progress_status': 'ustalaşıldı',
    },
    'ar': {
      'title': 'اختبار المواطنة',
      'subtitle_prefix': 'مدرب ل',
      'learn_button': 'تعلم',
      'learn_button_subtitle': 'بطاقات',
      'quiz_button': 'اختبار',
      'exam_button': 'امتحان تجريبي',
      'progress_title': 'تقدمك في التعلم',
      'progress_status': 'متقن',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String response = await rootBundle.loadString('assets/questions.json');
    final data = await json.decode(response);
    setState(() {
      _questions = (data['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final texts = translations[widget.selectedLanguage] ?? translations['en']!;
    final stateName = widget.selectedState;

    return Scaffold(
      backgroundColor: const Color(0xFF10182A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
            onPressed: () {
              // TODO: Handle notification tap
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () {
              // TODO: Handle menu tap
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              texts['title']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${texts['subtitle_prefix']!} $stateName',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 48),
            _buildMenuButton(
              text: texts['learn_button']!,
              subtitle: '${_questions.length} ${texts['learn_button_subtitle']!}',
              color: Colors.black,
              textColor: Colors.white,
              onPressed: () {
                if (_questions.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LearningScreen(
                        questions: _questions,
                        selectedLanguage: widget.selectedLanguage,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              text: texts['quiz_button']!,
              color: const Color(0xFFD32F2F), // Red color
              textColor: Colors.white,
              onPressed: () {},
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              text: texts['exam_button']!,
              color: const Color(0xFFFFC107), // Yellow/Gold color
              textColor: Colors.black,
              onPressed: () {},
            ),
            const SizedBox(height: 40),
            _buildProgressCard(context, texts),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String text,
    String? subtitle,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 80),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, Map<String, String> texts) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF232B3E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                texts['progress_title']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '0 / ${_questions.length} ${texts['progress_status']!}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.0, // TODO: Make this dynamic
              backgroundColor: Color(0xFF3A4256),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
