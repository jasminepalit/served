/**
 * This file defines the SignUpPage widget, which allows users to create a new account by providing their email, password, first name, last name, and year of graduation. It uses Firebase Authentication for user registration and Firestore to store additional user information. After successful sign-up, it checks the user's role and navigates to the appropriate home page (admin or regular user). The page also includes a button to navigate to the login page for existing users.
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart';
import 'MainScreen.dart';
import 'AdminHomePage.dart';
import 'auth_helpers.dart';


const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);   
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

/**
 * SignUpPage is a StatefulWidget that provides a user interface for new users to create an account. It includes text fields for email, password, first name, last name, and year of graduation. When the user presses the "Sign Up" button, it attempts to create a new user with Firebase Authentication and stores additional user information in Firestore. Depending on the user's role (admin or regular), it navigates to the appropriate home page. There is also a button to navigate to the login page for existing users.
 */
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}
/**
 * _SignUpPageState is the state class for SignUpPage. It manages the state of the text fields for email, password, first name, last name, and year of graduation. The build method constructs the user interface, which includes text fields for user input and buttons for signing up and navigating to the login page. The sign-up button triggers an asynchronous function that attempts to create a new user with Firebase Authentication and checks the user's role in Firestore to navigate to the appropriate home page.
 */
class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _yogController = TextEditingController();

/**
 * The build method constructs the user interface for the SignUpPage. It includes an AppBar with the title "Sign Up" and a body that contains a column of text fields for email, password, first name, last name, and year of graduation. There are also two buttons: one for signing up and another for navigating to the login page. The sign-up button triggers an asynchronous function that attempts to create a new user with Firebase Authentication and checks the user's role in Firestore to navigate to the appropriate home page (admin or regular user). The login button navigates to the LoginPage for existing users.
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name')),
            TextField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name')),
            TextField(controller: _yogController, decoration: const InputDecoration(labelText: 'Year of Graduation')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print("Attempting to sign up with email: ${_emailController.text.trim()}");
                final user = await signUp(_emailController.text.trim(), _passwordController.text.trim(), _firstNameController.text.trim(), _lastNameController.text.trim(), _yogController.text.trim());
                print("User signed up: ${user?.uid}");

                if (!context.mounted) return;

                if (user != null) {
                  // Check user role in Firestore
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
                  if (userDoc.exists && userDoc['type'] == 'admin') {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminHomePage()));
                  } else {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
                  }
                }
              },
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}