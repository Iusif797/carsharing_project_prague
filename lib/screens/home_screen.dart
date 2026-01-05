import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prague_carsharing/models/vehicle.dart';
import 'package:prague_carsharing/services/booking_service.dart';
import 'package:prague_carsharing/screens/map_screen.dart';
import 'package:prague_carsharing/screens/car_booking_screen.dart';
import 'package:prague_carsharing/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCity = 'Prague';
  final List<String> _cities = ['Prague', 'Brno', 'Karlovy Vary'];
  final BookingService _bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.bars,
                    color: Colors.white,
                  ),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/prague_header.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(FontAwesomeIcons.car, color: Colors.white, size: 18),
                              SizedBox(width: 10),
                              Text(
                                'Prague Carsharing',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Welcome to $_selectedCity!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Find and book your perfect ride',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCitySelector(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildNearbyVehicles(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          icon: const Icon(FontAwesomeIcons.chevronDown),
          iconSize: 24,
          elevation: 16,
          isExpanded: true,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCity = newValue;
              });
            }
          },
          items: _cities.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                FontAwesomeIcons.mapLocationDot,
                'Find Cars',
                AppTheme.primaryGradient,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapScreen()),
                  );
                },
              ),
              _buildActionButton(
                FontAwesomeIcons.calendar,
                'Book Now',
                AppTheme.secondaryGradient,
                () {
                  _openBookingSheet();
                },
              ),
              _buildActionButton(
                FontAwesomeIcons.headset,
                'Support',
                AppTheme.successGradient,
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, LinearGradient gradient, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(20),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyVehicles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby Vehicles',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            final vehicleNames = ['Škoda Octavia', 'BMW X3', 'Audi A4'];
            final brands = ['Škoda', 'BMW', 'Audi'];
            final models = ['Octavia', 'X3', 'A4'];
            final vehicle = Vehicle(
              id: 'v$index',
              name: vehicleNames[index],
              brand: brands[index],
              model: models[index],
              year: 2023,
              city: 'Prague',
              latitude: 50.0755 + (index * 0.001),
              longitude: 14.4378 + (index * 0.001),
              status: 'available',
              pricePerMinute: 4.0 + (index * 0.5),
              pricePerHour: 180.0 + (index * 20.0),
              pricePerDay: 800.0 + (index * 100.0),
              pricePerWeek: 4500.0 + (index * 500.0),
              fuelType: 'petrol',
              transmission: 'automatic',
              seats: 5,
              rating: 4.5 + (index * 0.1),
              batteryLevel: 100,
              distance: '${(index + 1) * 100}m away',
            );
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FontAwesomeIcons.car,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  vehicle.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(vehicle.distance!),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CarBookingScreen(vehicle: vehicle),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Book'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Booking via bottom sheet is used instead of direct call

  void _showBookingConfirmation(Vehicle vehicle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully booked ${vehicle.name}!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'View Bookings',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/bookings');
          },
        ),
      ),
    );
  }

  void _showErrorNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  void _openBookingSheet({Vehicle? vehicle}) async {
    final Vehicle v = vehicle ??
        Vehicle(
          id: 'quick',
          name: 'Nearest Car',
          brand: 'Demo',
          model: 'Car',
          year: 2023,
          city: 'Prague',
          latitude: 50.0755,
          longitude: 14.4378,
          status: 'available',
          pricePerMinute: 4.0,
          pricePerHour: 180.0,
          pricePerDay: 800.0,
          pricePerWeek: 4500.0,
          fuelType: 'petrol',
          transmission: 'automatic',
          seats: 5,
          rating: 4.5,
          batteryLevel: 100,
        );

    DateTime now = DateTime.now();
    DateTime start = now.add(const Duration(minutes: 15));
    DateTime end = start.add(const Duration(hours: 2));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: StatefulBuilder(
                builder: (context, setSheetState) {
                  final hours = end.difference(start).inMinutes / 60.0;
                  final price = _estimatePrice(hours);
                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(FontAwesomeIcons.car, color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text('${v.latitude.toStringAsFixed(4)}, ${v.longitude.toStringAsFixed(4)}',
                                    style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDateTimePicker(
                        title: 'Start',
                        value: start,
                        onTap: () async {
                          final picked = await _pickDateTime(start);
                          if (picked != null) {
                            setSheetState(() {
                              start = picked;
                              if (!end.isAfter(start)) {
                                end = start.add(const Duration(hours: 1));
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDateTimePicker(
                        title: 'End',
                        value: end,
                        onTap: () async {
                          final picked = await _pickDateTime(end);
                          if (picked != null) {
                            setSheetState(() {
                              end = picked.isAfter(start) ? picked : start.add(const Duration(hours: 1));
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(FontAwesomeIcons.clock, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('${hours.toStringAsFixed(1)} h total',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 10),
                            Text('~ €${price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            Navigator.of(context).pop();
                            await _bookingService.bookVehicle(v);
                            if (!mounted) return;
                            _showBookingConfirmation(v);
                          } catch (e) {
                            if (!mounted) return;
                            _showErrorNotification('Failed to book vehicle: $e');
                          }
                        },
                        icon: const Icon(FontAwesomeIcons.check),
                        label: const Text('Confirm Booking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  double _estimatePrice(double hours) {
    const double base = 1.99; // service fee
    const double perHour = 7.5;
    return base + perHour * hours.clamp(1.0, 24.0);
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return null;
    if (!mounted) return null;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    if (!mounted) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Widget _buildDateTimePicker({
    required String title,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            const Icon(FontAwesomeIcons.calendarDay, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    value.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(FontAwesomeIcons.chevronRight, size: 14, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}


