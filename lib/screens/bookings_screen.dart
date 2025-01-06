import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prague_carsharing/models/vehicle.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Здесь должна быть логика получения списка бронирований
    final bookings = [
      Vehicle(id: 'v1', name: 'Vehicle 1', distance: '100m away'),
      Vehicle(id: 'v2', name: 'Vehicle 2', distance: '200m away'),
      Vehicle(id: 'v3', name: 'Vehicle 3', distance: '300m away'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                FontAwesomeIcons.car,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(booking.name),
              subtitle: Text(booking.distance),
              trailing: IconButton(
                icon: const Icon(FontAwesomeIcons.xmark),
                onPressed: () {
                  // Здесь должна быть логика отмены бронирования
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
