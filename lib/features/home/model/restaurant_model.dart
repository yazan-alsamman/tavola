class RestaurantModel {
  RestaurantModel({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.occasion,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.availabilityLabel,
    required this.isAvailable,
  });

  final String id;
  final String name;
  final String cuisine;
  final String occasion;
  final String description;
  final String imageUrl;
  final String location;
  final String availabilityLabel;
  final bool isAvailable;
}
