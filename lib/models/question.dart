class Question {
  final String id;
  final String question_de;
  final String question_en;
  final String question_es;
  final String question_fr;
  final String question_el;
  final String question_it;
  final String question_pl;
  final String question_ru;
  final String question_hu;
  final String question_cs;
  final String question_tr;
  final String question_ar;
  final List<String> options_de;
  final List<String> options_en;
  final List<String> options_es;
  final List<String> options_fr;
  final List<String> options_el;
  final List<String> options_it;
  final List<String> options_pl;
  final List<String> options_ru;
  final List<String> options_hu;
  final List<String> options_cs;
  final List<String> options_tr;
  final List<String> options_ar;
  final int correctOptionIndex;
  final String? state;

  Question({
    required this.id,
    required this.question_de,
    required this.question_en,
    required this.question_es,
    required this.question_fr,
    required this.question_el,
    required this.question_it,
    required this.question_pl,
    required this.question_ru,
    required this.question_hu,
    required this.question_cs,
    required this.question_tr,
    required this.question_ar,
    required this.options_de,
    required this.options_en,
    required this.options_es,
    required this.options_fr,
    required this.options_el,
    required this.options_it,
    required this.options_pl,
    required this.options_ru,
    required this.options_hu,
    required this.options_cs,
    required this.options_tr,
    required this.options_ar,
    required this.correctOptionIndex,
    this.state,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question_de: json['question_de'],
      question_en: json['question_en'],
      question_es: json['question_es'],
      question_fr: json['question_fr'],
      question_el: json['question_el'],
      question_it: json['question_it'],
      question_pl: json['question_pl'],
      question_ru: json['question_ru'],
      question_hu: json['question_hu'],
      question_cs: json['question_cs'],
      question_tr: json['question_tr'],
      question_ar: json['question_ar'],
      options_de: List<String>.from(json['options_de']),
      options_en: List<String>.from(json['options_en']),
      options_es: List<String>.from(json['options_es']),
      options_fr: List<String>.from(json['options_fr']),
      options_el: List<String>.from(json['options_el']),
      options_it: List<String>.from(json['options_it']),
      options_pl: List<String>.from(json['options_pl']),
      options_ru: List<String>.from(json['options_ru']),
      options_hu: List<String>.from(json['options_hu']),
      options_cs: List<String>.from(json['options_cs']),
      options_tr: List<String>.from(json['options_tr']),
      options_ar: List<String>.from(json['options_ar']),
      correctOptionIndex: json['correct_option_index'],
      state: json['state'],
    );
  }
}
