class Restaurant {
  final String name;
  final String municipality;
  final String categories;
  final double rating;
  final int topicId;
  final String topicLabel;
  final double? lat;
  final double? lon;

  Restaurant({
    required this.name,
    required this.municipality,
    required this.categories,
    required this.rating,
    required this.topicId,
    required this.topicLabel,
    this.lat,
    this.lon,
  });

  // This function converts the JSON data into a Dart Object
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['Name'] ?? 'Unknown',
      municipality: json['Municipality'] ?? 'Unknown',
      categories: json['Categories'] ?? 'N/A',
      rating: (json['Rating'] as num).toDouble(),
      topicId: json['Main_Topic_ID'] ?? -1,
      topicLabel: json['Topic_Label'] ?? 'General',
      lat: json['Latitude'] is double ? json['Latitude'] : null,
      lon: json['Longitude'] is double ? json['Longitude'] : null,
    );
  }
}