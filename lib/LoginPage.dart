import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'MainScreen.dart';
import 'SignUpPage.dart';
import 'auth_helpers.dart';
import 'AdminDatabaseView.dart';
import 'AdminMainScreen.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                final userType = await loadUserType(uid: user.uid);
                print("Logged in as $userType for uid=${user.uid}");
                if (userType == 'admin') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminMainScreen(),
                    ),
                  );
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainScreen(),
                  ),
                );
              }
            },
            child: const Text('Login'),
          ),
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
    );
  }
}

