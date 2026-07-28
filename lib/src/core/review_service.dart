import 'package:in_app_review/in_app_review.dart';
import 'prefs.dart';

/// Requests an in-app store review at an appropriate moment.
///
/// Only prompts once per install (tracked via [AppPrefs.getReviewRequested]).
/// Google Play and the App Store both enforce their own quotas on top of this,
/// so the dialog may silently not appear even when requested.
class ReviewService {
  static final instance = ReviewService._();
  ReviewService._();

  final _inAppReview = InAppReview.instance;

  Future<void> requestReviewIfAppropriate() async {
    // Only ask once — avoid annoying repeat prompts
    if (await AppPrefs.getReviewRequested()) return;
    if (!await _inAppReview.isAvailable()) return;

    await AppPrefs.setReviewRequested();
    await _inAppReview.requestReview();
  }
}
