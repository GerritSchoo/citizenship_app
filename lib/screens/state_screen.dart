import 'package:flutter/material.dart';

class StateScreen extends StatelessWidget {
  final String selectedLanguage;
  final void Function(String) onStateSelected;
  const StateScreen({Key? key, required this.selectedLanguage, required this.onStateSelected}) : super(key: key);

  // List of German states and their translations
  static const states = [
    {'de': 'Baden-Württemberg', 'en': 'Baden-Württemberg', 'es': 'Baden-Wurtemberg', 'fr': 'Bade-Wurtemberg'},
    {'de': 'Bayern', 'en': 'Bavaria', 'es': 'Baviera', 'fr': 'Bavière'},
    {'de': 'Berlin', 'en': 'Berlin', 'es': 'Berlín', 'fr': 'Berlin'},
    {'de': 'Brandenburg', 'en': 'Brandenburg', 'es': 'Brandeburgo', 'fr': 'Brandebourg'},
    {'de': 'Bremen', 'en': 'Bremen', 'es': 'Bremen', 'fr': 'Brême'},
    {'de': 'Hamburg', 'en': 'Hamburg', 'es': 'Hamburgo', 'fr': 'Hambourg'},
    {'de': 'Hessen', 'en': 'Hesse', 'es': 'Hesse', 'fr': 'Hesse'},
    {'de': 'Mecklenburg-Vorpommern', 'en': 'Mecklenburg-Western Pomerania', 'es': 'Mecklemburgo-Pomerania Occidental', 'fr': 'Mecklembourg-Poméranie-Occidentale'},
    {'de': 'Niedersachsen', 'en': 'Lower Saxony', 'es': 'Baja Sajonia', 'fr': 'Basse-Saxe'},
    {'de': 'Nordrhein-Westfalen', 'en': 'North Rhine-Westphalia', 'es': 'Renania del Norte-Westfalia', 'fr': 'Rhénanie-du-Nord-Westphalie'},
    {'de': 'Rheinland-Pfalz', 'en': 'Rhineland-Palatinate', 'es': 'Renania-Palatinado', 'fr': 'Rhénanie-Palatinat'},
    {'de': 'Saarland', 'en': 'Saarland', 'es': 'Sarre', 'fr': 'Sarre'},
    {'de': 'Sachsen', 'en': 'Saxony', 'es': 'Sajonia', 'fr': 'Saxe'},
    {'de': 'Sachsen-Anhalt', 'en': 'Saxony-Anhalt', 'es': 'Sajonia-Anhalt', 'fr': 'Saxe-Anhalt'},
    {'de': 'Schleswig-Holstein', 'en': 'Schleswig-Holstein', 'es': 'Schleswig-Holstein', 'fr': 'Schleswig-Holstein'},
    {'de': 'Thüringen', 'en': 'Thuringia', 'es': 'Turingia', 'fr': 'Thuringe'},
  ];

  static const Map<String, String> pageTitle = {
    'de': 'In welchem Bundesland sind Sie?',
    'en': 'Which federal state are you in?',
    'es': '¿En qué estado federado se encuentra?',
    'fr': 'Dans quel État fédéré vous trouvez-vous ?',
    'el': 'Σε ποιο ομοσπονδιακό κράτος βρίσκεστε;',
    'it': 'In quale stato federale ti trovi?',
    'pl': 'W jakim landzie się znajdujesz?',
    'ru': 'В какой федеральной земле вы находитесь?',
    'hu': 'Melyik szövetségi tartományban van?',
    'cs': 'Ve které spolkové zemi se nacházíte?',
    'tr': 'Hangi federal eyalettesiniz?',
    'ar': 'في أي ولاية فيدرالية أنت؟',
  };

  // TODO: Add more translations for other languages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10182A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                pageTitle[selectedLanguage] ?? pageTitle['en']!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: states.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final state = states[index];
                    return ElevatedButton(
                      onPressed: () => onStateSelected(state['de']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF232B3E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: Color(0xFF3A4256), width: 2),
                        ),
                        elevation: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(state['de']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(state[selectedLanguage] ?? state['en']!, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
