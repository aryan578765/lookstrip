/// Restaurant/place result from SerpApi Google Maps
class Restaurant {
  final String name;
  final double rating;
  final int reviews;
  final String cuisine;
  final String priceLevel; // $, $$, $$$
  final String address;
  final String imageUrl;
  final String hours;
  final double? lat;
  final double? lng;

  const Restaurant({
    required this.name,
    required this.rating,
    this.reviews = 0,
    this.cuisine = '',
    this.priceLevel = '',
    this.address = '',
    this.imageUrl = '',
    this.hours = '',
    this.lat,
    this.lng,
  });

  factory Restaurant.fromSerpApi(Map<String, dynamic> json) {
    return Restaurant(
      name: json['title'] as String? ?? json['name'] as String? ?? 'Unknown',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviews: json['reviews'] as int? ?? 0,
      cuisine: json['type'] as String? ?? '',
      priceLevel: json['price'] as String? ?? '',
      address: json['address'] as String? ?? '',
      imageUrl: json['thumbnail'] as String? ?? '',
      hours: json['hours'] as String? ?? '',
      lat: (json['gps_coordinates']?['latitude'] as num?)?.toDouble(),
      lng: (json['gps_coordinates']?['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'rating': rating,
    'reviews': reviews,
    'cuisine': cuisine,
    'price_level': priceLevel,
    'address': address,
    'image_url': imageUrl,
    'hours': hours,
    'lat': lat,
    'lng': lng,
  };

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    name: json['name'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    reviews: json['reviews'] as int? ?? 0,
    cuisine: json['cuisine'] as String? ?? '',
    priceLevel: json['price_level'] as String? ?? '',
    address: json['address'] as String? ?? '',
    imageUrl: json['image_url'] as String? ?? '',
    hours: json['hours'] as String? ?? '',
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
  );
}

/// Attraction/POI from SerpApi Google Local
class Attraction {
  final String name;
  final double rating;
  final int reviews;
  final String type;
  final String description;
  final String address;
  final String imageUrl;
  final double? lat;
  final double? lng;

  const Attraction({
    required this.name,
    required this.rating,
    this.reviews = 0,
    this.type = '',
    this.description = '',
    this.address = '',
    this.imageUrl = '',
    this.lat,
    this.lng,
  });

  factory Attraction.fromSerpApi(Map<String, dynamic> json) {
    return Attraction(
      name: json['title'] as String? ?? json['name'] as String? ?? 'Unknown',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviews: json['reviews'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      description:
          json['description'] as String? ?? json['snippet'] as String? ?? '',
      address: json['address'] as String? ?? '',
      imageUrl: json['thumbnail'] as String? ?? '',
      lat: (json['gps_coordinates']?['latitude'] as num?)?.toDouble(),
      lng: (json['gps_coordinates']?['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'rating': rating,
    'reviews': reviews,
    'type': type,
    'description': description,
    'address': address,
    'image_url': imageUrl,
    'lat': lat,
    'lng': lng,
  };

  factory Attraction.fromJson(Map<String, dynamic> json) => Attraction(
    name: json['name'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    reviews: json['reviews'] as int? ?? 0,
    type: json['type'] as String? ?? '',
    description: json['description'] as String? ?? '',
    address: json['address'] as String? ?? '',
    imageUrl: json['image_url'] as String? ?? '',
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
  );
}
