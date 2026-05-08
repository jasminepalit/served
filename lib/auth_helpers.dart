import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Loads User Type from Firestore, defaults to 'user' if not found or on error. If uid is provided, it fetches for that uid; otherwise, it uses the current user's uid.
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

//Loads User Status from Firestore, defaults to 'active' if not found or on error. If uid is provided, it fetches for that uid; otherwise, it uses the current user's uid.
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

//Loads the user's first name, default to Jane
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

//Loads the user's last name, default to Doe
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

//Loads another user's first name based on their uid, default to Jane
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

//Loads another user's last name based on their uid, default to Doe
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

//Loads another user's full name based on their uid, default to Jane Doe
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

//Signs up a new user with email and password, and stores additional info in Firestore. Returns the User object on success, or null on failure.
Future<User?> signUp(String email, String password, String firstName, String lastName, String yearOfGraduation) async {
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
      'yearOfGraduation': yearOfGraduation,
      'status': 'Active',
    });

    return user;
  } catch (e) {
    print("Sign up error: $e");
    return null;
  }
}

//Signs in an existing user with email and password. Returns the User object on success, or null on failure.
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

// Signs out the current user.
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

// Fetches the total approved hours for a specific student based on their uid.
Future<double> fetchSpecificStudentHours(uid) async {
    double total = 0;
    final firestore = FirebaseFirestore.instance;
    final students = await firestore.collection('Users').where('type', isEqualTo: 'user').get();

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

// Fetches the total approved hours for high needs activities for a specific student based on their uid.
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

  // Collect unique organizations
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

  // Sum hours where place is in high needs organizations
  for (final hoursDoc in hoursSnapshot.docs) {
    final data = hoursDoc.data();
    final place = data['place'] as String?;
    final hoursValue = data['hours'];
    final status = data['status'] as String?;
    if (place != null && highNeedsOrganizations.contains(place) && status == 'approved') {
      if (hoursValue is num) {
        total += hoursValue.toDouble();
      } else if (hoursValue is String && status == 'approved') {
        total += double.tryParse(hoursValue) ?? 0;
      }
    }
  }
  return total;
}
