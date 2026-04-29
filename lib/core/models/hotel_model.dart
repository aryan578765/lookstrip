/// Hotel search result from SerpApi
class Hotel {
  final String name;
  final double rating;
  final int reviews;
  final double pricePerNight;
  final String currency;
  final String imageUrl;
  final List<String> amenities;
  final String address;
  final String type; // Hotel, Resort, Hostel, etc.

  const Hotel({
    required this.name,
    required this.rating,
    this.reviews = 0,
    required this.pricePerNight,
    this.currency = 'USD',
    this.imageUrl = '',
    this.amenities = const [],
    this.address = '',
    this.type = 'Hotel',
  });

  factory Hotel.fromSerpApi(Map<String, dynamic> json) {
    final prices = json['rate_per_night'] as Map<String, dynamic>?;
    final priceStr = prices?['lowest'] as String? ?? '\$0';
    final priceNum =
        double.tryParse(priceStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;

    return Hotel(
      name: json['name'] as String? ?? 'Unknown Hotel',
      rating: (json['overall_rating'] as num?)?.toDouble() ?? 0,
      reviews: json['reviews'] as int? ?? 0,
      pricePerNight: priceNum,
      currency: 'USD',
      imageUrl: (json['images'] as List?)?.isNotEmpty == true
          ? (json['images'] as List).first['thumbnail'] as String? ?? ''
          : '',
      amenities:
          (json['amenities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .take(5)
              .toList() ??
          [],
      address: json['address'] as String? ?? '',
      type: json['type'] as String? ?? 'Hotel',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'rating': rating,
    'reviews': reviews,
    'price_per_night': pricePerNight,
    'currency': currency,
    'image_url': imageUrl,
    'amenities': amenities,
    'address': address,
    'type': type,
  };

  factory Hotel.fromJson(Map<String, dynamic> json) => Hotel(
    name: json['name'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    reviews: json['reviews'] as int? ?? 0,
    pricePerNight: (json['price_per_night'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'USD',
    imageUrl: json['image_url'] as String? ?? '',
    amenities:
        (json['amenities'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    address: json['address'] as String? ?? '',
    type: json['type'] as String? ?? 'Hotel',
  );

  String get priceLabel => '\$${pricePerNight.toStringAsFixed(0)}/night';
  String get ratingLabel => rating > 0 ? rating.toStringAsFixed(1) : 'N/A';
}
