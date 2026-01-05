class Vehicle {
  final String id;
  final String name;
  final String brand;
  final String model;
  final int year;
  final String city;
  final double latitude;
  final double longitude;
  final String status;
  final double pricePerMinute;
  final double pricePerHour;
  final double pricePerDay;
  final double pricePerWeek;
  final String fuelType;
  final String transmission;
  final int seats;
  final double rating;
  final int batteryLevel;
  final String? imageUrl;
  String? distance;

  Vehicle({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.pricePerMinute,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.pricePerWeek,
    required this.fuelType,
    required this.transmission,
    required this.seats,
    required this.rating,
    required this.batteryLevel,
    this.imageUrl,
    this.distance,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      city: json['city'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      status: json['status'],
      pricePerMinute: double.parse(json['pricePerMinute'].toString()),
      pricePerHour: double.parse(json['pricePerHour'].toString()),
      pricePerDay: double.parse(json['pricePerDay'].toString()),
      pricePerWeek: double.parse(json['pricePerWeek'].toString()),
      fuelType: json['fuelType'],
      transmission: json['transmission'],
      seats: json['seats'],
      rating: double.parse(json['rating']?.toString() ?? '5.0'),
      batteryLevel: json['batteryLevel'] ?? 100,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'year': year,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'pricePerMinute': pricePerMinute,
      'pricePerHour': pricePerHour,
      'pricePerDay': pricePerDay,
      'pricePerWeek': pricePerWeek,
      'fuelType': fuelType,
      'transmission': transmission,
      'seats': seats,
      'rating': rating,
      'batteryLevel': batteryLevel,
      'imageUrl': imageUrl,
    };
  }
}
