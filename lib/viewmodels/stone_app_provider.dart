import 'package:flutter/material.dart';
import '../helpers/stone_storage_helper.dart';
import '../helpers/revenue_cat_helper.dart';
import '../helpers/stone_navigation_helper.dart';

class StoneAppProvider extends ChangeNotifier {
  final StoneStorageHelper _storageHelper = StoneStorageHelper();

  // Tab index management
  int _selectedTabIndex = 0; // Start with home tab (index 0)
  int get selectedTabIndex => _selectedTabIndex;

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  // Home scroll control
  bool _stoneHomeScrollToTopRequested = false;
  bool get stoneHomeScrollToTopRequested => _stoneHomeScrollToTopRequested;

  set stoneHomeScrollToTopRequested(bool value) {
    _stoneHomeScrollToTopRequested = value;
    if (value) {
      Future.microtask(() {
        _stoneHomeScrollToTopRequested = false;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  // Theme management
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _storageHelper.setDarkMode(isDark);
      notifyListeners();
    }
  }

  // Premium status
  bool _isPremiumUser = false;
  bool get isPremiumUser => _isPremiumUser;

  Future<void> setPremiumUser(bool isPremium) async {
    if (_isPremiumUser != isPremium) {
      _isPremiumUser = isPremium;
      await _storageHelper.setPremiumUser(isPremium);
      notifyListeners();
    }
  }

  // Recent stones management
  List<String> _recentStones = [];
  List<String> get recentStones => List.unmodifiable(_recentStones);

  Future<void> addRecentStone(String stoneId) async {
    await _storageHelper.addRecentStone(stoneId);
    _recentStones = _storageHelper.getRecentStones();
    notifyListeners();
  }

  Future<void> clearRecentStones() async {
    await _storageHelper.clearRecentStones();
    _recentStones = [];
    notifyListeners();
  }

  // Favorite stones management
  List<String> _favoriteStones = [];
  List<String> get favoriteStones => List.unmodifiable(_favoriteStones);

  Future<void> addFavoriteStone(String stoneId) async {
    await _storageHelper.addFavoriteStone(stoneId);
    _favoriteStones = _storageHelper.getFavoriteStones();
    notifyListeners();
  }

  Future<void> removeFavoriteStone(String stoneId) async {
    await _storageHelper.removeFavoriteStone(stoneId);
    _favoriteStones = _storageHelper.getFavoriteStones();
    notifyListeners();
  }

  bool isFavoriteStone(String stoneId) {
    return _favoriteStones.contains(stoneId);
  }

  // App loading state
  bool _isAppLoading = true;
  bool get isAppLoading => _isAppLoading;
  
  // Onboarding state
  bool _isOnboardingCompleted = false;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  // Explore scroll control
  bool _exploreScrollToTopRequested = false;
  bool get exploreScrollToTopRequested => _exploreScrollToTopRequested;

  set exploreScrollToTopRequested(bool value) {
    _exploreScrollToTopRequested = value;
    if (value) {
      Future.microtask(() {
        _exploreScrollToTopRequested = false;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  // History scroll control
  bool _historyScrollToTopRequested = false;
  bool get historyScrollToTopRequested => _historyScrollToTopRequested;

  set historyScrollToTopRequested(bool value) {
    _historyScrollToTopRequested = value;
    if (value) {
      Future.microtask(() {
        _historyScrollToTopRequested = false;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  // Camera access state
  bool _hasCameraPermission = false;
  bool get hasCameraPermission => _hasCameraPermission;

  void setCameraPermission(bool hasPermission) {
    if (_hasCameraPermission != hasPermission) {
      _hasCameraPermission = hasPermission;
      notifyListeners();
    }
  }

  // Scan counting for free users
  int _scanCount = 0;
  int get scanCount => _scanCount;
  static const int maxFreeScans = 1;

  bool get canScanForFree => _isPremiumUser;
  bool get hasUsedFreeScans => !_isPremiumUser && _scanCount >= maxFreeScans;

  Future<void> incrementScanCount() async {
    if (!_isPremiumUser) {
      _scanCount++;
      await _storageHelper.setScanCount(_scanCount);
      notifyListeners();
    }
  }

  Future<void> resetScanCount() async {
    _scanCount = 0;
    await _storageHelper.setScanCount(_scanCount);
    notifyListeners();
  }

  // Initialization
  Future<void> initializeApp() async {
    try {
      _isAppLoading = true;
      notifyListeners();

      // Load stored data
      _isDarkMode = _storageHelper.isDarkMode();
      _isPremiumUser = _storageHelper.isPremiumUser();
      _recentStones = _storageHelper.getRecentStones();
      _favoriteStones = _storageHelper.getFavoriteStones();
      _isOnboardingCompleted = _storageHelper.isOnboardingCompleted();
      _scanCount = _storageHelper.getScanCount();

      // Load RevenueCat products and check subscription
      await RevenueCatHelper.shared.loadProducts();
      await RevenueCatHelper.shared.checkSubscription();
      
      // Update premium status from RevenueCat
      if (RevenueCatHelper.shared.isActive != _isPremiumUser) {
        await setPremiumUser(RevenueCatHelper.shared.isActive);
      }

      await Future.delayed(const Duration(milliseconds: 1500)); // Splash duration 1.5 seconds
    } catch (e) {
      debugPrint('Error initializing app: $e');
    } finally {
      _isAppLoading = false;
      notifyListeners();
    }
  }

  // History tab selected notification
  bool _historyTabSelected = false;
  bool get historyTabSelected => _historyTabSelected;
  
  void notifyHistoryTabSelected() {
    _historyTabSelected = true;
    notifyListeners();
    Future.microtask(() {
      _historyTabSelected = false;
      notifyListeners();
    });
  }

  // Navigation state for tab switching
  void requestTabScroll(int tabIndex) {
    switch (tabIndex) {
      case 0:
        exploreScrollToTopRequested = true;
        break;
      case 1:
        // Camera tab - no scroll needed
        break;
      case 2:
        historyScrollToTopRequested = true;
        break;
    }
  }

  // Reset app state
  Future<void> resetAppState() async {
    _selectedTabIndex = 0;
    _isDarkMode = false;
    _isPremiumUser = false;
    _recentStones = [];
    _favoriteStones = [];
    _hasCameraPermission = false;
    
    await _storageHelper.clearAllData();
    notifyListeners();
  }

  // Complete onboarding
  Future<void> completeOnboarding() async {
    await _storageHelper.setOnboardingCompleted(true);
    _isOnboardingCompleted = true;
    notifyListeners();
  }

}