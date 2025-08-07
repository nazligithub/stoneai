import 'package:flutter/material.dart';
import '../../models/stone_model.dart';
import '../../data/stone_data.dart';

class ExploreDetailViewModel extends ChangeNotifier {
  bool _isLoading = true;
  StoneModel? _stone;

  bool get isLoading => _isLoading;
  StoneModel? get stone => _stone;

  Future<void> initialize(String stoneId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find the stone from local data
      _stone = StoneData.getRockById(stoneId);
    } catch (e) {
      _stone = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}