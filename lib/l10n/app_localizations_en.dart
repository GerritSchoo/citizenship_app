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
  String get menu_language => 'App Language';

  @override
  String get menu_content_language => 'Question Language';

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
  String snack_app_lang_set(Object lang) {
    return 'App language set to $lang';
  }

  @override
  String snack_content_lang_set(Object lang) {
    return 'Question language set to $lang';
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
  String get quiz_modes_title => 'Choose quiz mode';

  @override
  String get quiz_mode_mistakes => 'Mistakes Quiz';

  @override
  String get quiz_mode_topics => 'Topics Quiz';

  @override
  String get quiz_mode_timer => 'Timer Quiz';

  @override
  String get quiz_mode_mistakes_desc => 'Practice your recent mistakes.';

  @override
  String get quiz_mode_topics_desc => 'Practice by topic.';

  @override
  String get quiz_mode_timer_desc => 'Answer as many as you can in 2 minutes.';

  @override
  String get quiz_mode_swipe_tf => 'Swipe Quiz';

  @override
  String get quiz_mode_swipe_tf_desc => 'Swipe right if it fits, left if not.';

  @override
  String get quiz_start => 'Start quiz';

  @override
  String get quiz_pick_topics => 'Pick topics';

  @override
  String get timer_results_title => 'Timer result';

  @override
  String get leaderboard_title => 'Leaderboard';

  @override
  String leaderboard_correct_answers(int count) {
    return '$count correct answers';
  }

  @override
  String get mistakes_results_title => 'Review mistakes';

  @override
  String get mistakes_retry_wrong => 'Retry wrong questions';

  @override
  String get mistakes_all_correct_title => 'All correct!';

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

  @override
  String achievement_unlocked(String title) {
    return 'Achievement unlocked: $title';
  }

  @override
  String get ach_learn_first_correct_name => 'First steps';

  @override
  String get ach_learn_first_correct_desc =>
      'Answer your first question correctly in Learning.';

  @override
  String get ach_quiz_first_correct_name => 'Getting warm';

  @override
  String get ach_quiz_first_correct_desc =>
      'Answer your first question correctly in Quiz.';

  @override
  String get ach_exam_pass_name => 'Passed the exam';

  @override
  String get ach_exam_pass_desc =>
      'Submit an exam with at least 17 correct answers.';

  @override
  String get ach_exam_30_name => 'Almost perfect';

  @override
  String get ach_exam_30_desc =>
      'Score 30 or more correct answers in a mock exam.';

  @override
  String get achievements_title => 'Achievements';

  @override
  String get achievements_none => 'No achievements yet';

  @override
  String get action_achievements => 'Achievements';

  @override
  String get action_achievements_sem => 'Open Achievements';

  @override
  String get menu_achievements => 'Achievements';

  @override
  String get menu_subscribe => 'Subscribe';

  @override
  String get ach_practice_10_name => 'Getting started';

  @override
  String get ach_practice_10_desc => 'Reach 10 correct answers in practice.';

  @override
  String get ach_practice_100_name => 'On a roll';

  @override
  String get ach_practice_100_desc => 'Reach 100 correct answers in practice.';

  @override
  String get ach_practice_1000_name => 'Practice master';

  @override
  String get ach_practice_1000_desc =>
      'Reach 1000 correct answers in practice.';

  @override
  String get ach_exam_first_name => 'First attempt';

  @override
  String get ach_exam_first_desc => 'Submit your first mock exam.';

  @override
  String get ach_exam_25_name => 'Strong score';

  @override
  String get ach_exam_25_desc =>
      'Score 25 or more correct answers in a mock exam.';

  @override
  String get ach_exam_perfect_name => 'Perfect!';

  @override
  String get ach_exam_perfect_desc =>
      'Score all answers correctly in a mock exam.';

  @override
  String get ach_exam_streak3_name => 'Hat trick';

  @override
  String get ach_exam_streak3_desc => 'Pass three mock exams in a row.';

  @override
  String get ach_exam_fast_name => 'Speed runner';

  @override
  String get ach_exam_fast_desc => 'Pass a mock exam in under 10 minutes.';

  @override
  String get ach_exam_fast5_name => 'Lightning fast';

  @override
  String get ach_exam_fast5_desc => 'Pass a mock exam in under 5 minutes.';

  @override
  String get ach_exam_pass10_name => 'Seasoned examinee';

  @override
  String get ach_exam_pass10_desc => 'Pass 10 mock exams in total.';

  @override
  String get ach_exam_perfect3_name => 'Triple perfection';

  @override
  String get ach_exam_perfect3_desc => 'Achieve 3 perfect mock exams.';

  @override
  String get ach_exam_streak5_name => 'On fire (5x)';

  @override
  String get ach_exam_streak5_desc => 'Pass 5 mock exams in a row.';

  @override
  String get ach_timer_first_name => 'Timer rookie';

  @override
  String get ach_timer_first_desc => 'Complete a timer run.';

  @override
  String get ach_timer_10_name => 'Timer 10';

  @override
  String get ach_timer_10_desc => 'Reach 10 correct in a timer run.';

  @override
  String get ach_timer_20_name => 'Timer 20';

  @override
  String get ach_timer_20_desc => 'Reach 20 correct in a timer run.';

  @override
  String get ach_timer_30_name => 'Timer 30';

  @override
  String get ach_timer_30_desc => 'Reach 30 correct in a timer run.';

  @override
  String get ach_mistakes_review_name => 'Reviewed mistakes';

  @override
  String get ach_mistakes_review_desc => 'Complete a Mistakes review.';

  @override
  String get ach_mistakes_clean_name => 'Clean sweep';

  @override
  String get ach_mistakes_clean_desc =>
      'Finish a Mistakes review with 0 wrong.';

  @override
  String get ach_topics_first_name => 'Topic explorer';

  @override
  String get ach_topics_first_desc =>
      'Answer your first question correctly in Topics.';

  @override
  String get ach_practice_2500_name => 'Practice veteran';

  @override
  String get ach_practice_2500_desc =>
      'Reach 2,500 correct answers in practice.';

  @override
  String get ach_practice_5000_name => 'Practice expert';

  @override
  String get ach_practice_5000_desc =>
      'Reach 5,000 correct answers in practice.';

  @override
  String get ach_practice_10000_name => 'Practice legend';

  @override
  String get ach_practice_10000_desc =>
      'Reach 10,000 correct answers in practice.';

  @override
  String get ach_streak7_name => '7-day streak';

  @override
  String get ach_streak7_desc => 'Stay active 7 days in a row.';

  @override
  String get ach_streak30_name => '30-day streak';

  @override
  String get ach_streak30_desc => 'Stay active 30 days in a row.';

  @override
  String get paywall_title => 'Subscribe';

  @override
  String get paywall_subtitle =>
      'Enjoy unlimited mock exams. You have used your 3 free exams.';

  @override
  String get paywall_monthly => 'Monthly';

  @override
  String get paywall_subscribe_action => 'Subscribe';

  @override
  String get paywall_cancel_anytime => 'Cancel anytime';

  @override
  String get paywall_popular_badge => 'Popular';

  @override
  String get paywall_unavailable =>
      'In-app purchases are currently not available.';

  @override
  String get trial_exhausted_title => 'Free trial used';

  @override
  String get trial_exhausted_body =>
      'You have completed 3 free mock exams. Subscribe to continue with unlimited access.';

  @override
  String get trial_subscribe => 'Subscribe';

  @override
  String get trial_later => 'Later';

  @override
  String get swipe_results_title => 'Great job!';

  @override
  String swipe_results_summary(int correct, int total) {
    return 'You got $correct of $total correct.';
  }

  @override
  String get topic_democracy => 'Living in a democracy';

  @override
  String get topic_history_responsibility => 'History and Responsibility';

  @override
  String get topic_people_society => 'People and Society';

  @override
  String get topic_state => 'Federal State Questions';

  @override
  String get paywall_lifetime => 'One-time';

  @override
  String get paywall_lifetime_description => 'Pay once, full access';

  @override
  String get paywall_buy_action => 'Buy';
}
