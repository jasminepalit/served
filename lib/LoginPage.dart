// Import necessary packages for Flutter, Firebase, and local files
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:served/AdminHomePage.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'MainScreen.dart';
import 'SignUpPage.dart';
import 'auth_helpers.dart';
import 'AdminDatabaseView.dart';
import 'AdminMainScreen.dart';

// Define color constants for the app's theme
const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

// Login page widget for user authentication
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// State class for LoginPage
class _LoginPageState extends State<LoginPage> {
  // Controllers for email and password text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title
      appBar: AppBar(title: const Text('Login')
    
      ),
      body: Center(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Email input field
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            // Password input field, obscured for security
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            // Login button
            ElevatedButton(
            onPressed: () async {
              // Attempt to sign in with provided credentials
              final user = await signIn(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              );
              if (!context.mounted) return;

              if (user != null) {
                      // Fetch user document from Firestore
                      DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .get();

            if (!context.mounted) return;

            // Check if user is inactive and sign out if so
            if (userDoc.exists && userDoc['status'] == 'Inactive') {
              signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }

            // Navigate to admin screen if user is admin, else to main screen
            if (userDoc.exists && userDoc['type'] == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminMainScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
              }
              }
            },
            child: const Text('Login'),
          ),
          const SizedBox(height: 12),
            // Sign up button to navigate to sign up page
            OutlinedButton(
              onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(),
                    ),
                  );
                
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
        ),
        ),
      ),
      ),
    );
  }
}

