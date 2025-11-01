import 'package:flutter/material.dart';
import 'package:hotel_app/models/search_result.dart';
import 'package:hotel_app/services/hotel_search_service.dart';

class HomeProvider extends ChangeNotifier {
  final HotelSearchService _searchService = HotelSearchService();
  
  // State variables
  List<SearchResult> _results = [];
  bool _isLoading = false;
  String _selectedSearchType = 'All';
  bool _hasSearched = false;
  String _searchQuery = '';

  // Getters
  List<SearchResult> get results => _results;
  bool get isLoading => _isLoading;
  String get selectedSearchType => _selectedSearchType;
  bool get hasSearched => _hasSearched;
  String get searchQuery => _searchQuery;

  // Initialize with default data
  Future<void> initialize() async {
    await performSearch('India', showLoading: true);
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Change search type
  void setSearchType(String type) {
    _selectedSearchType = type;
    notifyListeners();
  }

  // Perform search
  Future<void> performSearch(String query, {bool showLoading = false}) async {
    if (query.isEmpty) {
      _results = [];
      _hasSearched = false;
      notifyListeners();
      return;
    }

    _isLoading = showLoading;
    _hasSearched = true;
    _searchQuery = query;
    notifyListeners();

    try {
      final results = _selectedSearchType == 'All'
          ? await _searchService.searchAll(query)
          : await _searchService.searchAutoComplete(
              inputText: query,
              searchType: _getSearchTypeKey(_selectedSearchType),
            );

      _results = results;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Let UI handle the error display
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _results = [];
    _hasSearched = false;
    notifyListeners();
  }

  // Reset to initial state
  Future<void> resetToDefault() async {
    clearSearch();
    await initialize();
  }

  // Helper method to convert display type to search key
  String _getSearchTypeKey(String displayType) {
    switch (displayType) {
      case 'City':
        return 'byCity';
      case 'State':
        return 'byState';
      case 'Country':
        return 'byCountry';
      case 'Property':
        return 'byPropertyName';
      default:
        return 'byCity';
    }
  }
}