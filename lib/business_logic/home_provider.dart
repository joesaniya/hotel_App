import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:hotel_app/models/hotel_modal.dart';
import 'package:hotel_app/models/search_result.dart';
import 'package:hotel_app/services/hotel_search_service.dart';

class HomeProvider extends ChangeNotifier {
  final HotelSearchService _searchService = HotelSearchService();
  
  // State variables for autocomplete search
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  String _selectedSearchType = 'All';
  bool _hasSearched = false;
  String _searchQuery = '';

  // State variables for hotel results with pagination
  List<Hotel> _hotels = [];
  List<String> _excludedHotels = [];
  bool _isLoadingHotels = false;
  bool _hasMoreHotels = true;
  int _currentRid = 0;
  String? _selectedLocationId;
  String? _selectedSearchType2;
  
  // Search criteria
  String _checkIn = '';
  String _checkOut = '';
  int _rooms = 1;
  int _adults = 2;
  int _children = 0;

  // Getters for autocomplete
  List<SearchResult> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get selectedSearchType => _selectedSearchType;
  bool get hasSearched => _hasSearched;
  String get searchQuery => _searchQuery;

  // Getters for hotels
  List<Hotel> get hotels => _hotels;
  bool get isLoadingHotels => _isLoadingHotels;
  bool get hasMoreHotels => _hasMoreHotels;
  String? get selectedLocationId => _selectedLocationId;

  // Search criteria getters
  String get checkIn => _checkIn;
  String get checkOut => _checkOut;
  int get rooms => _rooms;
  int get adults => _adults;
  int get children => _children;

  /// Initialize with default data
  Future<void> initialize() async {
    await performAutoCompleteSearch('India', showLoading: true);
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Change search type for autocomplete
  void setSearchType(String type) {
    _selectedSearchType = type;
    notifyListeners();
  }

  /// Set search criteria
  void setSearchCriteria({
    required String checkIn,
    required String checkOut,
    int? rooms,
    int? adults,
    int? children,
  }) {
    _checkIn = checkIn;
    _checkOut = checkOut;
    if (rooms != null) _rooms = rooms;
    if (adults != null) _adults = adults;
    if (children != null) _children = children;
    notifyListeners();
  }

  /// Perform autocomplete search
  Future<void> performAutoCompleteSearch(
    String query, {
    bool showLoading = false,
  }) async {
    if (query.isEmpty) {
      _searchResults = [];
      _hasSearched = false;
      notifyListeners();
      return;
    }

    _isSearching = showLoading;
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

      _searchResults = results;
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      log('Error in autocomplete search: $e');
      _isSearching = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Select a location from search results and fetch hotels
  Future<void> selectLocationAndFetchHotels(SearchResult result) async {
    if (result.searchArray == null) {
      log('No search array found for result');
      return;
    }

    _selectedLocationId = result.id;
    _selectedSearchType2 = _mapCategoryToSearchType(result.type);
    
    // Reset pagination
    _hotels = [];
    _excludedHotels = [];
    _currentRid = 0;
    _hasMoreHotels = true;

    // Fetch first batch of hotels
    await fetchHotels(isInitial: true);
  }

  /// Fetch hotels with pagination
  Future<void> fetchHotels({bool isInitial = false}) async {
    if (_isLoadingHotels || !_hasMoreHotels) return;

    if (_selectedLocationId == null || _selectedSearchType2 == null) {
      log('No location selected');
      return;
    }

    _isLoadingHotels = true;
    if (isInitial) {
      _hotels = [];
      _currentRid = 0;
    }
    notifyListeners();

    try {
      final response = await _searchService.getSearchResultListOfHotels(
        searchQuery: [_selectedLocationId!],
        searchType: _selectedSearchType2!,
        checkIn: _checkIn.isEmpty ? _getDefaultCheckIn() : _checkIn,
        checkOut: _checkOut.isEmpty ? _getDefaultCheckOut() : _checkOut,
        rooms: _rooms,
        adults: _adults,
        children: _children,
        limit: 10,
        preloaderList: _excludedHotels,
        rid: _currentRid,
      );

      if (response.hotels.isEmpty) {
        _hasMoreHotels = false;
      } else {
        _hotels.addAll(response.hotels);
        _excludedHotels.addAll(response.excludedHotels);
        _currentRid++;
        _hasMoreHotels = response.hotels.length >= 10;
      }

      _isLoadingHotels = false;
      notifyListeners();
    } catch (e) {
      log('Error fetching hotels: $e');
      _isLoadingHotels = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load more hotels (pagination)
  Future<void> loadMoreHotels() async {
    if (!_isLoadingHotels && _hasMoreHotels) {
      await fetchHotels();
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _hasSearched = false;
    notifyListeners();
  }

  /// Clear hotel results
  void clearHotels() {
    _hotels = [];
    _excludedHotels = [];
    _currentRid = 0;
    _hasMoreHotels = true;
    _selectedLocationId = null;
    _selectedSearchType2 = null;
    notifyListeners();
  }

  /// Reset to initial state
  Future<void> resetToDefault() async {
    clearSearch();
    clearHotels();
    await initialize();
  }

  /// Helper: Convert display type to search key for autocomplete
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

  /// Helper: Map category to search type for hotel API
  String _mapCategoryToSearchType(String category) {
    switch (category.toLowerCase()) {
      case 'hotel':
        return 'hotelIdSearch';
      case 'city':
        return 'cityIdSearch';
      case 'state':
        return 'stateIdSearch';
      case 'country':
        return 'countryIdSearch';
      default:
        return 'cityIdSearch';
    }
  }

  /// Get default check-in date (tomorrow)
  String _getDefaultCheckIn() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
  }

  /// Get default check-out date (day after tomorrow)
  String _getDefaultCheckOut() {
    final dayAfterTomorrow = DateTime.now().add(const Duration(days: 2));
    return '${dayAfterTomorrow.year}-${dayAfterTomorrow.month.toString().padLeft(2, '0')}-${dayAfterTomorrow.day.toString().padLeft(2, '0')}';
  }
}