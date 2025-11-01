class StaticHotel {
  final String name;
  final String location;
  final String price;
  final String rating;
  final String imageUrl;

  StaticHotel({
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
  });
}

// Static deal data model
class StaticDeal {
  final String name;
  final String location;
  final String price;
  final String rating;
  final String discount;
  final String imageUrl;

  StaticDeal({
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.discount,
    required this.imageUrl,
  });
}
