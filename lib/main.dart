/**
 * This is the main entry point of the Flutter application. It initializes Firebase, sets up authentication state listeners, and defines the main widget structure of the app. The app uses Firebase Authentication to manage user sessions and Firestore to store user data. Depending on the user's authentication state and type (admin or regular user), it navigates to different screens. The app also includes a function to fetch and calculate total volunteer hours from Firestore for all users.
 */
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

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);
/**
 * The main function initializes the Flutter application and sets up Firebase. It also listens to authentication state changes to determine if a user is signed in or not. Depending on the authentication state, it navigates to either the authenticated home screen or the login page. The authenticated home screen further checks the user's type and status to navigate to the appropriate screen (admin or regular user) or sign out if the user is inactive.
 */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Ideal time to initialize
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //...
  FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseAuth.instance
  .idTokenChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseAuth.instance
  .userChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user != null) {
      print(user.uid);
    }
  });

  runApp(const MyApp());
}

/**
 * The MyApp class is the root widget of the application. It builds a MaterialApp with a title and theme. The home of the app is determined by the authentication state of the user. If the user is authenticated, it navigates to the AuthenticatedHome widget; otherwise, it shows the LoginPage. The AuthenticatedHome widget further checks the user's type and status to navigate to either the AdminMainScreen or MainScreen, or signs out if the user is inactive.
 */

class MyApp extends StatelessWidget {
  const MyApp({super.key});
/**
 * The build method of the MyApp class returns a MaterialApp widget that sets up the main structure of the application. It defines the title and theme of the app, and uses a StreamBuilder to listen to authentication state changes from FirebaseAuth. Depending on whether the user is authenticated or not, it navigates to either the AuthenticatedHome widget or the LoginPage. The AuthenticatedHome widget further checks the user's type and status to determine which screen to display (admin or regular user) or to sign out if the user is inactive.
 */
  @override
  Widget build(BuildContext context) {
  
/**
 * The StreamBuilder listens to the authentication state changes from FirebaseAuth. It checks the connection state and displays a loading indicator while waiting for the authentication state to be determined. If the user is authenticated, it navigates to the AuthenticatedHome widget; otherwise, it shows the LoginPage. The AuthenticatedHome widget will further check the user's type and status to navigate to the appropriate screen or sign out if the user is inactive.
 */
  return MaterialApp(
    title: 'Firestore Volunteer App',
    theme: ThemeData(primarySwatch: Colors.deepOrange),
    home: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
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
/**
 * The AuthenticatedHome widget is responsible for determining the appropriate screen to display based on the user's type and status. It uses a FutureBuilder to load the user's type and status from Firestore. If the user's status is 'inactive', it signs out the user and shows a signing out message. If the user is an admin, it navigates to the AdminMainScreen; otherwise, it navigates to the MainScreen for regular users.
 */
class AuthenticatedHome extends StatelessWidget {
  const AuthenticatedHome({super.key});
/**
 * The _loadUserData function is an asynchronous function that retrieves the user's type and status from Firestore. It calls the loadUserType and loadUserStatus functions (presumably defined in auth_helpers.dart) to get the user's type (e.g., 'admin' or 'user') and status (e.g., 'active' or 'inactive'). The function returns a map containing the user's type and status, which is used by the FutureBuilder in the build method to determine which screen to display or whether to sign out the user.
 */
  Future<Map<String, String>> _loadUserData() async {
    final type = await loadUserType();
    final status = await loadUserStatus();
    return {'type': type, 'status': status};
  }
/**
 * The build method of the AuthenticatedHome widget uses a FutureBuilder to load the user's type and status from Firestore. It checks the connection state and displays a loading indicator while waiting for the data to be loaded. Once the data is available, it checks the user's status. If the status is 'inactive', it signs out the user and shows a signing out message. If the user is an admin, it navigates to the AdminMainScreen; otherwise, it navigates to the MainScreen for regular users.
 */
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _loadUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
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
/**
 * The _fetchStudentHours function retrieves and calculates the total volunteer hours from Firestore for all users. It queries the 'Users' collection to find all documents where the 'type' field is equal to 'user'. For each user, it then queries their 'Hours' subcollection to retrieve the hours data. The function sums up the hours, handling both numeric and string formats, and returns the total as a double.
 */
Future<double> _fetchStudentHours() async {
    double total = 0;
    final firestore = FirebaseFirestore.instance;
    final students = await firestore.collection('Users').where('type', isEqualTo: 'user').get();
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

  