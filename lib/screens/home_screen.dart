import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prague_carsharing/models/vehicle.dart';
import 'package:prague_carsharing/services/booking_service.dart';

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
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Prague Carsharing'),
              background: Image.network(
                'https://example.com/prague_image.jpg',
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.bell),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCitySelector(),
                  const SizedBox(height: 24),
                  _buildWelcomeCard(),
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
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          icon: const Icon(FontAwesomeIcons.chevronDown),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 18,
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

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to $_selectedCity!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Ready for your next ride?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(FontAwesomeIcons.mapPin, 'Find Cars', () {}),
        _buildActionButton(FontAwesomeIcons.calendar, 'Book', () {}),
        _buildActionButton(FontAwesomeIcons.circleQuestion, 'Help', () {}),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildNearbyVehicles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby Vehicles',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            final vehicle = Vehicle(
              id: 'v$index',
              name: 'Vehicle ${index + 1}',
              distance: '${(index + 1) * 100}m away',
            );
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  FontAwesomeIcons.car,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(vehicle.name),
                subtitle: Text(vehicle.distance),
                trailing: ElevatedButton(
                  onPressed: () => _bookVehicle(vehicle),
                  child: const Text('Book'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _bookVehicle(Vehicle vehicle) async {
    try {
      await _bookingService.bookVehicle(vehicle);
      _showBookingConfirmation(vehicle);
    } catch (e) {
      _showErrorNotification('Failed to book vehicle: $e');
    }
  }

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
}
