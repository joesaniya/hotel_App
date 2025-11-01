import 'dart:developer';
import 'package:hotel_app/data-provider/dio-client.dart';
import 'package:hotel_app/models/hotel_modal.dart';
import 'package:hotel_app/models/search_result.dart';
import 'package:hotel_app/services/local_storage_service.dart';

class HotelSearchService {
  static const String baseUrl = 'https://api.mytravaly.com/public/v1/';
  static const String authToken = '71523fdd8d26f585315b4233e39d9263';

  final DioClient _dioClient = DioClient();

  /// Search hotels by city, state, country, or property name
  Future<List<SearchResult>> searchAutoComplete({
    required String inputText,
    String searchType = 'byCity',
    int limit = 10,
  }) async {
    if (inputText.length < 3) {
      return [];
    }

    try {
      final visitorToken = await LocalStorageService.getVisitorToken();

      if (visitorToken == null) {
        log('No visitor token found');
        return [];
      }

      log('Searching for: $inputText with type: $searchType');

      final requestBody = {
        "action": "searchAutoComplete",
        "searchAutoComplete": {
          "inputText": inputText,
          "searchType": [searchType],
          "limit": limit,
        },
      };

      final response = await _dioClient.performCall(
        requestType: RequestType.post,
        url: baseUrl,
        headers: {'authtoken': authToken, 'visitortoken': visitorToken},
        data: requestBody,
      );

      if (response != null && response.statusCode == 200) {
        log('Search autocomplete successful');
        return _parseSearchResults(response.data);
      } else {
        log('Search failed: ${response?.statusCode}');
      }

      return [];
    } catch (e) {
      log('Error searching: $e');
      return [];
    }
  }

  /// Search with multiple types
  Future<List<SearchResult>> searchAll(String inputText) async {
    if (inputText.length < 3) {
      return [];
    }

    try {
      final visitorToken = await LocalStorageService.getVisitorToken();

      if (visitorToken == null) {
        log('No visitor token found');
        return [];
      }

      final requestBody = {
        "action": "searchAutoComplete",
        "searchAutoComplete": {
          "inputText": inputText,
          "searchType": ["byCity", "byState", "byCountry", "byPropertyName"],
          "limit": 10,
        },
      };

      final response = await _dioClient.performCall(
        requestType: RequestType.post,
        url: baseUrl,
        headers: {'authtoken': authToken, 'visitortoken': visitorToken},
        data: requestBody,
      );

      if (response != null && response.statusCode == 200) {
        log('Search all successful');
        return _parseSearchResults(response.data);
      }

      return [];
    } catch (e) {
      log('Error searching all: $e');
      return [];
    }
  }

  /// Get hotel search results with pagination
  Future<HotelSearchResponse> getSearchResultListOfHotels({
    required List<String> searchQuery,
    required String searchType,
    required String checkIn,
    required String checkOut,
    int rooms = 1,
    int adults = 2,
    int children = 0,
    List<String> accommodation = const ['all'],
    List<String> arrayOfExcludedSearchType = const [],
    String highPrice = '3000000',
    String lowPrice = '0',
    int limit = 5, // Maximum allowed by API
    List<String> preloaderList = const [],
    String currency = 'INR',
    int rid = 0,
  }) async {
    try {
      final visitorToken = await LocalStorageService.getVisitorToken();

      if (visitorToken == null) {
        log('No visitor token found');
        return HotelSearchResponse(hotels: [], excludedHotels: []);
      }
      final requestBody = {
        "action": "getSearchResultListOfHotels",
        "getSearchResultListOfHotels": {
          "searchCriteria": {
            "checkIn": "2026-07-11",
            "checkOut": "2026-07-12",
            "rooms": 2,
            "adults": 2,
            "children": 0,
            "searchType": "hotelIdSearch",
            "searchQuery": ["qyhZqzVt"],
            "accommodation": [
              "all",
              "hotel", //allowed "hotel","resort","Boat House","bedAndBreakfast","guestHouse","Holidayhome","cottage","apartment","Home Stay", "hostel","Guest House","Camp_sites/tent","co_living","Villa","Motel","Capsule Hotel","Dome Hotel","all"
            ],
            "arrayOfExcludedSearchType": [
              "street", //allowed street, city, state, country
            ],
            "highPrice": "3000000",
            "lowPrice": "0",
            "limit": 5,
            "preloaderList": [],
            "currency": "INR",
            "rid": 0,
          },
        },
      };
      log('getSearchResultListOfHotels requestBody: $requestBody');
      final requestBody1 = {
        "action": "getSearchResultListOfHotels",
        "getSearchResultListOfHotels": {
          "searchCriteria": {
            "checkIn": checkIn,
            "checkOut": checkOut,
            "rooms": rooms,
            "adults": adults,
            "children": children,
            "searchType": searchType,
            "searchQuery": searchQuery,
            "accommodation": accommodation,
            "arrayOfExcludedSearchType": arrayOfExcludedSearchType,
            "highPrice": highPrice,
            "lowPrice": lowPrice,
            "limit": limit,
            "preloaderList": preloaderList,
            "currency": currency,
            "rid": rid,
          },
        },
      };

      log('Fetching hotels with query: $searchQuery');

      final response = await _dioClient.performCall(
        requestType: RequestType.post,
        url: baseUrl,
        headers: {'authtoken': authToken, 'visitortoken': visitorToken},
        data: requestBody,
      );

      if (response != null && response.statusCode == 200) {
        log('Hotel search successful');
        return _parseHotelSearchResponse(response.data);
      } else {
        log('Hotel search failed: ${response?.statusCode}');
      }

      return HotelSearchResponse(hotels: [], excludedHotels: []);
    } catch (e) {
      log('Error fetching hotels: $e');
      return HotelSearchResponse(hotels: [], excludedHotels: []);
    }
  }

  /// Parse search results from API response
  List<SearchResult> _parseSearchResults(dynamic responseData) {
    final List<SearchResult> results = [];

    try {
      if (responseData == null || responseData is! Map) {
        return results;
      }

      final data = responseData['data'];
      if (data == null || data['autoCompleteList'] == null) {
        return results;
      }

      final autoCompleteList = data['autoCompleteList'] as Map;

      final categories = [
        'byPropertyName',
        'byCity',
        'byState',
        'byCountry',
        'byStreet',
      ];

      for (final category in categories) {
        final categoryData = autoCompleteList[category];
        if (categoryData != null &&
            categoryData is Map &&
            categoryData['present'] == true &&
            categoryData['listOfResult'] != null) {
          final listOfResults = categoryData['listOfResult'] as List;

          for (final item in listOfResults) {
            if (item is Map) {
              results.add(
                SearchResult.fromJson(
                  Map<String, dynamic>.from(item),
                  category,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      log('Error parsing search results: $e');
    }

    return results;
  }

  /// Parse hotel search response
  HotelSearchResponse _parseHotelSearchResponse(dynamic responseData) {
    try {
      if (responseData == null || responseData is! Map) {
        return HotelSearchResponse(hotels: [], excludedHotels: []);
      }

      final data = responseData['data'];
      if (data == null) {
        return HotelSearchResponse(hotels: [], excludedHotels: []);
      }

      final List<Hotel> hotels = [];
      final arrayOfHotelList = data['arrayOfHotelList'] as List?;

      if (arrayOfHotelList != null) {
        for (final hotelJson in arrayOfHotelList) {
          if (hotelJson is Map) {
            hotels.add(Hotel.fromJson(Map<String, dynamic>.from(hotelJson)));
          }
        }
      }

      final List<String> excludedHotels = [];
      final arrayOfExcludedHotels = data['arrayOfExcludedHotels'] as List?;

      if (arrayOfExcludedHotels != null) {
        excludedHotels.addAll(
          arrayOfExcludedHotels.map((e) => e.toString()).toList(),
        );
      }

      return HotelSearchResponse(
        hotels: hotels,
        excludedHotels: excludedHotels,
      );
    } catch (e) {
      log('Error parsing hotel search response: $e');
      return HotelSearchResponse(hotels: [], excludedHotels: []);
    }
  }
}

/// Response model for hotel search
class HotelSearchResponse {
  final List<Hotel> hotels;
  final List<String> excludedHotels;

  HotelSearchResponse({required this.hotels, required this.excludedHotels});
}
