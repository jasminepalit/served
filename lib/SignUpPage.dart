import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:served/footer_bar.dart';
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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _yogController = TextEditingController();
  bool _passwordsMatch = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _updatePasswordMatch() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    setState(() {
      _passwordsMatch = password == confirmPassword;
    });
  }

  bool get _hasPasswordInput =>
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty;

  bool get _isPasswordValid => isValidPassword(_passwordController.text);

  bool get _isEmailValid => isValidEmail(_emailController.text);

  bool get _canSubmit =>
      _hasPasswordInput && _passwordsMatch && _isPasswordValid && _isEmailValid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FooterBar(),
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _emailController.text.isNotEmpty && !_isEmailValid
                    ? 'Enter a valid email'
                    : null,
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                helperText:
                    'Must be 8+ characters, include 1 uppercase letter, 1 number, and 1 special character.',
                errorText: _hasPasswordInput && !_isPasswordValid
                    ? 'Password does not meet the requirements'
                    : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              onChanged: (_) => _updatePasswordMatch(),
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
              onChanged: (_) => _updatePasswordMatch(),
            ),
            if (_hasPasswordInput && !_passwordsMatch)
              const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  'Passwords do not match',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _yogController,
              decoration: const InputDecoration(
                labelText: 'Year of Graduation',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _canSubmit
                  ? () async {
                      print(
                        "Attempting to sign up with email: ${_emailController.text.trim()}",
                      );
                      if (!_isPasswordValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Password must be 8+ characters with 1 uppercase letter, 1 number, and 1 special character.',
                            ),
                          ),
                        );
                        return;
                      }

                      final user = await signUp(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        _firstNameController.text.trim(),
                        _lastNameController.text.trim(),
                        _yogController.text.trim(),
                      );
                      print("User signed up: ${user?.uid}");

                      if (!context.mounted) return;

                      if (user != null) {
                        // Check user role in Firestore
                        DocumentSnapshot userDoc = await FirebaseFirestore
                            .instance
                            .collection('Users')
                            .doc(user.uid)
                            .get();
                        if (userDoc.exists && userDoc['type'] == 'admin') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminHomePage(),
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainScreen(),
                            ),
                          );
                        }
                      }
                    }
                  : null,
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
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
