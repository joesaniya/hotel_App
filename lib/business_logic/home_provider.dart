import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:hotel_app/models/hotel_modal.dart';
import 'package:hotel_app/models/search_result.dart';
import 'package:hotel_app/screens/bottom_sheet_widget/search_filter_bottomsheet.dart';
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
  
  // Store the actual search query list for API calls
  List<String>? _currentSearchQuery;
  String? _selectedSearchType2;

  // Search criteria
  SearchCriteria? _searchCriteria;

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
  SearchCriteria? get searchCriteria => _searchCriteria;

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
  void setSearchCriteria(SearchCriteria criteria) {
    _searchCriteria = criteria;
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
  Future<void> selectLocationAndFetchHotels(
    SearchResult result,
    SearchCriteria criteria,
  ) async {
    // Extract query list from searchArray
    final queryList = result.getSearchQueryList();
    
    // If no query list, use the result ID as fallback
    if (queryList.isEmpty) {
      log('⚠️ No query list found, using result ID: ${result.id}');
      _currentSearchQuery = [result.id];
    } else {
      log('✅ Using query list: $queryList');
      _currentSearchQuery = queryList;
    }

    // Map the result type to API search type
    _selectedSearchType2 = result.getSearchTypeForAPI();
    _searchCriteria = criteria;

    log('🔍 Search Parameters:');
    log('   Query: $_currentSearchQuery');
    log('   Search Type: $_selectedSearchType2');
    log('   Check-in: ${criteria.checkIn}');
    log('   Check-out: ${criteria.checkOut}');
    log('   Rooms: ${criteria.rooms}, Adults: ${criteria.adults}');
    log('   Accommodations: ${criteria.accommodations}');
    log('   Excluded Types: ${criteria.excludedSearchTypes}');
    log('   Price Range: ${criteria.minPrice} - ${criteria.maxPrice}');

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
    if (_isLoadingHotels || !_hasMoreHotels) {
      log('⏸️ Skipping fetch: loading=$_isLoadingHotels, hasMore=$_hasMoreHotels');
      return;
    }

    if (_currentSearchQuery == null || 
        _currentSearchQuery!.isEmpty || 
        _selectedSearchType2 == null) {
      log('❌ Missing search parameters');
      return;
    }

    if (_searchCriteria == null) {
      log('❌ No search criteria set');
      return;
    }

    _isLoadingHotels = true;
    if (isInitial) {
      _hotels = [];
      _currentRid = 0;
    }
    notifyListeners();

    try {
      log('📡 Fetching hotels (rid: $_currentRid)...');
      
      final response = await _searchService.getSearchResultListOfHotels(
        searchQuery: _currentSearchQuery!,
        searchType: _selectedSearchType2!,
        checkIn: _searchCriteria!.checkIn,
        checkOut: _searchCriteria!.checkOut,
        rooms: _searchCriteria!.rooms,
        adults: _searchCriteria!.adults,
        children: _searchCriteria!.children,
        accommodation: _searchCriteria!.accommodations,
        arrayOfExcludedSearchType: _searchCriteria!.excludedSearchTypes,
        highPrice: _searchCriteria!.maxPrice.toInt().toString(),
        lowPrice: _searchCriteria!.minPrice.toInt().toString(),
        limit: 5,
        preloaderList: _excludedHotels,
        rid: _currentRid,
      );

      log('✅ Fetched ${response.hotels.length} hotels');

      if (response.hotels.isEmpty) {
        log('📭 No more hotels available');
        _hasMoreHotels = false;
      } else {
        _hotels.addAll(response.hotels);
        _excludedHotels.addAll(response.excludedHotels);
        _currentRid++;
        _hasMoreHotels = response.hotels.length >= 5;
        
        log('📊 Total hotels: ${_hotels.length}');
        log('🚫 Excluded hotels: ${_excludedHotels.length}');
      }

      _isLoadingHotels = false;
      notifyListeners();
    } catch (e) {
      log('❌ Error fetching hotels: $e');
      _isLoadingHotels = false;
      _hasMoreHotels = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load more hotels (pagination)
  Future<void> loadMoreHotels() async {
    if (!_isLoadingHotels && _hasMoreHotels) {
      log('⏩ Loading more hotels...');
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
    _currentSearchQuery = null;
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
}