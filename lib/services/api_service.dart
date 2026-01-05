import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  String? _token;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> _headers({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<http.Response> get(String endpoint, {bool auth = true}) async {
    try {
      return await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers(includeAuth: auth),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool auth = true}) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers(includeAuth: auth),
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> patch(String endpoint, Map<String, dynamic> body, {bool auth = true}) async {
    try {
      return await http.patch(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers(includeAuth: auth),
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> delete(String endpoint, {bool auth = true}) async {
    try {
      return await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers(includeAuth: auth),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    final response = await post('auth/register', {
      'email': email,
      'password': password,
      'name': name,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    }, auth: false);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Registration failed');
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final response = await post('auth/login', {
      'email': email,
      'password': password,
    }, auth: false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
  }

  Future<void> logout() async {
    await clearToken();
  }

  Future<List<Map<String, dynamic>>> getVehicles({String? city}) async {
    final endpoint = city != null ? 'vehicles?city=$city' : 'vehicles';
    final response = await get(endpoint, auth: false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['vehicles']);
    }
    return [];
  }

  Future<Map<String, dynamic>?> getVehicle(String vehicleId) async {
    final response = await get('vehicles/$vehicleId', auth: false);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>?> createBooking({
    required String vehicleId,
    required String pricingPlan,
    required double totalPrice,
  }) async {
    final response = await post('bookings', {
      'vehicleId': vehicleId,
      'pricingPlan': pricingPlan,
      'totalPrice': totalPrice,
    });

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Booking failed');
  }

  Future<List<Map<String, dynamic>>> getMyBookings() async {
    final response = await get('bookings/my');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['bookings']);
    }
    return [];
  }

  Future<void> completeBooking(String bookingId) async {
    final response = await patch('bookings/$bookingId/complete', {});

    if (response.statusCode != 200) {
      throw Exception('Failed to complete booking');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    final response = await delete('bookings/$bookingId');

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel booking');
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final response = await get('users/me');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? driversLicense,
  }) async {
    final response = await patch('users/me', {
      if (name != null) 'name': name,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (driversLicense != null) 'driversLicense': driversLicense,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  Future<void> addReview({
    required String vehicleId,
    required int rating,
    String? comment,
  }) async {
    final response = await post('reviews', {
      'vehicleId': vehicleId,
      'rating': rating,
      if (comment != null) 'comment': comment,
    });

    if (response.statusCode != 201) {
      throw Exception('Failed to add review');
    }
  }

  Future<List<Map<String, dynamic>>> getVehicleReviews(String vehicleId) async {
    final response = await get('reviews/vehicle/$vehicleId', auth: false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['reviews']);
    }
    return [];
  }
}
