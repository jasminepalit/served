import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> loadUserType({String? uid}) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final targetUid = uid ?? currentUser?.uid;
  print("in loadUserType for uid=$targetUid");
  if (targetUid == null) return 'user';
  final docRef = FirebaseFirestore.instance.collection('Users').doc(targetUid);
  try {
    final doc = await docRef.get();
    if (doc.exists) {
      return (doc['type'] as String?)?.trim().toLowerCase() ?? 'user';
    }
  } catch (e) {
    print("Error fetching user type: $e");
  }
  return 'user';
}

Future<String> loadUserStatus({String? uid}) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final targetUid = uid ?? currentUser?.uid;
  print("in loadUserStatus for uid=$targetUid");
  if (targetUid == null) return 'active';
  final docRef = FirebaseFirestore.instance.collection('Users').doc(targetUid);
  try {
    final doc = await docRef.get();
    if (doc.exists) {
      return (doc['status'] as String?)?.trim().toLowerCase() ?? 'active';
    }
  } catch (e) {
    print("Error fetching user status: $e");
  }
  return 'active';
}

bool hasMinLength(String password) => password.length >= 8;

bool hasUppercase(String password) => RegExp(r'[A-Z]').hasMatch(password);

bool hasNumber(String password) => RegExp(r'\d').hasMatch(password);

bool hasSpecialCharacter(String password) => RegExp(r'[^A-Za-z0-9]').hasMatch(password);

bool isValidPassword(String password) {
  if (!hasMinLength(password)) return false;
  if (!hasUppercase(password)) return false;
  if (!hasNumber(password)) return false;
  if (!hasSpecialCharacter(password)) return false;
  return true;
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

Future<String> loadFirstNameSpecific(uid) async {
  final docRef = FirebaseFirestore.instance.collection('Users').doc(uid);
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

Future<String> loadLastNameSpecific(uid) async {
  final docRef = FirebaseFirestore.instance.collection('Users').doc(uid);
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

Future<String> loadNameSpecific(uid) async {
  final docRef = FirebaseFirestore.instance.collection('Users').doc(uid);
  try {
    final doc = await docRef.get();
    if (doc.exists) {
      String f = doc['firstName'] as String? ?? 'Jane';
      String l = doc['lastName'] as String? ?? 'Doe';
      return '$f $l';
    }
  } catch (e) {
    print("Error fetching user last name: $e");
  }
  return 'Doe';
}

Future<User?> signUp(
  String email,
  String password,
  String firstName,
  String lastName,
  String yearOfGraduation,
) async {
  print("Received sign up request for email: $email");
  if (!isValidEmail(email)) {
    print('Email address is not valid.');
    return null;
  }

  if (!isValidPassword(password)) {
    print('Password does not meet the required strength requirements.');
    return null;
  }

  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    print("User signed up: ${credential.user?.uid}");

    final user = credential.user;

    await FirebaseFirestore.instance.collection('Users').doc(user!.uid).set({
      'email': user.email,
      'createdAt': Timestamp.now(),
      'uid': user.uid,
      'type': 'user',
      'firstName': firstName,
      'lastName': lastName,
      'yearOfGraduation': yearOfGraduation,
      'status': 'Active',
    });

    return user;
  } catch (e) {
    print("Sign up error: $e");
    return null;
  }
}

Future<User?> signIn(String email, String password) async {
  if (!isValidEmail(email)) {
    print('Email address is not valid.');
    return null;
  }

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

Future<double> fetchSpecificStudentHours(uid) async {
  double total = 0;
  final firestore = FirebaseFirestore.instance;
  final students = await firestore
      .collection('Users')
      .where('type', isEqualTo: 'user')
      .get();

  final hoursSnapshot = await firestore
      .collection('Users')
      .doc(uid)
      .collection('Hours')
      .get();
  for (final hoursDoc in hoursSnapshot.docs) {
    final data = hoursDoc.data();
    final hoursValue = data['hours'];
    final status = data['status'] as String?;
    if (hoursValue is num && status == 'approved') {
      total += hoursValue.toDouble();
    } else if (hoursValue is String && status == 'approved') {
      total += double.tryParse(hoursValue) ?? 0;
    }
  }
  return total;
}

Future<double> fetchSpecificStudentHighNeedsHours(uid) async {
  double total = 0;
  final firestore = FirebaseFirestore.instance;

  // Get all approved high needs activities for the user
  final activitiesSnapshot = await firestore
      .collection('Users')
      .doc(uid)
      .collection('Activities')
      .where('status', isEqualTo: 'approved')
      .where('isHighNeeds', isEqualTo: true)
      .get();

  // Collect unique organizations from approved high-needs activities.
  final highNeedsOrganizations = activitiesSnapshot.docs
      .map((doc) => doc.data()['organization'] as String?)
      .where((org) => org != null)
      .toSet();

  // Get all hours for the user
  final hoursSnapshot = await firestore
      .collection('Users')
      .doc(uid)
      .collection('Hours')
      .where('status', isEqualTo: 'approved')
      .get();

  // Sum hours where the document is flagged as high needs or the place
  // matches a high-needs organization from approved activities.
  for (final hoursDoc in hoursSnapshot.docs) {
    final data = hoursDoc.data();
    final place = data['place'] as String?;
    final hoursValue = data['hours'];
    final status = data['status'] as String?;
    final isHighNeeds = data['isHighNeeds'] == true;
    final matchesHighNeedsOrganization =
        place != null && highNeedsOrganizations.contains(place);

    if (status == 'approved' && (isHighNeeds || matchesHighNeedsOrganization)) {
      if (hoursValue is num) {
        total += hoursValue.toDouble();
      } else if (hoursValue is String) {
        total += double.tryParse(hoursValue) ?? 0;
      }
    }
  }
  return total;
}

Future<void> resetUserPassword(String email) async {
  if (!isValidEmail(email)) {
    print('Email address is not valid.');
    return;
  }

  try {
    // Call the Firebase method to send the reset link
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    print("Password reset email sent successfully to $email.");
  } on FirebaseAuthException catch (e) {
    // Handle specific Firebase Auth errors
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'invalid-email') {
      print('The email address is badly formatted.');
    } else {
      print('Error: ${e.message}');
    }
  } catch (e) {
    print('An unexpected error occurred: $e');
  }
}
