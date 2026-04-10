import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> loadUserType() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 'user';
  final docRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
  try {
    final doc = await docRef.get();
    if (doc.exists) {
      return doc['type'] as String? ?? 'user';
    }
  } catch (e) {
    print("Error fetching user type: $e");
  }
  return 'user';
}

Future<String> loadFirstName() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 'Jane';
  final docRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
  try {
    final doc = await docRef.get();
    if (doc.exists) {
      return doc['firstName'] as String? ?? 'Jane';
    }
  } catch (e) {
    print("Error fetching user first name: $e");
  }
  return 'Jane';
}

Future<String> loadLastName() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 'Doe';
  final docRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
  try {
    final doc = await docRef.get();
    if (doc.exists) {
      return doc['lastName'] as String? ?? 'Doe';
    }
  } catch (e) {
    print("Error fetching user last name: $e");
  }
  return 'Doe';
}

Future<User?> signUp(String email, String password, String firstName, String lastName) async {
  print("Received sign up request for email: $email");
  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    print("User signed up: ${credential.user?.uid}");

    final user = credential.user;

    await FirebaseFirestore.instance.collection('Users').doc(user!.uid).set({
      'email': user.email,
      'createdAt': Timestamp.now(),
      'uid': user.uid,
      'type': 'user',
      'firstName': firstName,
      'lastName': lastName,
    });

    return user;
  } catch (e) {
    print("Sign up error: $e");
    return null;
  }
}

Future<User?> signIn(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  } catch (e) {
    print("Login error: $e");
    return null;
  }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}
