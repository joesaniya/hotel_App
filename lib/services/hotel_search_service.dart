import 'dart:developer';
import 'package:hotel_app/data-provider/dio-client.dart';
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
    // Minimum 3 characters required by API
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
        log('Searchautocomplete successful:${response.data}');
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
    // Minimum 3 characters required by API
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
        log('SearchAll successful:${response.data}');
        return _parseSearchResults(response.data);
      }

      return [];
    } catch (e) {
      log('Error searching all: $e');
      return [];
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

      // Parse each category
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
              // Cast to Map<String, dynamic> before passing to fromJson
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
}



/*import 'dart:developer';
import 'package:hotel_app/data-provider/dio-client.dart';
import 'package:hotel_app/models/search_result.dart';

import 'package:hotel_app/services/local_storage_service.dart';

class HotelSearchService {
  static const String baseUrl = 'https://api.mytravaly.com/public/v1/';
  static const String authToken = '71523fdd8d26f585315b4233e39d9263';

  final DioClient _dioClient = DioClient();

  /// Search hotels by city, state, country, or property name
  Future<List<SearchResult>> searchAutoComplete({
    required String inputText,
    String searchType =
        'byCity', // byCity, byState, byCountry, byRandom, byPropertyName
    int limit = 10,
  }) async {
    try {
      // Get visitor token from storage
      final visitorToken = await LocalStorageService.getVisitorToken();

      if (visitorToken == null) {
        log('No visitor token found');
        return [];
      }

      log('Searching for: $inputText with type: $searchType');

      final requestBody = {
        "action": "searchAutoComplete",
        "searchAutoComplete": {
          "inputText": "indi",
          "searchType": [
            "byCity",
            "byState",
            "byCountry",
            "byRandom",
            "byPropertyName", // you can put any searchType from the list
          ],
          "limit": 10,
        },
      }; /*{
        "action": "searchAutoComplete",
        "searchAutoComplete": {
          "inputText": inputText,
          "searchType": [searchType],
          "limit": limit,
        },
      };*/

      final response = await _dioClient.performCall(
        requestType: RequestType.post,
        url: baseUrl,
        headers: {'authtoken': authToken, 'visitortoken': visitorToken},
        data: requestBody,
      );

      if (response != null && response.statusCode == 200) {
        log('Searchautocomplete successful:${response.data}');

        if (response.data != null &&
            response.data is Map &&
            response.data['data'] != null &&
            response.data['data']['autoCompleteList'] is List) {
          final List results = response.data['data']['autoCompleteList'];
          return results.map((item) => SearchResult.fromJson(item)).toList();
        }
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
    try {
      final visitorToken = await LocalStorageService.getVisitorToken();

      if (visitorToken == null) {
        log('No visitor token found');
        return [];
      }

      final requestBody = {
        "action": "searchAutoComplete",
        "searchAutoComplete": {
          "inputText": "indi",
          "searchType": [
            "byCity",
            "byState",
            "byCountry",
            "byRandom",
            "byPropertyName", // you can put any searchType from the list
          ],
          "limit": 10,
        },
      }; /*{
        "action": "searchAutoComplete",
        "searchAutoComplete": {
          "inputText": inputText,
          "searchType": ["byCity", "byState", "byCountry", "byPropertyName"],
          "limit": 10,
        },
      };*/

      final response = await _dioClient.performCall(
        requestType: RequestType.post,
        url: baseUrl,
        headers: {'authtoken': authToken, 'visitortoken': visitorToken},
        data: requestBody,
      );

      if (response != null && response.statusCode == 200) {
        log('SearchAll successful:${response.data}');
        if (response.data != null &&
            response.data is Map &&
            response.data['data'] != null &&
            response.data['data']['autoCompleteList'] is List) {
          final List results = response.data['data']['autoCompleteList'];
          return results.map((item) => SearchResult.fromJson(item)).toList();
        }
      }

      return [];
    } catch (e) {
      log('Error searching all: $e');
      return [];
    }
  }
}
*/