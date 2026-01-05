# 📱 API Integration Guide for Flutter

## Базовый URL

**Development:** `http://localhost:3000/api`  
**Production:** `https://your-domain.com/api`

## Flutter HTTP Service

Создайте сервис в Flutter:

```dart
// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Future<http.Response> get(String endpoint) async {
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    return await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    return await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    return await http.patch(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    return await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
  }
}
```

## Примеры использования

### 1. Регистрация

```dart
final api = ApiService();

Future<void> register() async {
  final response = await api.post('auth/register', {
    'email': 'user@example.com',
    'password': 'password123',
    'name': 'John Doe',
    'phoneNumber': '+420123456789'
  });

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    api.setToken(data['token']);
    // Сохраните токен в SharedPreferences
  }
}
```

### 2. Вход

```dart
Future<void> login() async {
  final response = await api.post('auth/login', {
    'email': 'user@example.com',
    'password': 'password123'
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    api.setToken(data['token']);
  }
}
```

### 3. Получить машины

```dart
Future<List<Vehicle>> getVehicles({String? city}) async {
  final endpoint = city != null ? 'vehicles?city=$city' : 'vehicles';
  final response = await api.get(endpoint);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['vehicles'] as List)
        .map((v) => Vehicle.fromJson(v))
        .toList();
  }
  return [];
}
```

### 4. Создать бронирование

```dart
Future<void> createBooking(String vehicleId, String plan, double price) async {
  final response = await api.post('bookings', {
    'vehicleId': vehicleId,
    'pricingPlan': plan, // 'PER_MINUTE', 'HOURLY', 'DAILY', 'WEEKLY'
    'totalPrice': price
  });

  if (response.statusCode == 201) {
    print('Booking created!');
  }
}
```

### 5. Получить мои бронирования

```dart
Future<List<Booking>> getMyBookings() async {
  final response = await api.get('bookings/my');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['bookings'] as List)
        .map((b) => Booking.fromJson(b))
        .toList();
  }
  return [];
}
```

### 6. Завершить бронирование

```dart
Future<void> completeBooking(String bookingId) async {
  final response = await api.patch('bookings/$bookingId/complete', {});

  if (response.statusCode == 200) {
    print('Booking completed!');
  }
}
```

### 7. Оставить отзыв

```dart
Future<void> addReview(String vehicleId, int rating, String comment) async {
  final response = await api.post('reviews', {
    'vehicleId': vehicleId,
    'rating': rating, // 1-5
    'comment': comment
  });

  if (response.statusCode == 201) {
    print('Review added!');
  }
}
```

### 8. Обновить профиль

```dart
Future<void> updateProfile(String name, String phone, String license) async {
  final response = await api.patch('users/me', {
    'name': name,
    'phoneNumber': phone,
    'driversLicense': license
  });

  if (response.statusCode == 200) {
    print('Profile updated!');
  }
}
```

## Модели данных

### Vehicle Model

```dart
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

  Vehicle.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        brand = json['brand'],
        model = json['model'],
        year = json['year'],
        city = json['city'],
        latitude = double.parse(json['latitude'].toString()),
        longitude = double.parse(json['longitude'].toString()),
        status = json['status'],
        pricePerMinute = double.parse(json['pricePerMinute'].toString()),
        pricePerHour = double.parse(json['pricePerHour'].toString()),
        pricePerDay = double.parse(json['pricePerDay'].toString()),
        pricePerWeek = double.parse(json['pricePerWeek'].toString()),
        fuelType = json['fuelType'],
        transmission = json['transmission'],
        seats = json['seats'],
        rating = double.parse(json['rating'].toString());
}
```

### Booking Model

```dart
class Booking {
  final String id;
  final String vehicleId;
  final String pricingPlan;
  final double totalPrice;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;

  Booking.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        vehicleId = json['vehicleId'],
        pricingPlan = json['pricingPlan'],
        totalPrice = double.parse(json['totalPrice'].toString()),
        status = json['status'],
        startTime = DateTime.parse(json['startTime']),
        endTime = json['endTime'] != null
            ? DateTime.parse(json['endTime'])
            : null;
}
```

## Обработка ошибок

```dart
Future<void> handleApiCall() async {
  try {
    final response = await api.get('vehicles');

    if (response.statusCode == 200) {
      // Success
    } else if (response.statusCode == 401) {
      // Unauthorized - токен истек
      // Перенаправить на Login
    } else if (response.statusCode == 404) {
      // Not found
    } else {
      // Other error
      final error = jsonDecode(response.body);
      print(error['error']);
    }
  } catch (e) {
    // Network error
    print('Network error: $e');
  }
}
```

## Сохранение токена

```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
}
```

## iOS Configuration

В `ios/Runner/Info.plist` добавьте для localhost:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

## Android Configuration

В `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Testing

Для тестирования на реальном устройстве используйте IP компьютера:

```dart
static const String baseUrl = 'http://192.168.1.100:3000/api';
```

Найдите свой IP:

```bash
# macOS
ifconfig | grep "inet "

# Windows
ipconfig
```

Готово! 🚀
