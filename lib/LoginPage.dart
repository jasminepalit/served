/**
 * LoginPage.dart is the login page of the app. It allows users to log in with their email and password. It also has a button to navigate to the sign up page. If the user is an admin, they will be navigated to the admin main screen. If the user is inactive, they will be signed out and navigated back to the login page.
 */
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

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);
/**
 * LoginPage is a stateful widget that represents the login page of the app. It has two text fields for email and password, and two buttons for login and sign up. The login button calls the signIn function from auth_helpers.dart and checks the user's status and type to navigate to the appropriate screen. The sign up button navigates to the SignUpPage.
 */
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
/**
 * createState creates the state of the LoginPage widget. It returns an instance of _LoginPageState.
 */
  @override
  State<LoginPage> createState() => _LoginPageState();
}
/**
 * _LoginPageState is the state of the LoginPage widget. It has two text editing controllers for the email and password fields. The build method returns a Scaffold with an AppBar and a body that contains a Card with the login form. The login button calls the signIn function and checks the user's status and type to navigate to the appropriate screen. The sign up button navigates to the SignUpPage.
 */
class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
/**
 * build builds the widget tree for the LoginPage. It returns a Scaffold with an AppBar and a body that contains a Card with the login form. The login button calls the signIn function and checks the user's status and type to navigate to the appropriate screen. The sign up button navigates to the SignUpPage.
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
            onPressed: () async {
              final user = await signIn(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              );
              if (!context.mounted) return;

              if (user != null) {
                      DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .get();

            if (!context.mounted) return;

            if (userDoc.exists && userDoc['status'] == 'Inactive') {
              signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }

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
            ElevatedButton(
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

