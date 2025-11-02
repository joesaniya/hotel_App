import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:hotel_app/models/hotel_modal.dart';
import 'package:hotel_app/models/search_result.dart';
import 'package:hotel_app/models/static_modal.dart';
import 'package:hotel_app/screens/bottom_sheet_widget/search_filter_bottomsheet.dart';
import 'package:hotel_app/services/hotel_search_service.dart';

class HomeProvider extends ChangeNotifier {
  final HotelSearchService _searchService = HotelSearchService();

  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  String _selectedSearchType = 'All';
  bool _hasSearched = false;
  String _searchQuery = '';

 
  List<Hotel> _hotels = [];
  List<String> _excludedHotels = [];
  bool _isLoadingHotels = false;
  bool _hasMoreHotels = true;
  int _currentRid = 0;
  
 
  List<String>? _currentSearchQuery;
  String? _selectedSearchType2;

 
  SearchCriteria? _searchCriteria;


  List<SearchResult> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get selectedSearchType => _selectedSearchType;
  bool get hasSearched => _hasSearched;
  String get searchQuery => _searchQuery;

  
  List<Hotel> get hotels => _hotels;
  bool get isLoadingHotels => _isLoadingHotels;
  bool get hasMoreHotels => _hasMoreHotels;
  SearchCriteria? get searchCriteria => _searchCriteria;


  Future<void> initialize() async {
    await performAutoCompleteSearch('India', showLoading: true);
  }


  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

 
  void setSearchType(String type) {
    _selectedSearchType = type;
    notifyListeners();
  }

  void setSearchCriteria(SearchCriteria criteria) {
    _searchCriteria = criteria;
    notifyListeners();
  }

  
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

Future<void> selectLocationAndFetchHotels(
    SearchResult result,
    SearchCriteria criteria,
  ) async {
 
    final queryList = result.getSearchQueryList();
    
   
    if (queryList.isEmpty) {
      log(' No query list found, using result ID: ${result.id}');
      _currentSearchQuery = [result.id];
    } else {
      log(' Using query list: $queryList');
      _currentSearchQuery = queryList;
    }

 
    _selectedSearchType2 = result.getSearchTypeForAPI();
    _searchCriteria = criteria;

    log(' Search Parameters:');
    log('   Query: $_currentSearchQuery');
    log('   Search Type: $_selectedSearchType2');
    log('   Check-in: ${criteria.checkIn}');
    log('   Check-out: ${criteria.checkOut}');
    log('   Rooms: ${criteria.rooms}, Adults: ${criteria.adults}');
    log('   Accommodations: ${criteria.accommodations}');
    log('   Excluded Types: ${criteria.excludedSearchTypes}');
    log('   Price Range: ${criteria.minPrice} - ${criteria.maxPrice}');

    
    _hotels = [];
    _excludedHotels = [];
    _currentRid = 0;
    _hasMoreHotels = true;

   
    await fetchHotels(isInitial: true);
  }


  Future<void> fetchHotels({bool isInitial = false}) async {
    if (_isLoadingHotels || !_hasMoreHotels) {
      log(' Skipping fetch: loading=$_isLoadingHotels, hasMore=$_hasMoreHotels');
      return;
    }

    if (_currentSearchQuery == null || 
        _currentSearchQuery!.isEmpty || 
        _selectedSearchType2 == null) {
      log(' Missing search parameters');
      return;
    }

    if (_searchCriteria == null) {
      log(' No search criteria set');
      return;
    }

    _isLoadingHotels = true;
    if (isInitial) {
      _hotels = [];
      _currentRid = 0;
    }
    notifyListeners();

    try {
      log(' Fetching hotels (rid: $_currentRid)...');
      
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

      log(' Fetched ${response.hotels.length} hotels');

      if (response.hotels.isEmpty) {
        log(' No more hotels available');
        _hasMoreHotels = false;
      } else {
        _hotels.addAll(response.hotels);
        _excludedHotels.addAll(response.excludedHotels);
        _currentRid++;
        _hasMoreHotels = response.hotels.length >= 5;
        
        log(' Total hotels: ${_hotels.length}');
        log(' Excluded hotels: ${_excludedHotels.length}');
      }

      _isLoadingHotels = false;
      notifyListeners();
    } catch (e) {
      log(' Error fetching hotels: $e');
      _isLoadingHotels = false;
      _hasMoreHotels = false;
      notifyListeners();
      rethrow;
    }
  }

 
  Future<void> loadMoreHotels() async {
    if (!_isLoadingHotels && _hasMoreHotels) {
      log(' Loading more hotels...');
      await fetchHotels();
    }
  }


  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _hasSearched = false;
    notifyListeners();
  }

  
  void clearHotels() {
    _hotels = [];
    _excludedHotels = [];
    _currentRid = 0;
    _hasMoreHotels = true;
    _currentSearchQuery = null;
    _selectedSearchType2 = null;
    notifyListeners();
  }

 
  Future<void> resetToDefault() async {
    clearSearch();
    clearHotels();
    await initialize();
  }

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

  
  final List<StaticHotel> popularHotels = [
    StaticHotel(
      name: 'Santorini',
      location: 'Greece',
      price: '\$488',
      rating: '4.9',
      imageUrl:
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=400',
    ),
    StaticHotel(
      name: 'Hotel Royal',
      location: 'Spain',
      price: '\$280',
      rating: '4.8',
      imageUrl:
          'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=400',
    ),
    StaticHotel(
      name: 'Grand Palace',
      location: 'France',
      price: '\$350',
      rating: '4.7',
      imageUrl:
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400',
    ),
    StaticHotel(
      name: 'Ocean View Resort',
      location: 'Maldives',
      price: '\$520',
      rating: '4.9',
      imageUrl:
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400',
    ),
  ];

  
  final List<StaticDeal> hotDeals = [
    StaticDeal(
      name: 'Bali Motel Vung Tau',
      location: 'Indonesia',
      price: '\$580',
      rating: '4.9',
      discount: '5% OFF',
      imageUrl:
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400',
    ),
    StaticDeal(
      name: 'Tropical Paradise',
      location: 'Thailand',
      price: '\$420',
      rating: '4.8',
      discount: '10% OFF',
      imageUrl:
          'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400',
    ),
    StaticDeal(
      name: 'Beach Resort',
      location: 'Philippines',
      price: '\$350',
      rating: '4.7',
      discount: '15% OFF',
      imageUrl:
          'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=400',
    ),
  ];

}