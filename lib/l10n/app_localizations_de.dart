// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get app_title => 'Einbürgerungshelfer';

  @override
  String get loading => 'Lädt…';

  @override
  String get menu => 'Menü';

  @override
  String get home_header_title => 'Einbürgerungshelfer';

  @override
  String get home_header_subtitle => 'Lernen, üben und die Prüfung bestehen';

  @override
  String get home_no_state => 'Kein Bundesland ausgewählt';

  @override
  String get action_learn => 'Lernen';

  @override
  String get action_learn_sem => 'Lernen öffnen';

  @override
  String get action_quiz => 'Quiz';

  @override
  String get action_quiz_sem => 'Quiz öffnen';

  @override
  String get action_exam => 'Prüfung';

  @override
  String get action_exam_sem => 'Prüfung öffnen';

  @override
  String get action_analytics => 'Analyse';

  @override
  String get action_analytics_sem => 'Analyse öffnen';

  @override
  String get menu_language => 'App-Sprache';

  @override
  String get menu_content_language => 'Fragen-Sprache';

  @override
  String get menu_state => 'Bundesland';

  @override
  String get menu_theme => 'Design';

  @override
  String get menu_analyse => 'Analyse';

  @override
  String get menu_privacy => 'Datenschutzerklärung';

  @override
  String get menu_imprint => 'Impressum';

  @override
  String snack_state_selected(Object state) {
    return 'Bundesland gewählt: $state';
  }

  @override
  String snack_lang_set(Object lang) {
    return 'Sprache gesetzt: $lang';
  }

  @override
  String snack_app_lang_set(Object lang) {
    return 'App-Sprache gesetzt: $lang';
  }

  @override
  String snack_content_lang_set(Object lang) {
    return 'Fragen-Sprache gesetzt: $lang';
  }

  @override
  String get theme_system => 'System';

  @override
  String get theme_light => 'Hell';

  @override
  String get theme_dark => 'Dunkel';

  @override
  String get progress_title => 'Analyse';

  @override
  String get progress_overall_accuracy => 'Gesamtgenauigkeit';

  @override
  String get progress_topic_accuracy => 'Genauigkeit je Thema';

  @override
  String get progress_state_questions => 'Bundesland-Fragen';

  @override
  String get progress_pass_rate => 'Bestehensquote Prüfungen';

  @override
  String get progress_last_exams => 'Letzte Prüfungen';

  @override
  String get progress_none => 'Noch keine Daten';

  @override
  String get progress_no_exams => 'Noch keine Prüfungen';

  @override
  String get progress_worked_questions => 'Fragen bearbeitet';

  @override
  String get progress_avg_time => 'Ø Zeit';

  @override
  String get exam_rules_title => 'Prüfungsregeln';

  @override
  String get exam_title => 'Prüfung';

  @override
  String get exam_submit => 'Abgeben';

  @override
  String get result_title => 'Ergebnis';

  @override
  String get result_passed => 'Bestanden';

  @override
  String get result_failed => 'Nicht bestanden';

  @override
  String get back => 'Zurück';

  @override
  String get reset_all => 'Alles zurücksetzen';

  @override
  String get reset_practice => 'Lernen/Quiz zurücksetzen';

  @override
  String get reset_exam => 'Prüfung zurücksetzen';

  @override
  String get snack_reset_all => 'Analyse: Alles zurückgesetzt';

  @override
  String get snack_reset_practice => 'Analyse: Lernen/Quiz zurückgesetzt';

  @override
  String get snack_reset_exam => 'Analyse: Prüfung zurückgesetzt';

  @override
  String get db_unavailable =>
      'Analytics-Speicher nicht verfügbar. Daten werden nicht gespeichert.';

  @override
  String get details => 'Details';

  @override
  String get close => 'Schließen';

  @override
  String get not_completed => 'nicht abgeschlossen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get back_btn => 'Zurück';

  @override
  String get next_btn => 'Weiter';

  @override
  String get done_btn => 'Fertig';

  @override
  String get yes_btn => 'Ja';

  @override
  String get no_btn => 'Nein';

  @override
  String get no_questions => 'Keine Fragen verfügbar.';

  @override
  String get setup_choose_state_title => 'Wähle dein Bundesland';

  @override
  String get setup_choose_state_subtitle =>
      'Dieses Bundesland wird für landesspezifische Fragen genutzt.';

  @override
  String get setup_state_hint => 'Bitte Bundesland wählen';

  @override
  String get setup_language_label => 'Sprache:';

  @override
  String get setup_save_continue => 'Speichern und fortfahren';

  @override
  String get learning_title => 'Lernmodus';

  @override
  String get learning_intro => 'Wähle einen Modus zum Lernen.';

  @override
  String get learning_general => 'Allgemein';

  @override
  String get learning_all_questions => 'Alle Fragen';

  @override
  String get learning_topics => 'Themen';

  @override
  String get learning_no_topics => 'Keine Themen verfügbar.';

  @override
  String get learning_state => 'Bundesland';

  @override
  String get learning_no_state_selected => 'Kein Bundesland ausgewählt';

  @override
  String get learning_select_state_hint =>
      'Wähle auf dem Home Screen ein Bundesland, um Landesfragen zu lernen.';

  @override
  String get learning_no_state_questions => 'Keine Landesfragen verfügbar.';

  @override
  String questions_count(Object count) {
    return '$count Fragen';
  }

  @override
  String get error_loading_questions => 'Fehler beim Laden der Fragen.';

  @override
  String position_label(Object index, Object total) {
    return 'Frage $index von $total';
  }

  @override
  String get quiz_title => 'Quiz';

  @override
  String get next_question => 'Nächste Frage';

  @override
  String get quiz_modes_title => 'Quizmodus wählen';

  @override
  String get quiz_mode_mistakes => 'Fehlerquiz';

  @override
  String get quiz_mode_topics => 'Themenquiz';

  @override
  String get quiz_mode_timer => 'Timerquiz';

  @override
  String get quiz_mode_mistakes_desc => 'Übe gezielt deine Fehler.';

  @override
  String get quiz_mode_topics_desc => 'Nach Themen üben.';

  @override
  String get quiz_mode_timer_desc => 'So viele wie möglich in 2 Minuten.';

  @override
  String get quiz_mode_swipe_tf => 'Swipe-Quiz';

  @override
  String get quiz_mode_swipe_tf_desc =>
      'Wische rechts wenn es richig ist, links wenn nicht.';

  @override
  String get quiz_start => 'Quiz starten';

  @override
  String get quiz_pick_topics => 'Themen auswählen';

  @override
  String get timer_results_title => 'Timer-Ergebnis';

  @override
  String get leaderboard_title => 'Bestenliste';

  @override
  String leaderboard_correct_answers(int count) {
    return '$count richtige Antworten';
  }

  @override
  String get mistakes_results_title => 'Fehler wiederholen';

  @override
  String get mistakes_retry_wrong => 'Nur falsche erneut üben';

  @override
  String get mistakes_all_correct_title => 'Alle richtig!';

  @override
  String get mock_exam_title => 'Probeprüfung';

  @override
  String get exam_confirm_title => 'Prüfung abgeben?';

  @override
  String get exam_confirm_body =>
      'Möchtest du die Prüfung jetzt abgeben? Du kannst danach nicht zurück.';

  @override
  String get exam_start => 'Prüfung starten';

  @override
  String get rule_duration => 'Dauer: 60 Minuten für den kompletten Test.';

  @override
  String get rule_composition =>
      'Zusammensetzung: 30 allgemeine Fragen + 3 länderspezifische Fragen.';

  @override
  String get rule_pass =>
      'Bestehen: Mindestens 17 richtige Antworten erforderlich.';

  @override
  String get rule_no_aids =>
      'Keine Hilfsmittel erlaubt (Bücher, Notizen, Internet).';

  @override
  String get rule_change_answers =>
      'Antworten können während der Prüfung geändert werden.';

  @override
  String get rule_auto_submit =>
      'Die Prüfung wird automatisch abgegeben, wenn die Zeit abläuft.';

  @override
  String get rule_no_return =>
      'Nach Abgabe gibt es keine Rückkehr zur Prüfung.';

  @override
  String result_correct_of_total(Object correct, Object total) {
    return 'Richtige Antworten: $correct von $total';
  }

  @override
  String result_your_answer(Object answer) {
    return 'Deine Antwort: $answer';
  }

  @override
  String result_correct_answer(Object answer) {
    return 'Richtige Antwort: $answer';
  }

  @override
  String get no_answer => 'Keine';

  @override
  String get back_to_home => 'Zurück zur Startseite';

  @override
  String get grade_sehr_gut => 'sehr gut';

  @override
  String get grade_gut => 'gut';

  @override
  String get grade_befriedigend => 'befriedigend';

  @override
  String get grade_ausreichend => 'ausreichend';

  @override
  String get grade_mangelhaft => 'mangelhaft';

  @override
  String get grade_ungenuegend => 'ungenügend';

  @override
  String achievement_unlocked(String title) {
    return 'Erfolg freigeschaltet: $title';
  }

  @override
  String get ach_learn_first_correct_name => 'Erste Schritte';

  @override
  String get ach_learn_first_correct_desc =>
      'Beantworte im Lernen deine erste Frage richtig.';

  @override
  String get ach_quiz_first_correct_name => 'Warmgelaufen';

  @override
  String get ach_quiz_first_correct_desc =>
      'Beantworte im Quiz deine erste Frage richtig.';

  @override
  String get ach_exam_pass_name => 'Prüfung bestanden';

  @override
  String get ach_exam_pass_desc =>
      'Gib eine Prüfung mit mindestens 17 richtigen Antworten ab.';

  @override
  String get ach_exam_30_name => 'Fast perfekt';

  @override
  String get ach_exam_30_desc =>
      'Erreiche 30 oder mehr richtige Antworten in der Probeprüfung.';

  @override
  String get achievements_title => 'Erfolge';

  @override
  String get achievements_none => 'Noch keine Erfolge';

  @override
  String get action_achievements => 'Erfolge';

  @override
  String get action_achievements_sem => 'Erfolge öffnen';

  @override
  String get menu_achievements => 'Erfolge';

  @override
  String get menu_subscribe => 'Abonnement';

  @override
  String get ach_practice_10_name => 'Los geht\'s';

  @override
  String get ach_practice_10_desc =>
      'Erreiche 10 richtige Antworten im Lernen/Quiz.';

  @override
  String get ach_practice_100_name => 'Gut in Fahrt';

  @override
  String get ach_practice_100_desc =>
      'Erreiche 100 richtige Antworten im Lernen/Quiz.';

  @override
  String get ach_practice_1000_name => 'Übungsmeister';

  @override
  String get ach_practice_1000_desc =>
      'Erreiche 1000 richtige Antworten im Lernen/Quiz.';

  @override
  String get ach_exam_first_name => 'Erste Prüfung';

  @override
  String get ach_exam_first_desc => 'Gib deine erste Probeprüfung ab.';

  @override
  String get ach_exam_25_name => 'Starke Leistung';

  @override
  String get ach_exam_25_desc =>
      'Erreiche 25 oder mehr richtige Antworten in der Probeprüfung.';

  @override
  String get ach_exam_perfect_name => 'Perfekt!';

  @override
  String get ach_exam_perfect_desc =>
      'Beantworte alle Fragen in der Probeprüfung richtig.';

  @override
  String get ach_exam_streak3_name => 'Hattrick';

  @override
  String get ach_exam_streak3_desc => 'Bestehe drei Probeprüfungen in Folge.';

  @override
  String get ach_exam_fast_name => 'Schnellläufer';

  @override
  String get ach_exam_fast_desc =>
      'Bestehe eine Probeprüfung in unter 10 Minuten.';

  @override
  String get ach_exam_fast5_name => 'Blitzschnell';

  @override
  String get ach_exam_fast5_desc =>
      'Bestehe eine Probeprüfung in unter 5 Minuten.';

  @override
  String get ach_exam_pass10_name => 'Erfahrener Prüfling';

  @override
  String get ach_exam_pass10_desc => 'Bestehe insgesamt 10 Probeprüfungen.';

  @override
  String get ach_exam_perfect3_name => 'Dreifache Perfektion';

  @override
  String get ach_exam_perfect3_desc => 'Erreiche 3 perfekte Probeprüfungen.';

  @override
  String get ach_exam_streak5_name => 'Läuft (5x)';

  @override
  String get ach_exam_streak5_desc =>
      'Bestehe 5 Probeprüfungen hintereinander.';

  @override
  String get ach_timer_first_name => 'Timer-Einsteiger';

  @override
  String get ach_timer_first_desc => 'Schließe einen Timer-Lauf ab.';

  @override
  String get ach_timer_10_name => 'Timer 10';

  @override
  String get ach_timer_10_desc =>
      'Erreiche 10 richtige Antworten in einem Timer-Lauf.';

  @override
  String get ach_timer_20_name => 'Timer 20';

  @override
  String get ach_timer_20_desc =>
      'Erreiche 20 richtige Antworten in einem Timer-Lauf.';

  @override
  String get ach_timer_30_name => 'Timer 30';

  @override
  String get ach_timer_30_desc =>
      'Erreiche 30 richtige Antworten in einem Timer-Lauf.';

  @override
  String get ach_mistakes_review_name => 'Fehler überprüft';

  @override
  String get ach_mistakes_review_desc => 'Schließe eine Fehler-Überprüfung ab.';

  @override
  String get ach_mistakes_clean_name => 'Ohne Fehler';

  @override
  String get ach_mistakes_clean_desc =>
      'Beende eine Fehler-Überprüfung mit 0 falschen Antworten.';

  @override
  String get ach_topics_first_name => 'Themen-Entdecker';

  @override
  String get ach_topics_first_desc =>
      'Beantworte deine erste Frage im Themen-Quiz richtig.';

  @override
  String get ach_practice_2500_name => 'Übungs‑Veteran';

  @override
  String get ach_practice_2500_desc =>
      'Erreiche 2.500 richtige Antworten im Üben.';

  @override
  String get ach_practice_5000_name => 'Übungs‑Profi';

  @override
  String get ach_practice_5000_desc =>
      'Erreiche 5.000 richtige Antworten im Üben.';

  @override
  String get ach_practice_10000_name => 'Übungs‑Legende';

  @override
  String get ach_practice_10000_desc =>
      'Erreiche 10.000 richtige Antworten im Üben.';

  @override
  String get ach_streak7_name => '7‑Tage‑Serie';

  @override
  String get ach_streak7_desc => 'Bleibe 7 Tage hintereinander aktiv.';

  @override
  String get ach_streak30_name => '30‑Tage‑Serie';

  @override
  String get ach_streak30_desc => 'Bleibe 30 Tage hintereinander aktiv.';

  @override
  String get paywall_title => 'Abonnement';

  @override
  String get paywall_subtitle =>
      'Unbegrenzte Probeprüfungen. Du hast deine 3 kostenlosen Prüfungen genutzt.';

  @override
  String get paywall_monthly => 'Monatsabo';

  @override
  String get paywall_subscribe_action => 'Abonnieren';

  @override
  String get paywall_cancel_anytime => 'Jederzeit kündbar';

  @override
  String get paywall_popular_badge => 'Beliebt';

  @override
  String get paywall_unavailable => 'In-App-Käufe derzeit nicht verfügbar';

  @override
  String get trial_exhausted_title => 'Testphase aufgebraucht';

  @override
  String get trial_exhausted_body =>
      'Du hast 3 kostenlose Probeprüfungen abgeschlossen. Abonniere, um unbegrenzten Zugriff zu erhalten.';

  @override
  String get trial_subscribe => 'Abonnieren';

  @override
  String get trial_later => 'Später';

  @override
  String get swipe_results_title => 'Gut gemacht!';

  @override
  String swipe_results_summary(int correct, int total) {
    return 'Du hast $correct von $total richtig.';
  }

  @override
  String get topic_democracy => 'Leben in der Demokratie';

  @override
  String get topic_history_responsibility => 'Geschichte und Verantwortung';

  @override
  String get topic_people_society => 'Mensch und Gesellschaft';

  @override
  String get topic_state => 'Bundesland-Fragen';

  @override
  String get paywall_lifetime => 'Einmalig';

  @override
  String get paywall_lifetime_description => 'Einmal zahlen, alles nutzen';

  @override
  String get paywall_buy_action => 'Kaufen';

  @override
  String get disclaimer_title => 'Hinweis';

  @override
  String get disclaimer_accept_button => 'Verstanden & Akzeptieren';

  @override
  String get restore_purchases => 'Käufe wiederherstellen';

  @override
  String get purchased => 'Gekauft';
}
