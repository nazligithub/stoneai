import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/stone_model.dart';
import '../../helpers/stone_navigation_helper.dart';
import '../../data/stone_data.dart';

class StoneDiscoverViewModel extends ChangeNotifier {

  // Lifecycle state
  bool _isDisposed = false;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error state
  String? _error;
  String? get error => _error;
  bool get hasError => _error != null;

  // Search state
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Data
  List<StoneModel> _allStones = [];
  List<StoneModel> get allStones => List.unmodifiable(_allStones);

  List<StoneModel> _featuredStones = [];
  List<StoneModel> get featuredStones => List.unmodifiable(_featuredStones);

  List<StoneModel> _searchResults = [];
  List<StoneModel> get searchResults => List.unmodifiable(_searchResults);

  List<String> _categories = [];
  List<String> get categories => List.unmodifiable(_categories);

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  bool get isEmpty => _allStones.isEmpty && !_isLoading && !hasError;

  // Load discover data
  Future<void> loadDiscoverData() async {
    if (_isLoading || _isDisposed) return;

    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      // Load all stones from StoneData
      _allStones = StoneData.getExploreStones();
      
      // Set featured stones (first few stones)
      _featuredStones = _allStones.take(3).toList();
      
      // Set categories
      _categories = [
        'categories.igneous'.tr(),
        'categories.sedimentary'.tr(), 
        'categories.metamorphic'.tr(),
        'categories.minerals'.tr(),
        'categories.crystals'.tr(),
        'Gemstones'
      ];
      
    } catch (e) {
      _error = 'Error loading discover data: ${e.toString()}';
      debugPrint('Discover data error: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Search functionality
  Future<void> searchStones(String query) async {
    if (_isDisposed) return;
    
    _searchQuery = query.trim();
    
    if (_searchQuery.isEmpty) {
      _isSearching = false;
      _searchResults = [];
      _safeNotifyListeners();
      return;
    }

    _isSearching = true;
    _safeNotifyListeners();

    try {
      // For now, search within loaded stones
      _searchResults = _allStones
          .where((stone) => 
              stone.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              stone.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              stone.scientificName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      
      // When real API is ready:
      // _searchResults = await _apiService.searchStones(_searchQuery);
      
    } catch (e) {
      debugPrint('Search error: $e');
      _searchResults = [];
    }
    
    _safeNotifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    _searchResults = [];
    _safeNotifyListeners();
  }

  // Category selection
  Future<void> selectCategory(String category) async {
    if (_selectedCategory == category) {
      _selectedCategory = null;
      // TODO: Load actual stones from API when available
      _allStones = []; // Reset to all stones
    } else {
      _selectedCategory = category;
      
      try {
        // Filter stones by category
        // TODO: Load actual stones from API when available
        final allStonesData = <StoneModel>[];
        _allStones = allStonesData
            .where((stone) => stone.category.toLowerCase() == category.toLowerCase())
            .toList();
        
        // When real API is ready:
        // _allStones = await _apiService.getStonesByCategory(category);
        
      } catch (e) {
        debugPrint('Category filter error: $e');
        _error = 'Error filtering stones by category';
      }
    }
    
    _safeNotifyListeners();
  }

  // Navigation
  Future<void> navigateToStoneDetail(String stoneId) async {
    if (_isDisposed) return;
    
    try {
      // Record the stone view
      // TODO: Record stone view when API endpoint is available
      // await _apiService.recordStoneView(stoneId);
      
      if (_isDisposed) return;
      
      // Navigate to explore detail for explore stones
      await StoneNavigationHelper.goToExploreDetail(stoneId: stoneId);
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  // Refresh data
  Future<void> refreshDiscoverData() async {
    if (_isDisposed) return;
    
    _allStones = [];
    _featuredStones = [];
    _searchResults = [];
    _selectedCategory = null;
    await loadDiscoverData();
  }

  // Get stones by hardness range
  List<StoneModel> getStonesByHardness(double minHardness, double maxHardness) {
    return _allStones
        .where((stone) => stone.hardness >= minHardness && stone.hardness <= maxHardness)
        .toList();
  }

  // Get stones by color
  List<StoneModel> getStonesByColor(String color) {
    return _allStones
        .where((stone) => stone.color.toLowerCase().contains(color.toLowerCase()))
        .toList();
  }

  // Advanced search filters
  Future<void> applyFilters({
    String? category,
    double? minHardness,
    double? maxHardness,
    String? color,
    String? formation,
  }) async {
    try {
      List<StoneModel> filteredStones = List.from(_allStones);
      
      if (category != null && category.isNotEmpty) {
        filteredStones = filteredStones
            .where((stone) => stone.category.toLowerCase() == category.toLowerCase())
            .toList();
      }
      
      if (minHardness != null) {
        filteredStones = filteredStones
            .where((stone) => stone.hardness >= minHardness)
            .toList();
      }
      
      if (maxHardness != null) {
        filteredStones = filteredStones
            .where((stone) => stone.hardness <= maxHardness)
            .toList();
      }
      
      if (color != null && color.isNotEmpty) {
        filteredStones = filteredStones
            .where((stone) => stone.color.toLowerCase().contains(color.toLowerCase()))
            .toList();
      }
      
      if (formation != null && formation.isNotEmpty) {
        filteredStones = filteredStones
            .where((stone) => stone.formation.toLowerCase().contains(formation.toLowerCase()))
            .toList();
      }
      
      _allStones = filteredStones;
      _safeNotifyListeners();
      
    } catch (e) {
      debugPrint('Filter error: $e');
      _error = 'Error applying filters';
      _safeNotifyListeners();
    }
  }

  void clearFilters() async {
    _selectedCategory = null;
    await loadDiscoverData();
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