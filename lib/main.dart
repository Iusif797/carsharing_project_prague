import 'package:flutter/material.dart';
import 'package:prague_carsharing/screens/main_screen.dart';
import 'package:prague_carsharing/screens/bookings_screen.dart';
import 'package:prague_carsharing/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prague Carsharing',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/bookings': (context) => const BookingsScreen(),
      },
    );
  }
}
