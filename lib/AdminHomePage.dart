// Import necessary packages for Flutter, Firebase, and local files
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SignUpPage.dart';
import 'main.dart';
import 'LoginPage.dart';
import 'AdminActivityApproval.dart';

// Define color constants for the app's theme
const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

// Admin home page widget displaying welcome and total student hours
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

// State class for AdminHomePage
class _AdminHomePageState extends State<AdminHomePage> {
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
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Welcome message
            const Text(
              'Welcome Admin!',
              style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 24, 126)),
            ),
            const SizedBox(height: 20),
            // Future builder for total student hours
            FutureBuilder<double>(
              future: _fetchStudentHours(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator
                  return const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final totalHours = snapshot.data ?? 0;
                // Display total hours in a card
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF93a1fd),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Student Hours',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      Text(
                        totalHours.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Row of placeholder containers (possibly for future features)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) => Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF93a1fd),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}