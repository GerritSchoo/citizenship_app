import 'package:citizenship_app/screens/main_menu_screen.dart';
import 'package:flutter/material.dart';

class SetupScreen extends StatelessWidget {
  final String selectedLanguage;
  final String selectedState;

  const SetupScreen({
    Key? key,
    required this.selectedLanguage,
    required this.selectedState,
  }) : super(key: key);

  // Translations for the screen content
  static const Map<String, Map<String, String>> translations = {
    'de': {
      'title': 'Du bist startklar!',
      'subtitle': 'Das kannst du tun:',
      'learn_title': 'Lernen mit Lernkarten',
      'learn_subtitle': 'Meistere alle Fragen mit einem intelligenten System zur wiederholten Wiederholung.',
      'test_title': 'Testprüfungen ablegen',
      'test_subtitle': 'Simuliere den echten Test, um deine Bereitschaft zu überprüfen.',
      'progress_title': 'Verfolge deinen Fortschritt',
      'progress_subtitle': 'Beobachte, wie dein Wissen wächst und verdiene Erfolge.',
      'start_button': 'Lernen starten',
    },
    'en': {
      'title': 'You are ready to start!',
      'subtitle': 'Here\'s what you can do:',
      'learn_title': 'Learn with flashcards',
      'learn_subtitle': 'Master all questions with an intelligent system for spaced repetition.',
      'test_title': 'Take mock exams',
      'test_subtitle': 'Simulate the real test to check your readiness.',
      'progress_title': 'Track your progress',
      'progress_subtitle': 'Watch your knowledge grow and earn achievements.',
      'start_button': 'Start Learning',
    },
    // TODO: Add more languages
  };

  @override
  Widget build(BuildContext context) {
    final texts = translations[selectedLanguage] ?? translations['en']!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF10182A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                texts['title']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                texts['subtitle']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              _buildOptionCard(
                context,
                icon: Icons.collections_bookmark,
                title: texts['learn_title']!,
                subtitle: texts['learn_subtitle']!,
                iconColor: Colors.lightBlueAccent,
              ),
              const SizedBox(height: 20),
              _buildOptionCard(
                context,
                icon: Icons.assignment,
                title: texts['test_title']!,
                subtitle: texts['test_subtitle']!,
                iconColor: Colors.orangeAccent,
              ),
              const SizedBox(height: 20),
              _buildOptionCard(
                context,
                icon: Icons.show_chart,
                title: texts['progress_title']!,
                subtitle: texts['progress_subtitle']!,
                iconColor: Colors.greenAccent,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MainMenuScreen(
                        selectedLanguage: selectedLanguage,
                        selectedState: selectedState,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: const Color(0xFF10182A),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(texts['start_button']!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF232B3E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A4256), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
