class Hotel {
  final String propertyCode;
  final String propertyName;
  final PropertyImage? propertyImage;
  final String propertyType;
  final int propertyStar;
  final PropertyAddress? propertyAddress;
  final String propertyUrl;
  final String roomName;
  final int numberOfAdults;
  final PriceInfo? markedPrice;
  final PriceInfo? propertyMaxPrice;
  final PriceInfo? propertyMinPrice;
  final List<Deal> availableDeals;
  final GoogleReview? googleReview;
  final SimplPriceList? simplPriceList;
  final PropertyPolicies? propertyPolicies;

  Hotel({
    required this.propertyCode,
    required this.propertyName,
    this.propertyImage,
    required this.propertyType,
    required this.propertyStar,
    this.propertyAddress,
    required this.propertyUrl,
    required this.roomName,
    required this.numberOfAdults,
    this.markedPrice,
    this.propertyMaxPrice,
    this.propertyMinPrice,
    required this.availableDeals,
    this.googleReview,
    this.simplPriceList,
    this.propertyPolicies,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      propertyCode: json['propertyCode'] ?? '',
      propertyName: json['propertyName'] ?? '',
      propertyImage: json['propertyImage'] != null
          ? PropertyImage.fromJson(json['propertyImage'])
          : null,
      propertyType: json['propertytype'] ?? 'Hotel',
      propertyStar: json['propertyStar'] ?? 0,
      propertyAddress: json['propertyAddress'] != null
          ? PropertyAddress.fromJson(json['propertyAddress'])
          : null,
      propertyUrl: json['propertyUrl'] ?? '',
      roomName: json['roomName'] ?? '',
      numberOfAdults: json['numberOfAdults'] ?? 0,
      markedPrice: json['markedPrice'] != null
          ? PriceInfo.fromJson(json['markedPrice'])
          : null,
      propertyMaxPrice: json['propertyMaxPrice'] != null
          ? PriceInfo.fromJson(json['propertyMaxPrice'])
          : null,
      propertyMinPrice: json['propertyMinPrice'] != null
          ? PriceInfo.fromJson(json['propertyMinPrice'])
          : null,
      availableDeals: json['availableDeals'] != null
          ? (json['availableDeals'] as List)
              .map((deal) => Deal.fromJson(deal))
              .toList()
          : [],
      googleReview: json['googleReview'] != null &&
              json['googleReview']['reviewPresent'] == true
          ? GoogleReview.fromJson(json['googleReview']['data'])
          : null,
      simplPriceList: json['simplPriceList'] != null
          ? SimplPriceList.fromJson(json['simplPriceList'])
          : null,
      propertyPolicies: json['propertyPoliciesAndAmmenities'] != null &&
              json['propertyPoliciesAndAmmenities']['present'] == true
          ? PropertyPolicies.fromJson(
              json['propertyPoliciesAndAmmenities']['data'])
          : null,
    );
  }
}

class PropertyImage {
  final String fullUrl;
  final String location;
  final String imageName;

  PropertyImage({
    required this.fullUrl,
    required this.location,
    required this.imageName,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      fullUrl: json['fullUrl'] ?? '',
      location: json['location'] ?? '',
      imageName: json['imageName'] ?? '',
    );
  }
}

class PropertyAddress {
  final String street;
  final String city;
  final String state;
  final String country;
  final String zipcode;
  final double? latitude;
  final double? longitude;

  PropertyAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.zipcode,
    this.latitude,
    this.longitude,
  });

  factory PropertyAddress.fromJson(Map<String, dynamic> json) {
    return PropertyAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipcode: json['zipcode'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  String get fullAddress {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }
}

class PriceInfo {
  final double amount;
  final String displayAmount;
  final String currencySymbol;

  PriceInfo({
    required this.amount,
    required this.displayAmount,
    required this.currencySymbol,
  });

  factory PriceInfo.fromJson(Map<String, dynamic> json) {
    return PriceInfo(
      amount: (json['amount'] ?? 0).toDouble(),
      displayAmount: json['displayAmount'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '₹',
    );
  }
}

class Deal {
  final String headerName;
  final String websiteUrl;
  final String dealType;
  final PriceInfo price;

  Deal({
    required this.headerName,
    required this.websiteUrl,
    required this.dealType,
    required this.price,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      headerName: json['headerName'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',
      dealType: json['dealType'] ?? '',
      price: PriceInfo.fromJson(json['price'] ?? {}),
    );
  }
}

class GoogleReview {
  final double overallRating;
  final int totalUserRating;
  final int withoutDecimal;

  GoogleReview({
    required this.overallRating,
    required this.totalUserRating,
    required this.withoutDecimal,
  });

  factory GoogleReview.fromJson(Map<String, dynamic> json) {
    return GoogleReview(
      overallRating: (json['overallRating'] ?? 0).toDouble(),
      totalUserRating: json['totalUserRating'] ?? 0,
      withoutDecimal: json['withoutDecimal'] ?? 0,
    );
  }
}

class SimplPriceList {
  final PriceInfo simplPrice;
  final double originalPrice;

  SimplPriceList({
    required this.simplPrice,
    required this.originalPrice,
  });

  factory SimplPriceList.fromJson(Map<String, dynamic> json) {
    return SimplPriceList(
      simplPrice: PriceInfo.fromJson(json['simplPrice'] ?? {}),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
    );
  }
}

class PropertyPolicies {
  final bool petsAllowed;
  final bool coupleFriendly;
  final bool suitableForChildren;
  final bool bachularsAllowed;
  final bool freeWifi;
  final bool freeCancellation;
  final bool payAtHotel;
  final bool payNow;
  final String? cancelPolicy;
  final String? childPolicy;

  PropertyPolicies({
    required this.petsAllowed,
    required this.coupleFriendly,
    required this.suitableForChildren,
    required this.bachularsAllowed,
    required this.freeWifi,
    required this.freeCancellation,
    required this.payAtHotel,
    required this.payNow,
    this.cancelPolicy,
    this.childPolicy,
  });

  factory PropertyPolicies.fromJson(Map<String, dynamic> json) {
    return PropertyPolicies(
      petsAllowed: json['petsAllowed'] ?? false,
      coupleFriendly: json['coupleFriendly'] ?? false,
      suitableForChildren: json['suitableForChildren'] ?? false,
      bachularsAllowed: json['bachularsAllowed'] ?? false,
      freeWifi: json['freeWifi'] ?? false,
      freeCancellation: json['freeCancellation'] ?? false,
      payAtHotel: json['payAtHotel'] ?? false,
      payNow: json['payNow'] ?? false,
      cancelPolicy: json['cancelPolicy'],
      childPolicy: json['childPolicy'],
    );
  }
}