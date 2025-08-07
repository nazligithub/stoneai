import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoneStorageHelper {
  static final StoneStorageHelper _instance = StoneStorageHelper._internal();
  factory StoneStorageHelper() => _instance;

  late final GetStorage _getStorage;
  late final SharedPreferences _sharedPreferences;

  StoneStorageHelper._internal();

  Future<void> init() async {
    await GetStorage.init();
    _getStorage = GetStorage();
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // Onboarding
  bool isOnboardingCompleted() {
    return _getStorage.read('rock_onboarding_completed') ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _getStorage.write('rock_onboarding_completed', completed);
  }

  // Premium status
  bool isPremiumUser() {
    return _getStorage.read('crystal_premium_user') ?? false;
  }

  Future<void> setPremiumUser(bool isPremium) async {
    await _getStorage.write('crystal_premium_user', isPremium);
  }

  // Recent stones
  List<String> getRecentStones() {
    return List<String>.from(_getStorage.read('recent_stones') ?? []);
  }

  Future<void> addRecentStone(String stoneId) async {
    List<String> recentStones = getRecentStones();
    if (recentStones.contains(stoneId)) {
      recentStones.remove(stoneId);
    }
    recentStones.insert(0, stoneId);
    if (recentStones.length > 10) {
      recentStones = recentStones.take(10).toList();
    }
    await _getStorage.write('recent_stones', recentStones);
  }

  Future<void> clearRecentStones() async {
    await _getStorage.remove('recent_stones');
  }

  // Favorite stones
  List<String> getFavoriteStones() {
    return List<String>.from(_getStorage.read('favorite_stones') ?? []);
  }

  Future<void> addFavoriteStone(String stoneId) async {
    List<String> favorites = getFavoriteStones();
    if (!favorites.contains(stoneId)) {
      favorites.add(stoneId);
      await _getStorage.write('favorite_stones', favorites);
    }
  }

  Future<void> removeFavoriteStone(String stoneId) async {
    List<String> favorites = getFavoriteStones();
    favorites.remove(stoneId);
    await _getStorage.write('favorite_stones', favorites);
  }

  bool isFavoriteStone(String stoneId) {
    return getFavoriteStones().contains(stoneId);
  }

  // App settings
  bool isDarkMode() {
    return _getStorage.read('dark_mode') ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    await _getStorage.write('dark_mode', isDark);
  }

  String getLanguage() {
    return _getStorage.read('app_language') ?? 'en';
  }

  Future<void> setLanguage(String language) async {
    await _getStorage.write('app_language', language);
  }

  // API Scan History with User ID support
  List<Map<String, dynamic>> getApiScanHistory({String? userId}) {
    final key = userId != null ? 'api_scan_history_$userId' : 'api_scan_history';
    final history = _getStorage.read(key) ?? [];
    debugPrint('StoneStorageHelper: Getting history with key: $key');
    debugPrint('StoneStorageHelper: Found ${history.length} items in history');
    return List<Map<String, dynamic>>.from(history);
  }
  
  Future<void> addApiScanToHistory({
    required String stoneName,
    required String imageUrl,
    required double confidence,
    required DateTime scanDate,
    required Map<String, dynamic> fullData,
    String? userId,
  }) async {
    final key = userId != null ? 'api_scan_history_$userId' : 'api_scan_history';
    List<Map<String, dynamic>> history = getApiScanHistory(userId: userId);
    
    final scanData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId ?? 'guest',
      'stoneName': stoneName,
      'imageUrl': imageUrl,
      'confidence': confidence,
      'scanDate': scanDate.toIso8601String(),
      'fullData': fullData,
    };
    
    history.insert(0, scanData);
    
    // Keep only last 50 scans per user
    if (history.length > 50) {
      history = history.take(50).toList();
    }
    
    await _getStorage.write(key, history);
    
    // Debug: Verify it was saved
    final savedHistory = _getStorage.read(key);
    debugPrint('DEBUG: Saved history to key: $key');
    debugPrint('DEBUG: History length after save: ${savedHistory?.length ?? 0}');
  }
  
  Future<void> clearApiScanHistory({String? userId}) async {
    final key = userId != null ? 'api_scan_history_$userId' : 'api_scan_history';
    await _getStorage.remove(key);
  }

  // Scan count for free users
  int getScanCount() {
    return _getStorage.read('scan_count') ?? 0;
  }

  Future<void> setScanCount(int count) async {
    await _getStorage.write('scan_count', count);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _getStorage.erase();
    await _sharedPreferences.clear();
  }
}