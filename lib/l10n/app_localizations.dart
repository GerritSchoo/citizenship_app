import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Citizenship Helper'**
  String get app_title;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @home_header_title.
  ///
  /// In en, this message translates to:
  /// **'Citizenship Helper'**
  String get home_header_title;

  /// No description provided for @home_header_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn, practice and pass the test'**
  String get home_header_subtitle;

  /// No description provided for @home_no_state.
  ///
  /// In en, this message translates to:
  /// **'No state selected'**
  String get home_no_state;

  /// No description provided for @action_learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get action_learn;

  /// No description provided for @action_learn_sem.
  ///
  /// In en, this message translates to:
  /// **'Open Learn'**
  String get action_learn_sem;

  /// No description provided for @action_quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get action_quiz;

  /// No description provided for @action_quiz_sem.
  ///
  /// In en, this message translates to:
  /// **'Open Quiz'**
  String get action_quiz_sem;

  /// No description provided for @action_exam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get action_exam;

  /// No description provided for @action_exam_sem.
  ///
  /// In en, this message translates to:
  /// **'Open Exam'**
  String get action_exam_sem;

  /// No description provided for @action_analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get action_analytics;

  /// No description provided for @action_analytics_sem.
  ///
  /// In en, this message translates to:
  /// **'Open Analytics'**
  String get action_analytics_sem;

  /// No description provided for @menu_language.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get menu_language;

  /// No description provided for @menu_content_language.
  ///
  /// In en, this message translates to:
  /// **'Question Language'**
  String get menu_content_language;

  /// No description provided for @menu_state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get menu_state;

  /// No description provided for @menu_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get menu_theme;

  /// No description provided for @menu_analyse.
  ///
  /// In en, this message translates to:
  /// **'Analyse'**
  String get menu_analyse;

  /// No description provided for @menu_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get menu_privacy;

  /// No description provided for @menu_imprint.
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get menu_imprint;

  /// No description provided for @snack_state_selected.
  ///
  /// In en, this message translates to:
  /// **'Selected state: {state}'**
  String snack_state_selected(Object state);

  /// No description provided for @snack_lang_set.
  ///
  /// In en, this message translates to:
  /// **'Language set to {lang}'**
  String snack_lang_set(Object lang);

  /// No description provided for @snack_app_lang_set.
  ///
  /// In en, this message translates to:
  /// **'App language set to {lang}'**
  String snack_app_lang_set(Object lang);

  /// No description provided for @snack_content_lang_set.
  ///
  /// In en, this message translates to:
  /// **'Question language set to {lang}'**
  String snack_content_lang_set(Object lang);

  /// No description provided for @theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get theme_system;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_dark;

  /// No description provided for @progress_title.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get progress_title;

  /// No description provided for @progress_overall_accuracy.
  ///
  /// In en, this message translates to:
  /// **'Overall accuracy'**
  String get progress_overall_accuracy;

  /// No description provided for @progress_topic_accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy by topic'**
  String get progress_topic_accuracy;

  /// No description provided for @progress_state_questions.
  ///
  /// In en, this message translates to:
  /// **'State questions'**
  String get progress_state_questions;

  /// No description provided for @progress_pass_rate.
  ///
  /// In en, this message translates to:
  /// **'Exam pass rate'**
  String get progress_pass_rate;

  /// No description provided for @progress_last_exams.
  ///
  /// In en, this message translates to:
  /// **'Last exams'**
  String get progress_last_exams;

  /// No description provided for @progress_none.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get progress_none;

  /// No description provided for @progress_no_exams.
  ///
  /// In en, this message translates to:
  /// **'No exams yet'**
  String get progress_no_exams;

  /// No description provided for @progress_worked_questions.
  ///
  /// In en, this message translates to:
  /// **'Questions worked'**
  String get progress_worked_questions;

  /// No description provided for @progress_avg_time.
  ///
  /// In en, this message translates to:
  /// **'Ø time'**
  String get progress_avg_time;

  /// No description provided for @exam_rules_title.
  ///
  /// In en, this message translates to:
  /// **'Exam rules'**
  String get exam_rules_title;

  /// No description provided for @exam_title.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get exam_title;

  /// No description provided for @exam_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get exam_submit;

  /// No description provided for @result_title.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result_title;

  /// No description provided for @result_passed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get result_passed;

  /// No description provided for @result_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get result_failed;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @reset_all.
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get reset_all;

  /// No description provided for @reset_practice.
  ///
  /// In en, this message translates to:
  /// **'Reset learning/quiz'**
  String get reset_practice;

  /// No description provided for @reset_exam.
  ///
  /// In en, this message translates to:
  /// **'Reset exams'**
  String get reset_exam;

  /// No description provided for @snack_reset_all.
  ///
  /// In en, this message translates to:
  /// **'Analytics: Reset everything'**
  String get snack_reset_all;

  /// No description provided for @snack_reset_practice.
  ///
  /// In en, this message translates to:
  /// **'Analytics: Reset learning/quiz'**
  String get snack_reset_practice;

  /// No description provided for @snack_reset_exam.
  ///
  /// In en, this message translates to:
  /// **'Analytics: Reset exams'**
  String get snack_reset_exam;

  /// No description provided for @db_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Analytics storage unavailable. Data will not be saved.'**
  String get db_unavailable;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @not_completed.
  ///
  /// In en, this message translates to:
  /// **'not completed'**
  String get not_completed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @back_btn.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back_btn;

  /// No description provided for @next_btn.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next_btn;

  /// No description provided for @done_btn.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done_btn;

  /// No description provided for @yes_btn.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes_btn;

  /// No description provided for @no_btn.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no_btn;

  /// No description provided for @no_questions.
  ///
  /// In en, this message translates to:
  /// **'No questions available.'**
  String get no_questions;

  /// No description provided for @setup_choose_state_title.
  ///
  /// In en, this message translates to:
  /// **'Choose your state'**
  String get setup_choose_state_title;

  /// No description provided for @setup_choose_state_subtitle.
  ///
  /// In en, this message translates to:
  /// **'This will be used for state-specific questions.'**
  String get setup_choose_state_subtitle;

  /// No description provided for @setup_state_hint.
  ///
  /// In en, this message translates to:
  /// **'Please select a state'**
  String get setup_state_hint;

  /// No description provided for @setup_language_label.
  ///
  /// In en, this message translates to:
  /// **'Language:'**
  String get setup_language_label;

  /// No description provided for @setup_save_continue.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get setup_save_continue;

  /// No description provided for @learning_title.
  ///
  /// In en, this message translates to:
  /// **'Learning mode'**
  String get learning_title;

  /// No description provided for @learning_intro.
  ///
  /// In en, this message translates to:
  /// **'Choose a mode to study.'**
  String get learning_intro;

  /// No description provided for @learning_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get learning_general;

  /// No description provided for @learning_all_questions.
  ///
  /// In en, this message translates to:
  /// **'All questions'**
  String get learning_all_questions;

  /// No description provided for @learning_topics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get learning_topics;

  /// No description provided for @learning_no_topics.
  ///
  /// In en, this message translates to:
  /// **'No topics available.'**
  String get learning_no_topics;

  /// No description provided for @learning_state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get learning_state;

  /// No description provided for @learning_no_state_selected.
  ///
  /// In en, this message translates to:
  /// **'No state selected'**
  String get learning_no_state_selected;

  /// No description provided for @learning_select_state_hint.
  ///
  /// In en, this message translates to:
  /// **'Select a state on the Home screen to study state-specific questions.'**
  String get learning_select_state_hint;

  /// No description provided for @learning_no_state_questions.
  ///
  /// In en, this message translates to:
  /// **'No state questions available.'**
  String get learning_no_state_questions;

  /// No description provided for @questions_count.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String questions_count(Object count);

  /// No description provided for @error_loading_questions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load questions.'**
  String get error_loading_questions;

  /// No description provided for @position_label.
  ///
  /// In en, this message translates to:
  /// **'Question {index} of {total}'**
  String position_label(Object index, Object total);

  /// No description provided for @quiz_title.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz_title;

  /// No description provided for @next_question.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get next_question;

  /// No description provided for @quiz_modes_title.
  ///
  /// In en, this message translates to:
  /// **'Choose quiz mode'**
  String get quiz_modes_title;

  /// No description provided for @quiz_mode_mistakes.
  ///
  /// In en, this message translates to:
  /// **'Mistakes Quiz'**
  String get quiz_mode_mistakes;

  /// No description provided for @quiz_mode_topics.
  ///
  /// In en, this message translates to:
  /// **'Topics Quiz'**
  String get quiz_mode_topics;

  /// No description provided for @quiz_mode_timer.
  ///
  /// In en, this message translates to:
  /// **'Timer Quiz'**
  String get quiz_mode_timer;

  /// No description provided for @quiz_mode_mistakes_desc.
  ///
  /// In en, this message translates to:
  /// **'Practice your recent mistakes.'**
  String get quiz_mode_mistakes_desc;

  /// No description provided for @quiz_mode_topics_desc.
  ///
  /// In en, this message translates to:
  /// **'Practice by topic.'**
  String get quiz_mode_topics_desc;

  /// No description provided for @quiz_mode_timer_desc.
  ///
  /// In en, this message translates to:
  /// **'Answer as many as you can in 2 minutes.'**
  String get quiz_mode_timer_desc;

  /// Swipe-based true/false practice mode title
  ///
  /// In en, this message translates to:
  /// **'Swipe Quiz'**
  String get quiz_mode_swipe_tf;

  /// Short description for swipe true/false mode
  ///
  /// In en, this message translates to:
  /// **'Swipe right if it fits, left if not.'**
  String get quiz_mode_swipe_tf_desc;

  /// No description provided for @quiz_start.
  ///
  /// In en, this message translates to:
  /// **'Start quiz'**
  String get quiz_start;

  /// No description provided for @quiz_pick_topics.
  ///
  /// In en, this message translates to:
  /// **'Pick topics'**
  String get quiz_pick_topics;

  /// No description provided for @timer_results_title.
  ///
  /// In en, this message translates to:
  /// **'Timer result'**
  String get timer_results_title;

  /// No description provided for @leaderboard_title.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard_title;

  /// Shows only the number of correct answers in leaderboard entries
  ///
  /// In en, this message translates to:
  /// **'{count} correct answers'**
  String leaderboard_correct_answers(int count);

  /// No description provided for @mistakes_results_title.
  ///
  /// In en, this message translates to:
  /// **'Review mistakes'**
  String get mistakes_results_title;

  /// No description provided for @mistakes_retry_wrong.
  ///
  /// In en, this message translates to:
  /// **'Retry wrong questions'**
  String get mistakes_retry_wrong;

  /// No description provided for @mistakes_all_correct_title.
  ///
  /// In en, this message translates to:
  /// **'All correct!'**
  String get mistakes_all_correct_title;

  /// No description provided for @mock_exam_title.
  ///
  /// In en, this message translates to:
  /// **'Mock exam'**
  String get mock_exam_title;

  /// No description provided for @exam_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Submit exam?'**
  String get exam_confirm_title;

  /// No description provided for @exam_confirm_body.
  ///
  /// In en, this message translates to:
  /// **'Do you want to submit the exam now? You can\'t return afterward.'**
  String get exam_confirm_body;

  /// No description provided for @exam_start.
  ///
  /// In en, this message translates to:
  /// **'Start exam'**
  String get exam_start;

  /// No description provided for @rule_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration: 60 minutes for the entire test.'**
  String get rule_duration;

  /// No description provided for @rule_composition.
  ///
  /// In en, this message translates to:
  /// **'Composition: 30 general questions + 3 state-specific questions.'**
  String get rule_composition;

  /// No description provided for @rule_pass.
  ///
  /// In en, this message translates to:
  /// **'Pass: At least 17 correct answers required.'**
  String get rule_pass;

  /// No description provided for @rule_no_aids.
  ///
  /// In en, this message translates to:
  /// **'No aids allowed (books, notes, internet).'**
  String get rule_no_aids;

  /// No description provided for @rule_change_answers.
  ///
  /// In en, this message translates to:
  /// **'Answers can be changed during the exam.'**
  String get rule_change_answers;

  /// No description provided for @rule_auto_submit.
  ///
  /// In en, this message translates to:
  /// **'The exam will be submitted automatically when time runs out.'**
  String get rule_auto_submit;

  /// No description provided for @rule_no_return.
  ///
  /// In en, this message translates to:
  /// **'After submission you cannot return to the exam.'**
  String get rule_no_return;

  /// No description provided for @result_correct_of_total.
  ///
  /// In en, this message translates to:
  /// **'Correct answers: {correct} of {total}'**
  String result_correct_of_total(Object correct, Object total);

  /// No description provided for @result_your_answer.
  ///
  /// In en, this message translates to:
  /// **'Your answer: {answer}'**
  String result_your_answer(Object answer);

  /// No description provided for @result_correct_answer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String result_correct_answer(Object answer);

  /// No description provided for @no_answer.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get no_answer;

  /// No description provided for @back_to_home.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get back_to_home;

  /// No description provided for @grade_sehr_gut.
  ///
  /// In en, this message translates to:
  /// **'very good'**
  String get grade_sehr_gut;

  /// No description provided for @grade_gut.
  ///
  /// In en, this message translates to:
  /// **'good'**
  String get grade_gut;

  /// No description provided for @grade_befriedigend.
  ///
  /// In en, this message translates to:
  /// **'satisfactory'**
  String get grade_befriedigend;

  /// No description provided for @grade_ausreichend.
  ///
  /// In en, this message translates to:
  /// **'sufficient'**
  String get grade_ausreichend;

  /// No description provided for @grade_mangelhaft.
  ///
  /// In en, this message translates to:
  /// **'poor'**
  String get grade_mangelhaft;

  /// No description provided for @grade_ungenuegend.
  ///
  /// In en, this message translates to:
  /// **'insufficient'**
  String get grade_ungenuegend;

  /// Bottom snackbar text when an achievement is unlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked: {title}'**
  String achievement_unlocked(String title);

  /// Achievement title: first correct in learning
  ///
  /// In en, this message translates to:
  /// **'First steps'**
  String get ach_learn_first_correct_name;

  /// Achievement description: first correct in learning
  ///
  /// In en, this message translates to:
  /// **'Answer your first question correctly in Learning.'**
  String get ach_learn_first_correct_desc;

  /// Achievement title: first correct in quiz
  ///
  /// In en, this message translates to:
  /// **'Getting warm'**
  String get ach_quiz_first_correct_name;

  /// Achievement description: first correct in quiz
  ///
  /// In en, this message translates to:
  /// **'Answer your first question correctly in Quiz.'**
  String get ach_quiz_first_correct_desc;

  /// Achievement title: pass exam (>=17)
  ///
  /// In en, this message translates to:
  /// **'Passed the exam'**
  String get ach_exam_pass_name;

  /// Achievement description: pass exam (>=17)
  ///
  /// In en, this message translates to:
  /// **'Submit an exam with at least 17 correct answers.'**
  String get ach_exam_pass_desc;

  /// Achievement title: >=30 correct in exam
  ///
  /// In en, this message translates to:
  /// **'Almost perfect'**
  String get ach_exam_30_name;

  /// Achievement description: >=30 correct in exam
  ///
  /// In en, this message translates to:
  /// **'Score 30 or more correct answers in a mock exam.'**
  String get ach_exam_30_desc;

  /// Title for the Achievements screen
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements_title;

  /// Shown when no achievements have been unlocked yet
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get achievements_none;

  /// Home action card label for Achievements
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get action_achievements;

  /// Semantics label for Achievements card
  ///
  /// In en, this message translates to:
  /// **'Open Achievements'**
  String get action_achievements_sem;

  /// Overflow menu entry to open Achievements screen
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get menu_achievements;

  /// Overflow menu entry to open subscription/paywall screen
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get menu_subscribe;

  /// 100 correct answers in practice
  ///
  /// In en, this message translates to:
  /// **'On a roll'**
  String get ach_practice_100_name;

  /// Description for 100 practice correct answers
  ///
  /// In en, this message translates to:
  /// **'Reach 100 correct answers in practice.'**
  String get ach_practice_100_desc;

  /// 1000 correct answers in practice
  ///
  /// In en, this message translates to:
  /// **'Practice master'**
  String get ach_practice_1000_name;

  /// Description for 1000 practice correct answers
  ///
  /// In en, this message translates to:
  /// **'Reach 1000 correct answers in practice.'**
  String get ach_practice_1000_desc;

  /// First exam submitted
  ///
  /// In en, this message translates to:
  /// **'First attempt'**
  String get ach_exam_first_name;

  /// Description for first exam submitted
  ///
  /// In en, this message translates to:
  /// **'Submit your first mock exam.'**
  String get ach_exam_first_desc;

  /// All answers correct in exam
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get ach_exam_perfect_name;

  /// Description for perfect exam
  ///
  /// In en, this message translates to:
  /// **'Score all answers correctly in a mock exam.'**
  String get ach_exam_perfect_desc;

  /// Pass 3 exams in a row
  ///
  /// In en, this message translates to:
  /// **'Hat trick'**
  String get ach_exam_streak3_name;

  /// Description for 3 pass streak
  ///
  /// In en, this message translates to:
  /// **'Pass three mock exams in a row.'**
  String get ach_exam_streak3_desc;

  /// Pass an exam in under 10 minutes
  ///
  /// In en, this message translates to:
  /// **'Speed runner'**
  String get ach_exam_fast_name;

  /// Description for fast pass exam
  ///
  /// In en, this message translates to:
  /// **'Pass a mock exam in under 10 minutes.'**
  String get ach_exam_fast_desc;

  /// First timer run - title
  ///
  /// In en, this message translates to:
  /// **'Timer rookie'**
  String get ach_timer_first_name;

  /// First timer run - description
  ///
  /// In en, this message translates to:
  /// **'Complete a timer run.'**
  String get ach_timer_first_desc;

  /// Mistakes review - title
  ///
  /// In en, this message translates to:
  /// **'Reviewed mistakes'**
  String get ach_mistakes_review_name;

  /// Mistakes review - description
  ///
  /// In en, this message translates to:
  /// **'Complete a Mistakes review.'**
  String get ach_mistakes_review_desc;

  /// Mistakes clean - title
  ///
  /// In en, this message translates to:
  /// **'Clean sweep'**
  String get ach_mistakes_clean_name;

  /// Mistakes clean - description
  ///
  /// In en, this message translates to:
  /// **'Finish a Mistakes review with 0 wrong.'**
  String get ach_mistakes_clean_desc;

  /// First correct in Topics - title
  ///
  /// In en, this message translates to:
  /// **'Topic explorer'**
  String get ach_topics_first_name;

  /// First correct in Topics - description
  ///
  /// In en, this message translates to:
  /// **'Answer your first question correctly in Topics.'**
  String get ach_topics_first_desc;

  /// 7 day streak - title
  ///
  /// In en, this message translates to:
  /// **'7-day streak'**
  String get ach_streak7_name;

  /// 7 day streak - description
  ///
  /// In en, this message translates to:
  /// **'Stay active 7 days in a row.'**
  String get ach_streak7_desc;

  /// Paywall screen title
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get paywall_title;

  /// Short paywall pitch
  ///
  /// In en, this message translates to:
  /// **'Enjoy unlimited mock exams. You have used your 3 free exams.'**
  String get paywall_subtitle;

  /// Monthly plan label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywall_monthly;

  /// Button text for subscription
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get paywall_subscribe_action;

  /// Flexible cancellation hint
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get paywall_cancel_anytime;

  /// Badge text for the most popular plan
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get paywall_popular_badge;

  /// Error shown when IAP is not available
  ///
  /// In en, this message translates to:
  /// **'In-app purchases are currently not available.'**
  String get paywall_unavailable;

  /// Dialog title when free trial is exhausted
  ///
  /// In en, this message translates to:
  /// **'Free trial used'**
  String get trial_exhausted_title;

  /// Dialog body for exhausted trial
  ///
  /// In en, this message translates to:
  /// **'You have completed 3 free mock exams. Subscribe to continue with unlimited access.'**
  String get trial_exhausted_body;

  /// Subscribe CTA
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get trial_subscribe;

  /// Defer subscription CTA
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get trial_later;

  /// Title shown at the end of swipe session
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get swipe_results_title;

  /// Summary line for swipe results
  ///
  /// In en, this message translates to:
  /// **'You got {correct} of {total} correct.'**
  String swipe_results_summary(int correct, int total);

  /// No description provided for @topic_democracy.
  ///
  /// In en, this message translates to:
  /// **'Living in a democracy'**
  String get topic_democracy;

  /// No description provided for @topic_history_responsibility.
  ///
  /// In en, this message translates to:
  /// **'History and Responsibility'**
  String get topic_history_responsibility;

  /// No description provided for @topic_people_society.
  ///
  /// In en, this message translates to:
  /// **'People and Society'**
  String get topic_people_society;

  /// No description provided for @topic_state.
  ///
  /// In en, this message translates to:
  /// **'Federal State Questions'**
  String get topic_state;

  /// Lifetime plan label
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get paywall_lifetime;

  /// Description for lifetime plan
  ///
  /// In en, this message translates to:
  /// **'Pay once, full access'**
  String get paywall_lifetime_description;

  /// Button text for one-time purchase
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get paywall_buy_action;

  /// No description provided for @disclaimer_title.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer_title;

  /// No description provided for @disclaimer_accept_button.
  ///
  /// In en, this message translates to:
  /// **'Understand & Accept'**
  String get disclaimer_accept_button;

  /// Button to restore purchases
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restore_purchases;

  /// Label for purchased plan
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// No description provided for @confirm_reset_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reset'**
  String get confirm_reset_title;

  /// No description provided for @confirm_reset_body.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your progress data and cannot be undone.'**
  String get confirm_reset_body;

  /// No description provided for @restore_checking.
  ///
  /// In en, this message translates to:
  /// **'Checking purchases…'**
  String get restore_checking;

  /// No description provided for @restore_no_purchases.
  ///
  /// In en, this message translates to:
  /// **'No purchases found'**
  String get restore_no_purchases;

  /// No description provided for @finish_quiz.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish_quiz;

  /// No description provided for @exam_trials_remaining.
  ///
  /// In en, this message translates to:
  /// **'{count} free trial(s) remaining'**
  String exam_trials_remaining(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
