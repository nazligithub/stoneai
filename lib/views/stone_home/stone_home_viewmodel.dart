import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/stone_model.dart';
import '../../data/stone_data.dart';
import '../../helpers/stone_navigation_helper.dart';
import '../../constants/stone_routes.dart';
import '../../viewmodels/stone_app_provider.dart';

class StoneHomeViewModel extends ChangeNotifier {
  List<StoneModel> _featuredStones = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _error;
  final TextEditingController _questionController = TextEditingController();
  bool _isKeyboardVisible = false;

  List<StoneModel> get featuredStones => _featuredStones;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get error => _error;
  TextEditingController get questionController => _questionController;
  bool get isKeyboardVisible => _isKeyboardVisible;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void setKeyboardVisible(bool visible) {
    _isKeyboardVisible = visible;
    notifyListeners();
  }

  Future<void> loadHomeData() async {
    _isLoading = true;
    _hasError = false;
    _error = null;
    notifyListeners();

    try {
      final allStones = StoneData.getExploreStones();
      // Get featured stones (first 6 most popular ones)
      _featuredStones = allStones.take(6).toList();
      _hasError = false;
    } catch (e) {
      _hasError = true;
      _error = 'Failed to load stones: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void navigateToStoneDetail(String stoneId) {
    StoneNavigationHelper.navigateTo(
      StoneRoutes.exploreDetail,
      arguments: {'stoneId': stoneId},
    );
  }

  void navigateToCamera() {
    // Update tab index to camera
    final context = StoneNavigationHelper.navigatorKey.currentContext!;
    Provider.of<StoneAppProvider>(context, listen: false).setTabIndex(1);
  }

  void submitQuestion() {
    if (_questionController.text.trim().isNotEmpty) {
      final question = _questionController.text.trim();
      _questionController.clear();

      // Navigate to AI chat with the question
      StoneNavigationHelper.navigateTo(
        StoneRoutes.aiChat,
        arguments: {'initialMessage': question},
      );
    }
  }
}