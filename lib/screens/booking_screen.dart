import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prague_carsharing/models/vehicle.dart';
import 'package:prague_carsharing/services/booking_service.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookedVehicles = _bookingService.getBookedVehicles();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: bookedVehicles.isEmpty
                    ? _buildEmptyState(context)
                    : _buildBookingsList(bookedVehicles),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'My Bookings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.calendarXmark,
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(FontAwesomeIcons.car),
            label: const Text('Book a Car'),
            onPressed: () {
              // TODO: Navigate to car booking screen
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<Vehicle> bookedVehicles) {
    return ListView.builder(
      itemCount: bookedVehicles.length,
      itemBuilder: (context, index) {
        final booking = bookedVehicles[index];
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  index / bookedVehicles.length,
                  (index + 1) / bookedVehicles.length,
                  curve: Curves.easeOut,
                ),
              )),
              child: child,
            );
          },
          child: _buildBookingCard(booking),
        );
      },
    );
  }

  Widget _buildBookingCard(Vehicle booking) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.car,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    booking.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildCancelButton(booking),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(FontAwesomeIcons.locationDot, 'Location',
                '${booking.latitude.toStringAsFixed(4)}, ${booking.longitude.toStringAsFixed(4)}'),
            const SizedBox(height: 8),
            _buildInfoRow(FontAwesomeIcons.clock, 'Booked on',
                DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(Vehicle booking) {
    return ElevatedButton.icon(
      icon: const Icon(FontAwesomeIcons.xmark, size: 16),
      label: const Text('Cancel'),
      onPressed: () {
        _showCancellationDialog(booking);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  void _showCancellationDialog(Vehicle booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: Text(
              'Are you sure you want to cancel your booking for ${booking.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                setState(() {
                  _bookingService.cancelBooking(booking.id);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
