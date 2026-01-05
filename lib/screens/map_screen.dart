import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:prague_carsharing/providers/theme_provider.dart';
import 'package:prague_carsharing/models/vehicle.dart';
import 'package:prague_carsharing/screens/new_home_screen.dart';
import 'package:prague_carsharing/services/api_service.dart';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _animationController;
  
  final Map<String, List<Vehicle>> _cityVehicles = {
    'Prague': [],
    'Brno': [],
    'Karlovy Vary': [],
  };

  final Map<String, LatLng> _cityCoordinates = {
    'Prague': const LatLng(50.0755, 14.4378),
    'Brno': const LatLng(49.1951, 16.6068),
    'Karlovy Vary': const LatLng(50.2315, 12.8714),
  };

  String _selectedCity = 'Prague';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadVehiclesFromApi();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadVehiclesFromApi() async {
    try {
      final api = ApiService();
      final vehiclesData = await api.getVehicles();
      
      if (vehiclesData.isNotEmpty) {
        final vehicles = vehiclesData.map((v) => Vehicle.fromJson(v)).toList();
        
        setState(() {
          _cityVehicles['Prague'] = vehicles.where((v) => v.city == 'Prague').toList();
          _cityVehicles['Brno'] = vehicles.where((v) => v.city == 'Brno').toList();
          _cityVehicles['Karlovy Vary'] = vehicles.where((v) => v.city == 'Karlovy Vary').toList();
        });
      } else {
        _generateDemoVehicles();
      }
    } catch (e) {
      print('Failed to load vehicles from API: $e');
      _generateDemoVehicles();
    }
  }

  void _generateDemoVehicles() {
    _cityVehicles['Prague'] = _generateVehiclesForCity('Prague', 50, 0.02);
    _cityVehicles['Brno'] = _generateVehiclesForCity('Brno', 30, 0.02);
    _cityVehicles['Karlovy Vary'] = _generateVehiclesForCity('Karlovy Vary', 15, 0.02);
  }

  List<Vehicle> _generateVehiclesForCity(String city, int count, double radius) {
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
        brand: 'Demo',
        model: 'Model X',
        year: 2023,
        city: city,
        latitude: lat,
        longitude: lng,
        status: 'AVAILABLE',
        pricePerMinute: 0.35,
        pricePerHour: 15,
        pricePerDay: 80,
        pricePerWeek: 450,
        fuelType: 'petrol',
        transmission: 'automatic',
        seats: 5,
        rating: 4.5,
        batteryLevel: 100,
      );
    });
  }

  void _moveToCity(String city) {
    setState(() {
      _selectedCity = city;
    });
    _mapController.move(_cityCoordinates[city]!, 12.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _cityCoordinates['Prague']!,
                  initialZoom: 12.0,
                  minZoom: 7.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.prague.carsharing',
                  ),
                  MarkerLayer(
                    markers: _buildMarkers(),
                  ),
                ],
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, isDark),
                    const SizedBox(height: 16),
                    _buildCitySelector(isDark),
                  ],
                ),
              ),
              Positioned(
                bottom: 90,
                right: 16,
                child: _buildMapControls(isDark),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark
                ? Colors.black.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.9),
            isDark ? Colors.transparent : Colors.white.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const NewHomeScreen(),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Available Cars',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: _cityCoordinates.keys.map((city) {
          final isSelected = city == _selectedCity;
          return Expanded(
            child: GestureDetector(
              onTap: () => _moveToCity(city),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2196F3),
                            const Color(0xFF1976D2),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      city,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[400] : Colors.grey[700]),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_cityVehicles[city]?.length ?? 0} cars',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : (isDark ? Colors.grey[600] : Colors.grey[500]),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMapControls(bool isDark) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () {
                  final currentCenter = _mapController.camera.center;
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(currentCenter, currentZoom + 1);
                },
              ),
              Container(
                height: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300],
              ),
              IconButton(
                icon: Icon(
                  Icons.remove,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () {
                  final currentCenter = _mapController.camera.center;
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(currentCenter, currentZoom - 1);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.my_location,
              color: const Color(0xFF2196F3),
            ),
            onPressed: () {
              _mapController.move(_cityCoordinates[_selectedCity]!, 12.0);
            },
          ),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    _cityVehicles.forEach((city, vehicles) {
      for (var vehicle in vehicles) {
        markers.add(
          Marker(
            point: LatLng(vehicle.latitude, vehicle.longitude),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showCarDetails(context, vehicle, city),
              child: _buildVehicleMarker(city == _selectedCity),
            ),
          ),
        );
      }
    });

    return markers;
  }

  Widget _buildVehicleMarker(bool isInSelectedCity) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.8, end: 1.0),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                FontAwesomeIcons.car,
                size: 20,
                color: isInSelectedCity
                    ? const Color(0xFF2196F3)
                    : Colors.grey[400],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCarDetails(BuildContext context, Vehicle vehicle, String city) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDark = themeProvider.isDarkMode;
          
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              String selectedPlan = 'hourly';
              
              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF2196F3),
                                    const Color(0xFF1976D2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: const Icon(
                                          FontAwesomeIcons.car,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vehicle.name,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  city,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white.withValues(alpha: 0.9),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF4CAF50),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Text(
                                                    'Available Now',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildCarSpec(
                                        icon: FontAwesomeIcons.gauge,
                                        value: '220',
                                        label: 'km/h',
                                      ),
                                      _buildCarSpec(
                                        icon: FontAwesomeIcons.gears,
                                        value: 'Auto',
                                        label: 'Transmission',
                                      ),
                                      _buildCarSpec(
                                        icon: FontAwesomeIcons.gasPump,
                                        value: 'Full',
                                        label: 'Fuel',
                                      ),
                                      _buildCarSpec(
                                        icon: FontAwesomeIcons.users,
                                        value: '5',
                                        label: 'Seats',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Pricing Plans',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => setModalState(() => selectedPlan = 'minute'),
                              child: _buildPricingOption(
                                icon: FontAwesomeIcons.clock,
                                title: 'Per Minute',
                                price: '€0.35',
                                period: 'per minute',
                                isDark: isDark,
                                isSelected: selectedPlan == 'minute',
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => setModalState(() => selectedPlan = 'hourly'),
                              child: _buildPricingOption(
                                icon: FontAwesomeIcons.hourglassHalf,
                                title: 'Hourly',
                                price: '€15',
                                period: 'per hour',
                                isDark: isDark,
                                isPopular: true,
                                isSelected: selectedPlan == 'hourly',
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => setModalState(() => selectedPlan = 'daily'),
                              child: _buildPricingOption(
                                icon: FontAwesomeIcons.calendarDay,
                                title: 'Daily',
                                price: '€80',
                                period: 'per day',
                                isDark: isDark,
                                isSelected: selectedPlan == 'daily',
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => setModalState(() => selectedPlan = 'weekly'),
                              child: _buildPricingOption(
                                icon: FontAwesomeIcons.calendarWeek,
                                title: 'Weekly',
                                price: '€450',
                                period: 'per week',
                                isDark: isDark,
                                discount: '20% Off',
                                isSelected: selectedPlan == 'weekly',
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF2196F3),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Fuel included. First 200 km free, then €0.25/km',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF2196F3),
                                    const Color(0xFF1976D2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2196F3).withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Booking ${vehicle.name} with $selectedPlan plan'),
                                      backgroundColor: const Color(0xFF4CAF50),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.circleCheck,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Book Now',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCarSpec({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 18,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingOption({
    required IconData icon,
    required String title,
    required String price,
    required String period,
    required bool isDark,
    bool isPopular = false,
    bool isSelected = false,
    String? discount,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isSelected || isPopular
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2196F3).withValues(alpha: 0.15),
                  const Color(0xFF1976D2).withValues(alpha: 0.15),
                ],
              )
            : null,
        color: isSelected || isPopular ? null : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF2196F3)
              : isPopular
                  ? const Color(0xFF2196F3)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.2)),
          width: isSelected ? 2.5 : (isPopular ? 2 : 1),
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected || isPopular
                ? const Color(0xFF2196F3).withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: isSelected || isPopular ? 16 : 12,
            offset: Offset(0, isSelected || isPopular ? 6 : 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2196F3),
                  const Color(0xFF1976D2),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    if (isPopular) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2196F3),
                              const Color(0xFF1976D2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'POPULAR',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isSelected) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2196F3),
                    const Color(0xFF1976D2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              if (discount != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    discount,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    final totalCars = _cityVehicles.values.fold<int>(0, (sum, list) => sum + list.length);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2196F3),
                      const Color(0xFF1976D2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  FontAwesomeIcons.car,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Available',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalCars Cars',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2196F3),
                  const Color(0xFF1976D2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Filter',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension RandomExtension on Random {
  double nextGaussian() {
    double u1 = nextDouble();
    double u2 = nextDouble();
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }
}
