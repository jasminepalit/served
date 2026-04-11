import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart';
import 'HomePage.dart';
import 'VolunteerFormPage.dart';
import 'ActivityFormPage.dart';
import 'main.dart';
import 'MainScreen.dart';
import 'AdminHomePage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print("Attempting to sign up with email: ${_emailController.text.trim()}");
                final user = await signUp(_emailController.text.trim(), _passwordController.text.trim());
                print("User signed up: ${user?.uid}");

                if (!context.mounted) return;

                if (user != null) {
                  // Check user role in Firestore
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
                  if (userDoc.exists && userDoc['type'] == 'admin') {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Adminhomepage()));
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