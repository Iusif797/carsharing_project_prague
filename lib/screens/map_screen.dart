import 'package:flutter/material.dart';
import 'package:prague_carsharing/models/vehicle.dart';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Map<String, List<Vehicle>> _cityVehicles = {
    'Prague': [],
    'Brno': [],
    'Karlovy Vary': [],
  };

  final Map<String, LatLng> _cityCoordinates = {
    'Prague': LatLng(50.0755, 14.4378),
    'Brno': LatLng(49.1951, 16.6068),
    'Karlovy Vary': LatLng(50.2315, 12.8714),
  };

  @override
  void initState() {
    super.initState();
    _generateVehicles();
  }

  void _generateVehicles() {
    _cityVehicles['Prague'] = _generateVehiclesForCity('Prague', 300, 0.05);
    _cityVehicles['Brno'] = _generateVehiclesForCity('Brno', 150, 0.05);
    _cityVehicles['Karlovy Vary'] =
        _generateVehiclesForCity('Karlovy Vary', 50, 0.05);
  }

  List<Vehicle> _generateVehiclesForCity(
      String city, int count, double radius) {
    final random = Random();
    final cityCoord = _cityCoordinates[city]!;

    return List.generate(count, (index) {
      final r = random.nextGaussian() * radius;
      final theta = random.nextDouble() * 2 * pi;

      final lat = cityCoord.latitude + r * cos(theta);
      final lng = cityCoord.longitude + r * sin(theta);

      return Vehicle(
        id: '${city}_$index',
        name: 'Car ${index + 1}',
        latitude: lat,
        longitude: lng,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Sharing Map'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(49.8175, 15.4730), // Center of Czech Republic
              zoom: 7.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    _cityVehicles.forEach((city, vehicles) {
      for (var vehicle in vehicles) {
        markers.add(
          Marker(
            point: LatLng(vehicle.latitude, vehicle.longitude),
            width: 30,
            height: 30,
            builder: (context) => _buildVehicleMarker(_getCityColor(city)),
          ),
        );
      }

      // Add city marker
      markers.add(
        Marker(
          point: _cityCoordinates[city]!,
          width: 40,
          height: 40,
          builder: (context) => _buildCityMarker(city),
        ),
      );
    });

    return markers;
  }

  Widget _buildVehicleMarker(Color color) {
    return SvgPicture.asset(
      'assets/icons/car_icon.svg',
      color: color,
    );
  }

  Widget _buildCityMarker(String city) {
    return Container(
      decoration: BoxDecoration(
        color: _getCityColor(city).withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.location_city,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle Distribution',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._cityVehicles.entries.map((entry) => _buildLegendItem(
                entry.key,
                _getCityColor(entry.key),
                '${entry.value.length} cars',
              )),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String city, Color color, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$city: $count'),
        ],
      ),
    );
  }

  Color _getCityColor(String city) {
    switch (city) {
      case 'Prague':
        return Colors.red;
      case 'Brno':
        return Colors.blue;
      case 'Karlovy Vary':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

extension RandomExtension on Random {
  double nextGaussian() {
    double u1 = nextDouble();
    double u2 = nextDouble();
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }
}
