// Import necessary packages for Flutter, Firebase, and local files
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart';
import 'MainScreen.dart';
import 'AdminHomePage.dart';
import 'auth_helpers.dart';

// Define color constants for the app's theme
const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);   
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

// Sign up page widget for user registration
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

// State class for SignUpPage
class _SignUpPageState extends State<SignUpPage> {
  // Controllers for form fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Email input field
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            // Password input field, obscured for security
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            // First name input field
            TextField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name')),
            // Last name input field
            TextField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name')),
            const SizedBox(height: 20),
            // Sign up button
            ElevatedButton(
              onPressed: () async {
                // Print debug info
                print("Attempting to sign up with email: ${_emailController.text.trim()}");
                // Attempt to sign up with provided details
                final user = await signUp(_emailController.text.trim(), _passwordController.text.trim(), _firstNameController.text.trim(), _lastNameController.text.trim());
                print("User signed up: ${user?.uid}");

                if (!context.mounted) return;

                if (user != null) {
                  // Fetch user document to check role
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
                  // Navigate to admin home if admin, else main screen
                  if (userDoc.exists && userDoc['type'] == 'admin') {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminHomePage()));
                  } else {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
                  }
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}