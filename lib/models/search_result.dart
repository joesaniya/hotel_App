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
      id: json['id']?.toString() ?? 
          json['searchArray']?['query']?.first?.toString() ?? 
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['valueToDisplay'] ?? 
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
}

/*class SearchResult {
  final String id;
  final String name;
  final String type;
  final String? city;
  final String? state;
  final String? country;
  final String? imageUrl;

  SearchResult({
    required this.id,
    required this.name,
    required this.type,
    this.city,
    this.state,
    this.country,
    this.imageUrl,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['propertyName'] ?? '',
      type: json['type'] ?? 'hotel',
      city: json['city'],
      state: json['state'],
      country: json['country'],
      imageUrl: json['image'] ?? json['imageUrl'],
    );
  }

  String get displayLocation {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}*/