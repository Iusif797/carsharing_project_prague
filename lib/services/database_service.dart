import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get users => _db.collection('users');
  CollectionReference get vehicles => _db.collection('vehicles');
  CollectionReference get bookings => _db.collection('bookings');
  CollectionReference get trips => _db.collection('trips');
  CollectionReference get reviews => _db.collection('reviews');

  Future<void> initializeDatabase() async {
    await _seedVehicles();
  }

  Future<void> _seedVehicles() async {
    try {
      final vehiclesSnapshot = await vehicles.limit(1).get().timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw TimeoutException('Firestore timeout'),
      );
      if (vehiclesSnapshot.docs.isNotEmpty) return;
    } catch (e) {
      return;
    }

    final List<Map<String, dynamic>> pragueCars = [
      {
        'id': 'prague_1',
        'name': 'Tesla Model 3',
        'brand': 'Tesla',
        'model': 'Model 3',
        'year': 2023,
        'city': 'Prague',
        'latitude': 50.0875 + (0.02 * (1 - 0.5)),
        'longitude': 14.4213 + (0.02 * (0.3 - 0.5)),
        'status': 'available',
        'batteryLevel': 85,
        'pricePerMinute': 0.35,
        'pricePerHour': 15,
        'pricePerDay': 80,
        'pricePerWeek': 450,
        'fuelType': 'electric',
        'transmission': 'automatic',
        'seats': 5,
        'image': 'https://images.unsplash.com/photo-1560958089-b8a1929cea89',
        'rating': 4.8,
        'totalTrips': 245,
      },
      {
        'id': 'prague_2',
        'name': 'BMW 3 Series',
        'brand': 'BMW',
        'model': '3 Series',
        'year': 2022,
        'city': 'Prague',
        'latitude': 50.0875 + (0.02 * (0.7 - 0.5)),
        'longitude': 14.4213 + (0.02 * (0.8 - 0.5)),
        'status': 'available',
        'batteryLevel': 100,
        'pricePerMinute': 0.40,
        'pricePerHour': 18,
        'pricePerDay': 90,
        'pricePerWeek': 500,
        'fuelType': 'petrol',
        'transmission': 'automatic',
        'seats': 5,
        'image': 'https://images.unsplash.com/photo-1555215695-3004980ad54e',
        'rating': 4.7,
        'totalTrips': 189,
      },
    ];

    final List<Map<String, dynamic>> brnoCars = [
      {
        'id': 'brno_1',
        'name': 'Škoda Octavia',
        'brand': 'Škoda',
        'model': 'Octavia',
        'year': 2023,
        'city': 'Brno',
        'latitude': 49.1951,
        'longitude': 16.6068,
        'status': 'available',
        'batteryLevel': 100,
        'pricePerMinute': 0.30,
        'pricePerHour': 12,
        'pricePerDay': 70,
        'pricePerWeek': 400,
        'fuelType': 'petrol',
        'transmission': 'manual',
        'seats': 5,
        'image': 'https://images.unsplash.com/photo-1583121274602-3e2820c69888',
        'rating': 4.6,
        'totalTrips': 156,
      },
    ];

    final List<Map<String, dynamic>> karlovyVaryCars = [
      {
        'id': 'karlovy_1',
        'name': 'Volkswagen Golf',
        'brand': 'Volkswagen',
        'model': 'Golf',
        'year': 2022,
        'city': 'Karlovy Vary',
        'latitude': 50.2329,
        'longitude': 12.8716,
        'status': 'available',
        'batteryLevel': 100,
        'pricePerMinute': 0.28,
        'pricePerHour': 10,
        'pricePerDay': 65,
        'pricePerWeek': 380,
        'fuelType': 'diesel',
        'transmission': 'manual',
        'seats': 5,
        'image': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d',
        'rating': 4.5,
        'totalTrips': 98,
      },
    ];

    final allCars = [...pragueCars, ...brnoCars, ...karlovyVaryCars];

    for (var car in allCars) {
      try {
        await vehicles.doc(car['id']).set(car).timeout(
          const Duration(seconds: 1),
          onTimeout: () => throw TimeoutException('Write timeout'),
        );
      } catch (e) {
        break;
      }
    }
  }

  Stream<QuerySnapshot> getVehiclesByCity(String city) {
    return vehicles.where('city', isEqualTo: city).snapshots();
  }

  Stream<QuerySnapshot> getAllVehicles() {
    return vehicles.snapshots();
  }

  Future<DocumentSnapshot> getVehicle(String vehicleId) {
    return vehicles.doc(vehicleId).get();
  }

  Future<String> createBooking({
    required String userId,
    required String vehicleId,
    required String pricingPlan,
    required double price,
  }) async {
    final bookingData = {
      'userId': userId,
      'vehicleId': vehicleId,
      'pricingPlan': pricingPlan,
      'price': price,
      'status': 'active',
      'startTime': FieldValue.serverTimestamp(),
      'endTime': null,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = await bookings.add(bookingData);
    
    await vehicles.doc(vehicleId).update({'status': 'booked'});

    return docRef.id;
  }

  Future<void> endBooking(String bookingId) async {
    await bookings.doc(bookingId).update({
      'status': 'completed',
      'endTime': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserBookings(String userId) {
    return bookings
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> createUser({
    required String uid,
    required String email,
    required String name,
  }) async {
    await users.doc(uid).set({
      'email': email,
      'name': name,
      'phoneNumber': '',
      'driversLicense': '',
      'totalTrips': 0,
      'totalSpent': 0.0,
      'memberSince': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return users.doc(uid).get();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return users.doc(uid).update(data);
  }
}
