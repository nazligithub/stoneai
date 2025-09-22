import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../helpers/stone_navigation_helper.dart';

class RatingViewModel extends ChangeNotifier {
  final InAppReview inAppReview = InAppReview.instance;
  bool _hasRated = false;
  bool _showRatedButton = false;

  bool get hasRated => _hasRated;
  bool get showRatedButton => _showRatedButton;

  void showRatingButton() {
    _showRatedButton = true;
    notifyListeners();
  }

  void onLeaveRating() async {
    try {
      // Request app review
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }

      // Show rated button after review
      await Future.delayed(const Duration(milliseconds: 500));
      showRatingButton();
      _hasRated = true;
    } catch (e) {
      debugPrint('Error requesting review: $e');
      // Show button anyway
      showRatingButton();
      _hasRated = true;
    }
  }

  void onRatedButtonTapped() async {
    await navigateNext();
  }

  Future<void> navigateNext() async {
    HapticFeedback.mediumImpact();
    // Navigate to paywall after rating
    StoneNavigationHelper.goToPaywall(isFromOnboarding: true);
  }
}