import 'package:flutter/material.dart';
import 'dart:async';
import '../services/supabase_service.dart';

class RemoteConfigProvider extends ChangeNotifier {
  bool _showRatingScreen = false;
  bool _isLoading = true;
  StreamSubscription? _subscription;

  bool get showRatingScreen => _showRatingScreen;
  bool get isLoading => _isLoading;

  RemoteConfigProvider() {
    _initializeRemoteConfig();
  }

  Future<void> _initializeRemoteConfig() async {
    debugPrint('🔄 Initializing Remote Config...');
    try {
      // Get initial value
      _showRatingScreen = await SupabaseService.instance.getRockIdentifierStatus();
      _isLoading = false;
      debugPrint('✅ Initial Remote Config loaded: showRatingScreen = $_showRatingScreen');
      notifyListeners();

      // Listen for realtime changes
      _subscription = SupabaseService.instance
          .watchRockIdentifierStatus()
          .listen((status) {
        _showRatingScreen = status;
        notifyListeners();
        debugPrint('🔄 Remote config updated: showRatingScreen = $status');
      });
    } catch (e) {
      debugPrint('❌ Error initializing remote config: $e');
      _showRatingScreen = false; // Default value
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}