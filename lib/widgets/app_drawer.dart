import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:prague_carsharing/providers/theme_provider.dart';
import 'package:prague_carsharing/screens/profile_screen.dart';
import 'package:prague_carsharing/screens/booking_screen.dart';
import 'package:prague_carsharing/screens/settings_screen.dart';
import 'package:prague_carsharing/screens/about_us_screen.dart';
import 'package:prague_carsharing/screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  Future<String> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ?? 'user@example.com';
  }

  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'Guest User';
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Drawer(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          child: Column(
            children: [
              FutureBuilder<List<String>>(
                future: Future.wait([_getUserName(), _getUserEmail()]),
                builder: (context, snapshot) {
                  final userName = snapshot.data?[0] ?? 'Guest User';
                  final userEmail = snapshot.data?[1] ?? 'user@example.com';
                  
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2196F3),
                          const Color(0xFF1976D2),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            FontAwesomeIcons.user,
                            color: Color(0xFF2196F3),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildMenuItem(
                      context: context,
                      icon: FontAwesomeIcons.user,
                      title: 'Profile',
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: FontAwesomeIcons.clockRotateLeft,
                      title: 'My Bookings',
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookingsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: FontAwesomeIcons.wallet,
                      title: 'Payment Methods',
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment methods coming soon')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: FontAwesomeIcons.gift,
                      title: 'Rewards',
                      isDark: isDark,
                      badge: 'NEW',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Rewards coming soon')),
                        );
                      },
                    ),
                    const Divider(),
                    _buildMenuItem(
                      context: context,
                      icon: FontAwesomeIcons.gear,
                      title: 'Settings',
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: FontAwesomeIcons.circleInfo,
                      title: 'About Us',
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutUsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: FontAwesomeIcons.circleQuestion,
                      title: 'Help & Support',
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Help & Support coming soon')),
                        );
                      },
                    ),
                    const Divider(),
                    
                    _buildMenuItem(
                      context: context,
                      icon: isDark ? FontAwesomeIcons.sun : FontAwesomeIcons.moon,
                      title: isDark ? 'Light Mode' : 'Dark Mode',
                      isDark: isDark,
                      onTap: () {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: const EdgeInsets.all(16),
                child: _buildMenuItem(
                  context: context,
                  icon: FontAwesomeIcons.rightFromBracket,
                  title: 'Logout',
                  isDark: isDark,
                  textColor: Colors.red,
                  onTap: () => _logout(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
    String? badge,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? (isDark ? Colors.white : Colors.black87),
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? (isDark ? Colors.white : Colors.black87),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
