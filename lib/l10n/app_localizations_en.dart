// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Citizenship Test Quiz';

  @override
  String get loading => 'Loading…';

  @override
  String get menu => 'Menu';

  @override
  String get home_header_title => 'Citizenship Test';

  @override
  String get home_header_subtitle => 'Learn, practice and pass the test';

  @override
  String get home_no_state => 'No state selected';

  @override
  String get action_learn => 'Learn';

  @override
  String get action_learn_sem => 'Open Learn';

  @override
  String get action_quiz => 'Quiz';

  @override
  String get action_quiz_sem => 'Open Quiz';

  @override
  String get action_exam => 'Exam';

  @override
  String get action_exam_sem => 'Open Exam';

  @override
  String get action_analytics => 'Analytics';

  @override
  String get action_analytics_sem => 'Open Analytics';

  @override
  String get menu_language => 'Language';

  @override
  String get menu_state => 'State';

  @override
  String get menu_theme => 'Theme';

  @override
  String get menu_analyse => 'Analyse';

  @override
  String snack_state_selected(Object state) {
    return 'Selected state: $state';
  }

  @override
  String snack_lang_set(Object lang) {
    return 'Language set to $lang';
  }

  @override
  String get theme_system => 'System';

  @override
  String get theme_light => 'Light';

  @override
  String get theme_dark => 'Dark';

  @override
  String get progress_title => 'Analytics';

  @override
  String get progress_overall_accuracy => 'Overall accuracy';

  @override
  String get progress_topic_accuracy => 'Accuracy by topic';

  @override
  String get progress_state_questions => 'State questions';

  @override
  String get progress_pass_rate => 'Exam pass rate';

  @override
  String get progress_last_exams => 'Last exams';

  @override
  String get progress_none => 'No data yet';

  @override
  String get progress_no_exams => 'No exams yet';

  @override
  String get progress_worked_questions => 'Questions worked';

  @override
  String get progress_avg_time => 'Ø time';

  @override
  String get exam_rules_title => 'Exam rules';

  @override
  String get exam_title => 'Exam';

  @override
  String get exam_submit => 'Submit';

  @override
  String get result_title => 'Result';

  @override
  String get result_passed => 'Passed';

  @override
  String get result_failed => 'Failed';

  @override
  String get back => 'Back';

  @override
  String get reset_all => 'Reset all';

  @override
  String get reset_practice => 'Reset learning/quiz';

  @override
  String get reset_exam => 'Reset exams';

  @override
  String get snack_reset_all => 'Analytics: Reset everything';

  @override
  String get snack_reset_practice => 'Analytics: Reset learning/quiz';

  @override
  String get snack_reset_exam => 'Analytics: Reset exams';

  @override
  String get db_unavailable =>
      'Analytics storage unavailable. Data will not be saved.';

  @override
  String get details => 'Details';

  @override
  String get close => 'Close';

  @override
  String get not_completed => 'not completed';

  @override
  String get retry => 'Retry';

  @override
  String get back_btn => 'Back';

  @override
  String get next_btn => 'Next';

  @override
  String get done_btn => 'Done';

  @override
  String get yes_btn => 'Yes';

  @override
  String get no_btn => 'No';

  @override
  String get no_questions => 'No questions available.';

  @override
  String get setup_choose_state_title => 'Choose your state';

  @override
  String get setup_choose_state_subtitle =>
      'This will be used for state-specific questions.';

  @override
  String get setup_state_hint => 'Please select a state';

  @override
  String get setup_language_label => 'Language:';

  @override
  String get setup_save_continue => 'Save and continue';

  @override
  String get setup_choose_later => 'Choose later';

  @override
  String get learning_title => 'Learning mode';

  @override
  String get learning_intro => 'Choose a mode to study.';

  @override
  String get learning_general => 'General';

  @override
  String get learning_all_questions => 'All questions';

  @override
  String get learning_topics => 'Topics';

  @override
  String get learning_no_topics => 'No topics available.';

  @override
  String get learning_state => 'State';

  @override
  String get learning_no_state_selected => 'No state selected';

  @override
  String get learning_select_state_hint =>
      'Select a state on the Home screen to study state-specific questions.';

  @override
  String get learning_no_state_questions => 'No state questions available.';

  @override
  String questions_count(Object count) {
    return '$count questions';
  }

  @override
  String get error_loading_questions => 'Failed to load questions.';

  @override
  String position_label(Object index, Object total) {
    return 'Question $index of $total';
  }

  @override
  String get quiz_title => 'Quiz';

  @override
  String get next_question => 'Next question';

  @override
  String get mock_exam_title => 'Mock exam';

  @override
  String get exam_confirm_title => 'Submit exam?';

  @override
  String get exam_confirm_body =>
      'Do you want to submit the exam now? You can\'t return afterward.';

  @override
  String get exam_start => 'Start exam';

  @override
  String get rule_duration => 'Duration: 60 minutes for the entire test.';

  @override
  String get rule_composition =>
      'Composition: 30 general questions + 3 state-specific questions.';

  @override
  String get rule_pass => 'Pass: At least 17 correct answers required.';

  @override
  String get rule_no_aids => 'No aids allowed (books, notes, internet).';

  @override
  String get rule_change_answers => 'Answers can be changed during the exam.';

  @override
  String get rule_auto_submit =>
      'The exam will be submitted automatically when time runs out.';

  @override
  String get rule_no_return =>
      'After submission you cannot return to the exam.';

  @override
  String result_correct_of_total(Object correct, Object total) {
    return 'Correct answers: $correct of $total';
  }

  @override
  String result_your_answer(Object answer) {
    return 'Your answer: $answer';
  }

  @override
  String result_correct_answer(Object answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get no_answer => 'None';

  @override
  String get back_to_home => 'Back to home';

  @override
  String get grade_sehr_gut => 'very good';

  @override
  String get grade_gut => 'good';

  @override
  String get grade_befriedigend => 'satisfactory';

  @override
  String get grade_ausreichend => 'sufficient';

  @override
  String get grade_mangelhaft => 'poor';

  @override
  String get grade_ungenuegend => 'insufficient';
}
