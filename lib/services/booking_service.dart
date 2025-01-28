import 'package:prague_carsharing/models/vehicle.dart';

class BookingService {
  // Синглтон
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final List<Vehicle> _bookedVehicles = [];

  Future<void> bookVehicle(Vehicle vehicle) async {
    await Future.delayed(const Duration(seconds: 1));
    _bookedVehicles.add(vehicle);
  }

  List<Vehicle> getBookedVehicles() {
    return List.unmodifiable(_bookedVehicles);
  }

  Future<void> cancelBooking(String vehicleId) async {
    await Future.delayed(const Duration(seconds: 1));
    _bookedVehicles.removeWhere((vehicle) => vehicle.id == vehicleId);
  }
}
