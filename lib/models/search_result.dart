class SearchResult {
  final String id;
  final String name;
  final String type;
  final String? city;
  final String? state;
  final String? country;
  final String? imageUrl;
  final Map<String, dynamic>? searchArray;

  SearchResult({
    required this.id,
    required this.name,
    required this.type,
    this.city,
    this.state,
    this.country,
    this.imageUrl,
    this.searchArray,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json, String category) {
    final address = json['address'] as Map<String, dynamic>?;

    return SearchResult(
      id:
          json['id']?.toString() ??
          json['searchArray']?['query']?.first?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name:
          json['valueToDisplay'] ??
          json['propertyName'] ??
          json['name'] ??
          'Unknown',
      type: _getCategoryDisplayName(category),
      city: address?['city']?.toString(),
      state: address?['state']?.toString(),
      country: address?['country']?.toString(),
      imageUrl: json['image'] ?? json['imageUrl'],
     
      searchArray: json['searchArray'] as Map<String, dynamic>?,
    );
  }

  static String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'byPropertyName':
        return 'Hotel';
      case 'byCity':
        return 'City';
      case 'byState':
        return 'State';
      case 'byCountry':
        return 'Country';
      case 'byStreet':
        return 'Street';
      default:
        return 'Location';
    }
  }

  String get displayLocation {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  
  List<String> getSearchQueryList() {
    if (searchArray == null || searchArray!['query'] == null) {
      return [];
    }

    final queryList = searchArray!['query'];
    if (queryList is List) {
      return queryList.map((e) => e.toString()).toList();
    }

    return [];
  }


  String getSearchTypeForAPI() {
    switch (type.toLowerCase()) {
      case 'hotel':
        return 'hotelIdSearch';
      case 'city':
        return 'cityIdSearch';
      case 'state':
        return 'stateIdSearch';
      case 'country':
        return 'countryIdSearch';
      case 'street':
        return 'streetIdSearch';
      default:
        return 'cityIdSearch';
    }
  }
}
