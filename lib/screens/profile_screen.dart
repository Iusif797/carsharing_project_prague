import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(FontAwesomeIcons.user, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildTextField('Name', 'Enter your name'),
          _buildTextField('Email', 'Enter your email'),
          _buildTextField('Phone', 'Enter your phone number'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement save profile
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Save Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
        ),
      ),
    );
  }
}
