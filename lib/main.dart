import 'package:flutter/material.dart';
import 'package:served/footer_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_helpers.dart';
import 'LoginPage.dart';
import 'AdminMainScreen.dart';
import 'HomePage.dart';
import 'VolunteerFormPage.dart';
import 'ActivityFormPage.dart';
import 'SignUpPage.dart';
import 'MainScreen.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ideal time to initialize
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //...
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseAuth.instance.idTokenChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseAuth.instance.userChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      print(user.uid);
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servd',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              bottomNavigationBar: FooterBar(),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const AuthenticatedHome();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}

class AuthenticatedHome extends StatelessWidget {
  const AuthenticatedHome({super.key});

  Future<Map<String, String>> _loadUserData() async {
    final type = await loadUserType();
    final status = await loadUserStatus();
    return {'type': type, 'status': status};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _loadUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            bottomNavigationBar: FooterBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data ?? {'type': 'user', 'status': 'active'};
        final type = data['type']!;
        final status = data['status']!;

        if (status == 'inactive') {
          // Sign out the user
          FirebaseAuth.instance.signOut();
          // Return a loading screen or message while signing out
          return const Scaffold(
            bottomNavigationBar: FooterBar(),
            body: Center(child: Text('Signing out...')),
          );
        }

        if (type == 'admin') {
          return const AdminMainScreen();
        }
        return const MainScreen();
      },
    );
  }
}

Future<double> _fetchStudentHours() async {
  double total = 0;
  final firestore = FirebaseFirestore.instance;
  final students = await firestore
      .collection('Users')
      .where('type', isEqualTo: 'user')
      .get();
  for (final student in students.docs) {
    final hoursSnapshot = await firestore
        .collection('Users')
        .doc(student.id)
        .collection('Hours')
        .get();
    for (final hoursDoc in hoursSnapshot.docs) {
      final data = hoursDoc.data();
      final hoursValue = data['hours'];
      if (hoursValue is num) {
        total += hoursValue.toDouble();
      } else if (hoursValue is String) {
        total += double.tryParse(hoursValue) ?? 0;
      }
    }
  }
  return total;
}