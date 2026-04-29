/// Destination model for Explore screen
class Destination {
  final String id;
  final String name;
  final String country;
  final String continent;
  final String emoji;
  final String description;
  final double rating;
  final String priceLevel; // '$', '$$', '$$$'
  final List<String> categories; // Beach, Mountains, City, etc.
  final String bestSeason;
  final String imageKeyword; // for future image loading

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.continent,
    required this.emoji,
    required this.description,
    required this.rating,
    required this.priceLevel,
    required this.categories,
    required this.bestSeason,
    required this.imageKeyword,
  });
}

/// Static destination data — curated list
class DestinationData {
  static const allCategories = [
    'All',
    '🏖️ Beach',
    '🏔️ Mountains',
    '🏙️ City',
    '🏛️ Culture',
    '🍽️ Food',
    '🌿 Nature',
    '🎉 Nightlife',
  ];

  static const continents = [
    'All',
    '🌏 Asia',
    '🌍 Europe',
    '🌎 Americas',
    '🌍 Africa',
    '🌏 Oceania',
  ];

  static const List<Destination> destinations = [
    // ─── Asia ───
    Destination(
      id: 'bali',
      name: 'Bali',
      country: 'Indonesia',
      continent: 'Asia',
      emoji: '🏝️',
      description:
          'Tropical paradise with ancient temples, rice terraces, and world-class surfing.',
      rating: 4.8,
      priceLevel: '\$\$',
      categories: ['Beach', 'Culture', 'Nature'],
      bestSeason: 'Apr–Oct',
      imageKeyword: 'bali temple',
    ),
    Destination(
      id: 'tokyo',
      name: 'Tokyo',
      country: 'Japan',
      continent: 'Asia',
      emoji: '🗼',
      description:
          'Ultra-modern city blending neon-lit streets with serene shrines and world-class cuisine.',
      rating: 4.9,
      priceLevel: '\$\$\$',
      categories: ['City', 'Food', 'Culture'],
      bestSeason: 'Mar–May',
      imageKeyword: 'tokyo city',
    ),
    Destination(
      id: 'phuket',
      name: 'Phuket',
      country: 'Thailand',
      continent: 'Asia',
      emoji: '🌊',
      description:
          'Crystal-clear waters, vibrant nightlife, and stunning limestone cliffs.',
      rating: 4.6,
      priceLevel: '\$',
      categories: ['Beach', 'Nightlife', 'Food'],
      bestSeason: 'Nov–Apr',
      imageKeyword: 'phuket beach',
    ),
    Destination(
      id: 'seoul',
      name: 'Seoul',
      country: 'South Korea',
      continent: 'Asia',
      emoji: '🇰🇷',
      description:
          'K-pop capital with traditional palaces, street food, and cutting-edge technology.',
      rating: 4.7,
      priceLevel: '\$\$',
      categories: ['City', 'Food', 'Culture'],
      bestSeason: 'Sep–Nov',
      imageKeyword: 'seoul korea',
    ),
    Destination(
      id: 'maldives',
      name: 'Maldives',
      country: 'Maldives',
      continent: 'Asia',
      emoji: '🏖️',
      description:
          'Overwater villas, turquoise lagoons, and the most pristine beaches on Earth.',
      rating: 4.9,
      priceLevel: '\$\$\$',
      categories: ['Beach', 'Nature'],
      bestSeason: 'Nov–Apr',
      imageKeyword: 'maldives resort',
    ),

    // ─── Europe ───
    Destination(
      id: 'paris',
      name: 'Paris',
      country: 'France',
      continent: 'Europe',
      emoji: '🗼',
      description:
          'City of Light — world-class art, fashion, cuisine, and the iconic Eiffel Tower.',
      rating: 4.8,
      priceLevel: '\$\$\$',
      categories: ['City', 'Food', 'Culture'],
      bestSeason: 'Apr–Jun',
      imageKeyword: 'paris eiffel',
    ),
    Destination(
      id: 'santorini',
      name: 'Santorini',
      country: 'Greece',
      continent: 'Europe',
      emoji: '🏛️',
      description:
          'White-washed buildings, blue domes, volcanic beaches, and legendary sunsets.',
      rating: 4.9,
      priceLevel: '\$\$\$',
      categories: ['Beach', 'Culture'],
      bestSeason: 'Jun–Sep',
      imageKeyword: 'santorini greece',
    ),
    Destination(
      id: 'barcelona',
      name: 'Barcelona',
      country: 'Spain',
      continent: 'Europe',
      emoji: '🇪🇸',
      description:
          'Gaudí architecture, Mediterranean beaches, tapas bars, and vibrant nightlife.',
      rating: 4.7,
      priceLevel: '\$\$',
      categories: ['City', 'Beach', 'Nightlife', 'Food'],
      bestSeason: 'May–Jun',
      imageKeyword: 'barcelona spain',
    ),
    Destination(
      id: 'swiss_alps',
      name: 'Swiss Alps',
      country: 'Switzerland',
      continent: 'Europe',
      emoji: '🏔️',
      description:
          'Majestic peaks, pristine lakes, ski resorts, and charming mountain villages.',
      rating: 4.8,
      priceLevel: '\$\$\$',
      categories: ['Mountains', 'Nature'],
      bestSeason: 'Dec–Mar / Jun–Sep',
      imageKeyword: 'swiss alps',
    ),
    Destination(
      id: 'amsterdam',
      name: 'Amsterdam',
      country: 'Netherlands',
      continent: 'Europe',
      emoji: '🇳🇱',
      description:
          'Canal-laced city with world-class museums, cycling culture, and cozy cafés.',
      rating: 4.6,
      priceLevel: '\$\$',
      categories: ['City', 'Culture', 'Nightlife'],
      bestSeason: 'Apr–May',
      imageKeyword: 'amsterdam canals',
    ),

    // ─── Americas ───
    Destination(
      id: 'new_york',
      name: 'New York',
      country: 'USA',
      continent: 'Americas',
      emoji: '🗽',
      description:
          'The city that never sleeps — Broadway, Central Park, and the world\'s best food scene.',
      rating: 4.7,
      priceLevel: '\$\$\$',
      categories: ['City', 'Food', 'Culture', 'Nightlife'],
      bestSeason: 'Apr–Jun',
      imageKeyword: 'new york city',
    ),
    Destination(
      id: 'cancun',
      name: 'Cancún',
      country: 'Mexico',
      continent: 'Americas',
      emoji: '🏖️',
      description:
          'Caribbean beaches, Mayan ruins, cenotes, and all-inclusive resorts.',
      rating: 4.5,
      priceLevel: '\$\$',
      categories: ['Beach', 'Culture', 'Nightlife'],
      bestSeason: 'Dec–Apr',
      imageKeyword: 'cancun mexico',
    ),
    Destination(
      id: 'rio',
      name: 'Rio de Janeiro',
      country: 'Brazil',
      continent: 'Americas',
      emoji: '🇧🇷',
      description:
          'Christ the Redeemer, Copacabana, samba music, and Carnival energy year-round.',
      rating: 4.6,
      priceLevel: '\$\$',
      categories: ['Beach', 'City', 'Nightlife', 'Culture'],
      bestSeason: 'Dec–Mar',
      imageKeyword: 'rio de janeiro',
    ),
    Destination(
      id: 'banff',
      name: 'Banff',
      country: 'Canada',
      continent: 'Americas',
      emoji: '🏔️',
      description:
          'Turquoise lakes, towering Rockies, wildlife, and world-class hiking trails.',
      rating: 4.8,
      priceLevel: '\$\$',
      categories: ['Mountains', 'Nature'],
      bestSeason: 'Jun–Sep',
      imageKeyword: 'banff canada',
    ),

    // ─── Africa ───
    Destination(
      id: 'cape_town',
      name: 'Cape Town',
      country: 'South Africa',
      continent: 'Africa',
      emoji: '🇿🇦',
      description:
          'Table Mountain, Cape Winelands, penguins, and stunning coastal drives.',
      rating: 4.7,
      priceLevel: '\$\$',
      categories: ['City', 'Beach', 'Nature'],
      bestSeason: 'Nov–Mar',
      imageKeyword: 'cape town',
    ),
    Destination(
      id: 'marrakech',
      name: 'Marrakech',
      country: 'Morocco',
      continent: 'Africa',
      emoji: '🇲🇦',
      description:
          'Vibrant souks, riads, the Sahara nearby, and flavors you\'ll never forget.',
      rating: 4.5,
      priceLevel: '\$',
      categories: ['Culture', 'Food'],
      bestSeason: 'Mar–May',
      imageKeyword: 'marrakech morocco',
    ),

    // ─── Oceania ───
    Destination(
      id: 'sydney',
      name: 'Sydney',
      country: 'Australia',
      continent: 'Oceania',
      emoji: '🇦🇺',
      description:
          'Harbour Bridge, Opera House, Bondi Beach, and laid-back coastal lifestyle.',
      rating: 4.7,
      priceLevel: '\$\$\$',
      categories: ['City', 'Beach', 'Nature'],
      bestSeason: 'Sep–Nov',
      imageKeyword: 'sydney australia',
    ),
    Destination(
      id: 'queenstown',
      name: 'Queenstown',
      country: 'New Zealand',
      continent: 'Oceania',
      emoji: '🇳🇿',
      description:
          'Adventure capital — bungee jumping, skiing, fjords, and Lord of the Rings scenery.',
      rating: 4.8,
      priceLevel: '\$\$',
      categories: ['Mountains', 'Nature'],
      bestSeason: 'Dec–Feb',
      imageKeyword: 'queenstown nz',
    ),
  ];

  /// Filter destinations
  static List<Destination> filter({
    String? category,
    String? continent,
    String? searchQuery,
  }) {
    var results = destinations;

    if (category != null && category != 'All' && !category.startsWith('All')) {
      // Strip emoji prefix if present
      final cleanCat = category.replaceAll(RegExp(r'^[^\w]+\s*'), '');
      results = results.where((d) => d.categories.contains(cleanCat)).toList();
    }

    if (continent != null &&
        continent != 'All' &&
        !continent.startsWith('All')) {
      final cleanContinent = continent.replaceAll(RegExp(r'^[^\w]+\s*'), '');
      results = results.where((d) => d.continent == cleanContinent).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results
          .where(
            (d) =>
                d.name.toLowerCase().contains(q) ||
                d.country.toLowerCase().contains(q) ||
                d.description.toLowerCase().contains(q) ||
                d.categories.any((c) => c.toLowerCase().contains(q)),
          )
          .toList();
    }

    return results;
  }
}
