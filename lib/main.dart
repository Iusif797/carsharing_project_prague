import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prague_carsharing/screens/onboarding_screen.dart';
import 'package:prague_carsharing/screens/login_screen.dart';
import 'package:prague_carsharing/screens/main_screen.dart';
import 'package:prague_carsharing/screens/map_screen.dart';
import 'package:prague_carsharing/screens/booking_screen.dart';
import 'package:prague_carsharing/providers/theme_provider.dart';
import 'package:prague_carsharing/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
  
  _initializeFirebaseAsync();
}

Future<void> _initializeFirebaseAsync() async {
  try {
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 3),
      onTimeout: () => throw TimeoutException('Firebase init timeout'),
    );
    await DatabaseService().initializeDatabase().timeout(
      const Duration(seconds: 2),
      onTimeout: () {},
    );
  } catch (e) {
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('onboardingComplete') ?? false;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!hasCompletedOnboarding) {
      return const OnboardingScreen();
    } else if (!isLoggedIn) {
      return const LoginScreen();
    } else {
      return const MainScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Prague Carsharing',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: FutureBuilder<Widget>(
            future: _getInitialScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return snapshot.data ?? const OnboardingScreen();
            },
          ),
          routes: {
            '/map': (context) => const MapScreen(),
            '/bookings': (context) => const BookingsScreen(),
            '/login': (context) => const LoginScreen(),
            '/main': (context) => const MainScreen(),
          },
        );
      },
    );
  }
}
