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
import 'ResetPassword.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Login'),
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
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _errorMessage = '';
                });
              },
            ),
            if (_errorMessage != null && _errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
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
              } else {
                setState(() {
                  _errorMessage = 'Incorrect password';
                });
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
                      const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResetPassword(),
                    ),
                  );
                
              },
              child: const Text('Forgot your password?'),
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

