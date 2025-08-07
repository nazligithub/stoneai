import 'package:flutter/material.dart';
import '../../models/stone_model.dart';
import '../../models/stone_scan_response.dart';
import '../../helpers/stone_storage_helper.dart';
import '../../helpers/stone_navigation_helper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class StoneHistoryViewModel extends ChangeNotifier {
  final StoneStorageHelper _storageHelper = StoneStorageHelper();

  // Lifecycle state
  bool _isDisposed = false;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error state
  String? _error;
  String? get error => _error;
  bool get hasError => _error != null;

  // Data
  List<StoneModel> _allHistory = [];
  List<StoneModel> get allHistory => List.unmodifiable(_allHistory);

  List<StoneModel> _recentStones = [];
  List<StoneModel> get recentStones => List.unmodifiable(_recentStones);

  List<StoneModel> _favoriteStones = [];
  List<StoneModel> get favoriteStones => List.unmodifiable(_favoriteStones);
  
  // API Scan History
  List<Map<String, dynamic>> _apiScanHistory = [];
  List<Map<String, dynamic>> get apiScanHistory => List.unmodifiable(_apiScanHistory);

  // Statistics
  int _totalScans = 0;
  int get totalScans => _totalScans;

  int _weeklyScans = 0;
  int get weeklyScans => _weeklyScans;

  int get favoritesCount => _favoriteStones.length;

  bool get isEmpty => _allHistory.isEmpty && !_isLoading && !hasError;
  bool get hasHistory => _allHistory.isNotEmpty;

  // Load history data
  Future<void> loadHistory() async {
    if (_isLoading || _isDisposed) return;

    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      // Initialize date formatting for Turkish locale
      await initializeDateFormatting('tr_TR', null);
      // Load API scan history (for now use guest user, later integrate with auth)
      final userId = 'guest'; // TODO: Get actual user ID from auth service
      
      // Try both with and without userId
      _apiScanHistory = _storageHelper.getApiScanHistory(userId: userId);
      if (_apiScanHistory.isEmpty) {
        // Try without userId as fallback
        debugPrint('StoneHistoryViewModel: No history found with userId, trying without...');
        _apiScanHistory = _storageHelper.getApiScanHistory();
      }
      
      debugPrint('StoneHistoryViewModel: Loading history...');
      debugPrint('StoneHistoryViewModel: API scan history count: ${_apiScanHistory.length}');
      for (final scan in _apiScanHistory) {
        debugPrint('StoneHistoryViewModel: Scan: ${scan['stoneName']} - ${scan['scanDate']}');
      }
      
      // Create StoneModel objects from API scan history only
      final apiStones = <StoneModel>[];
      for (final scan in _apiScanHistory) {
        try {
          final stoneData = StoneScanData.fromJson(scan['fullData'] as Map<String, dynamic>);
          final scanDate = DateTime.parse(scan['scanDate'] as String);
          final formattedDate = DateFormat('d MMM, HH:mm', 'tr_TR').format(scanDate);
          
          // Remove emoji from stone name if present
          String stoneName = stoneData.stone.name;
          // More comprehensive emoji removal
          stoneName = stoneName.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true), ''); // Emoticons
          stoneName = stoneName.replaceAll(RegExp(r'[\u{1F300}-\u{1F5FF}]', unicode: true), ''); // Misc Symbols and Pictographs
          stoneName = stoneName.replaceAll(RegExp(r'[\u{1F680}-\u{1F6FF}]', unicode: true), ''); // Transport and Map
          stoneName = stoneName.replaceAll(RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), ''); // Misc symbols
          stoneName = stoneName.replaceAll(RegExp(r'[\u{2700}-\u{27BF}]', unicode: true), ''); // Dingbats
          stoneName = stoneName.replaceAll(RegExp(r'[\u{1F900}-\u{1F9FF}]', unicode: true), ''); // Supplemental Symbols and Pictographs
          stoneName = stoneName.replaceAll(RegExp(r'[\u{1FA00}-\u{1FA6F}]', unicode: true), ''); // Chess Symbols
          stoneName = stoneName.replaceAll(RegExp(r'[\u{1FA70}-\u{1FAFF}]', unicode: true), ''); // Symbols and Pictographs Extended-A
          stoneName = stoneName.trim();
          
          apiStones.add(StoneModel(
            id: scan['id'] as String,
            name: stoneName.isNotEmpty ? stoneName : 'Unknown Stone',
            scientificName: stoneData.stone.basicInfo.mineralFamily,
            category: formattedDate,
            description: 'Güven: %${(stoneData.stone.confidence * 100).toStringAsFixed(0)}',
            imageUrl: stoneData.imageUrl,
            hardness: double.tryParse(stoneData.stone.basicInfo.hardness.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 7.0,
            color: stoneData.stone.basicInfo.colorVariations,
            luster: 'Vitreous',
            formation: stoneData.stone.basicInfo.crystalSystem,
            isPopular: false,
            uses: [],
            origin: scan['scanDate'] as String?, // Store scan date in origin field
          ));
        } catch (e) {
          debugPrint('Error parsing API scan: $e');
        }
      }
      
      // Sort by date - newest first
      apiStones.sort((a, b) {
        final dateA = DateTime.parse(a.origin ?? '');
        final dateB = DateTime.parse(b.origin ?? '');
        return dateB.compareTo(dateA); // Newest first
      });
      
      // Only show API scans in history
      _recentStones = apiStones.take(10).toList();
      _favoriteStones = []; // No favorites for now, only API scans
      _allHistory = apiStones;
      
      // Load statistics - only API scans
      _totalScans = _apiScanHistory.length;
      _weeklyScans = _apiScanHistory.where((scan) {
        final scanDate = DateTime.parse(scan['scanDate'] as String);
        final weekAgo = DateTime.now().subtract(Duration(days: 7));
        return scanDate.isAfter(weekAgo);
      }).length;
      
    } catch (e) {
      _error = 'Error loading history: ${e.toString()}';
      debugPrint('History error: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Refresh history
  Future<void> refreshHistory() async {
    _allHistory = [];
    _recentStones = [];
    _favoriteStones = [];
    await loadHistory();
  }

  // Clear history
  Future<void> clearHistory() async {
    try {
      final userId = 'guest'; // TODO: Get actual user ID from auth service
      await _storageHelper.clearRecentStones();
      await _storageHelper.clearApiScanHistory(userId: userId);
      _allHistory = [];
      _recentStones = [];
      _apiScanHistory = [];
      _totalScans = 0;
      _weeklyScans = 0;
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Error clearing history';
      debugPrint('Clear history error: $e');
      _safeNotifyListeners();
    }
  }

  // Navigation
  Future<void> navigateToStoneDetail(String stoneId) async {
    // Check if this is an API scan
    final apiScan = _apiScanHistory.firstWhere(
      (scan) => scan['id'] == stoneId,
      orElse: () => {},
    );
    
    if (apiScan.isNotEmpty) {
      // Navigate with API data
      final stoneData = StoneScanData.fromJson(apiScan['fullData'] as Map<String, dynamic>);
      StoneNavigationHelper.navigateTo(
        '/stone-detail',
        arguments: {
          'stoneId': stoneId,
          'stoneData': stoneData.stone,
          'imageUrl': stoneData.imageUrl,
        },
      );
    } else {
      // Navigate with local stone data
      StoneNavigationHelper.goToStoneDetail(stoneId: stoneId);
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String stoneId) async {
    try {
      final isFavorite = _storageHelper.isFavoriteStone(stoneId);
      
      if (isFavorite) {
        await _storageHelper.removeFavoriteStone(stoneId);
        _favoriteStones.removeWhere((stone) => stone.id == stoneId);
      } else {
        await _storageHelper.addFavoriteStone(stoneId);
        // Add to favorites if not already there
        // TODO: Load actual stones from API when available
      final allStones = [];
        final stone = allStones.firstWhere((s) => s.id == stoneId);
        if (!_favoriteStones.any((s) => s.id == stoneId)) {
          _favoriteStones.add(stone);
        }
      }
      
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
    }
  }

  // Add stone to history
  Future<void> addStoneToHistory(StoneModel stone) async {
    try {
      await _storageHelper.addRecentStone(stone.id);
      
      // Add to recent stones if not already there
      if (!_recentStones.any((s) => s.id == stone.id)) {
        _recentStones.insert(0, stone);
        if (_recentStones.length > 10) {
          _recentStones = _recentStones.take(10).toList();
        }
      }
      
      // Add to all history if not already there
      if (!_allHistory.any((s) => s.id == stone.id)) {
        _allHistory.insert(0, stone);
      }
      
      _totalScans++;
      _weeklyScans++;
      
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('Add to history error: $e');
    }
  }

  // Get stones by date range
  List<StoneModel> getStonesByDateRange(DateTime start, DateTime end) {
    // For now, return recent stones
    // In a real app, you would filter by actual identification dates
    return _recentStones;
  }

  // Get stones by category from history
  List<StoneModel> getHistoryByCategory(String category) {
    return _allHistory
        .where((stone) => stone.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // Search within history
  List<StoneModel> searchHistory(String query) {
    if (query.isEmpty) return _allHistory;
    
    return _allHistory
        .where((stone) =>
            stone.name.toLowerCase().contains(query.toLowerCase()) ||
            stone.category.toLowerCase().contains(query.toLowerCase()) ||
            stone.scientificName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Safe notifyListeners that checks if disposed
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}