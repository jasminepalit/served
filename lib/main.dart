import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart';
import 'MainScreen.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

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


String loadUserType() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 'user';
  final docRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
  docRef.get().then((doc) {
    if (doc.exists) {
      print(doc['type']);
      return doc['type'];
    } else {
      return 'user';
    }
  }).catchError((e) {
    print("Error fetching user type: $e");
    return 'user';
  });
  return 'user'; // default while loading
}

Future<User?> signUp(String email, String password) async {
  print("Received sign up request for email: $email");
  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    print("User signed up: ${credential.user?.uid}");

    final user = credential.user;

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .set({
      'email': user.email,
      'createdAt': Timestamp.now(),
      'uid': user.uid,
      'type': 'user',
    });

    return user;
  } catch (e) {
    print("Sign up error: $e");
    return null;
  }
}

Future<User?> signIn(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    /*
    final user = credential.user;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .set({
      'type': 'user',
      
    });*/

    loadUserType();

    return credential.user;
  } catch (e) {
    print("Login error: $e");
    return null;
  }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  
    
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
          return const MainScreen(); // logged in
        } else {
          return const LoginPage(); // logged out
        }
      },
    ),
  );
}
}

