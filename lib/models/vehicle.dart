class Vehicle {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  String? distance;

  Vehicle({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.distance,
  });
}
