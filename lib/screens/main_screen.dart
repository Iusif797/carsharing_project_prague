import 'package:flutter/material.dart';
import 'package:prague_carsharing/screens/new_home_screen.dart';
import 'package:prague_carsharing/screens/map_screen.dart';
import 'package:prague_carsharing/screens/booking_screen.dart';
import 'package:prague_carsharing/screens/profile_screen.dart';
import 'package:prague_carsharing/widgets/custom_bottom_nav.dart';
import 'package:prague_carsharing/widgets/custom_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const NewHomeScreen(),
    const MapScreen(),
    const BookingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      endDrawer: const CustomDrawer(),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
