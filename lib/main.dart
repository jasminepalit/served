// Import necessary packages for Flutter, Firebase, and local files
import 'package:flutter/material.dart';
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

// Define color constants for the app's theme
const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

// Main entry point of the Flutter application
void main() async {
  // Ensure Flutter widgets are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Optional: Uncomment to use Firebase Auth emulator for testing
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //...
  // Listen to authentication state changes
  FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  // Listen to ID token changes
  FirebaseAuth.instance
  .idTokenChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  // Listen to user changes
  FirebaseAuth.instance
  .userChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  // Listen to auth state changes and print user ID if signed in
  FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user != null) {
      print(user.uid);
    }
  });

  // Run the app
  runApp(const MyApp());
}



// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Return MaterialApp with theme and home widget
    return MaterialApp(
      title: 'Firestore Volunteer App',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while checking auth state
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            // User is authenticated, show authenticated home
            return const AuthenticatedHome();
          } else {
            // User is not authenticated, show login page
            return const LoginPage();
          }
        },
      ),
    );
  }
}


// Widget for authenticated users, determines which screen to show based on user type and status
class AuthenticatedHome extends StatelessWidget {
  const AuthenticatedHome({super.key});

  // Load user type and status from Firestore
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
          // Show loading while fetching user data
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data ?? {'type': 'user', 'status': 'active'};
        final type = data['type']!;
        final status = data['status']!;

        if (status == 'inactive') {
          // Sign out inactive users
          FirebaseAuth.instance.signOut();
          // Show signing out message
          return const Scaffold(
            body: Center(child: Text('Signing out...')),
          );
        }

        if (type == 'admin') {
          // Show admin screen for admin users
          return const AdminMainScreen();
        }
        // Show main screen for regular users
        return const MainScreen();
      },
    );
  }
}

// Function to fetch total student hours from Firestore
Future<double> _fetchStudentHours() async {
  double total = 0;
  final firestore = FirebaseFirestore.instance;
  // Get all users with type 'user'
  final students = await firestore.collection('Users').where('type', isEqualTo: 'user').get();
  for (final student in students.docs) {
    // Get hours subcollection for each student
    final hoursSnapshot = await firestore
        .collection('Users')
        .doc(student.id)
        .collection('Hours')
        .get();
    for (final hoursDoc in hoursSnapshot.docs) {
      final data = hoursDoc.data();
      final hoursValue = data['hours'];
      // Add hours to total, handling both num and String types
      if (hoursValue is num) {
        total += hoursValue.toDouble();
      } else if (hoursValue is String) {
        total += double.tryParse(hoursValue) ?? 0;
      }
    }
  }
  return total;
}

  