/**
 * AdminHomePage.dart is a Flutter widget that serves as the main dashboard for administrators in a student hours tracking application. It provides an overview of key statistics related to student hours and activities, such as total student hours, average hours per student, count of approved activities, count of pending activities, and total pending hours. The data is fetched from Firestore and displayed in a visually appealing manner using color-coded cards. Each card shows a specific statistic, and the UI is designed to be clean and modern, making it easy for administrators to quickly assess the status of student hours and activities.
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SignUpPage.dart';
import 'main.dart';
import 'LoginPage.dart';
import 'AdminActivityApproval.dart';
import 'auth_helpers.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);
/**
 * AdminHomePage is the main dashboard for administrators, providing an overview of key statistics related to student hours and activities. It fetches data from Firestore to display total student hours, average hours per student, count of approved activities, count of pending activities, and total pending hours. The UI is designed with a clean and modern aesthetic, using color-coded cards to differentiate between different types of statistics.
 */
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}
/**
 * _AdminHomePageState manages the state of the AdminHomePage, including fetching data from Firestore and building the UI. It contains methods to fetch total student hours, average hours per student, count of approved activities, count of pending activities, and total pending hours. The build method constructs the UI, displaying a welcome message and a series of cards that show the fetched statistics. Each card is styled with colors and borders to enhance visual appeal and readability.
 */
class _AdminHomePageState extends State<AdminHomePage> {
  /**
   * _fetchStudentHours retrieves the total number of approved hours logged by all students. It queries the 'Users' collection to find all documents where the 'type' field is 'user', then iterates through each student document to access their 'Hours' subcollection. For each hours document, it checks if the status is 'approved' and sums up the hours accordingly. The method returns the total approved hours as a double.
   */
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
        final status = data['status'] ?? 'pending';
        if (status == 'approved') {
          final hoursValue = data['hours'];
          if (hoursValue is num) {
            total += hoursValue.toDouble();
          } else if (hoursValue is String) {
            total += double.tryParse(hoursValue) ?? 0;
          }
        }
      }
    }
    return total;
  }
  /**
   * _fetchAverageHoursPerStudent calculates the average number of approved hours per student. It first retrieves all student documents from the 'Users' collection, then iterates through each student to access their 'Hours' subcollection. For each hours document, it checks if the status is 'approved' and sums up the hours. Finally, it divides the total approved hours by the number of students to get the average hours per student, which is returned as a double.
   */
  Future<double> _fetchAverageHoursPerStudent() async {
    double total = 0;
    final firestore = FirebaseFirestore.instance;
    final students = await firestore
        .collection('Users')
        .where('type', isEqualTo: 'user')
        .get();
    final studentCount = students.docs.length;
    if (studentCount == 0) return 0;
    for (final student in students.docs) {
      final hoursSnapshot = await firestore
          .collection('Users')
          .doc(student.id)
          .collection('Hours')
          .get();
      for (final hoursDoc in hoursSnapshot.docs) {
        final data = hoursDoc.data();
        final status = data['status'] ?? 'pending';
        if (status == 'approved') {
          final hoursValue = data['hours'];
          if (hoursValue is num) {
            total += hoursValue.toDouble();
          } else if (hoursValue is String) {
            total += double.tryParse(hoursValue) ?? 0;
          }
        }
      }
    }
    return total / studentCount;
  }
  /**
   * _fetchApprovedActivitiesCount counts the total number of approved activities across all students. It queries the 'Users' collection to find all student documents, then iterates through each student to access their 'Activities' subcollection. For each activity document, it checks if the status is 'approved' and increments the count accordingly. The method returns the total count of approved activities as an integer.
   */
  Future<int> _fetchApprovedActivitiesCount() async {
    int count = 0;
    final firestore = FirebaseFirestore.instance;
    final students = await firestore
        .collection('Users')
        .where('type', isEqualTo: 'user')
        .get();
    for (final student in students.docs) {
      final activitiesSnapshot = await firestore
          .collection('Users')
          .doc(student.id)
          .collection('Activities')
          .get();
      for (final activityDoc in activitiesSnapshot.docs) {
        final data = activityDoc.data();
        final status = data['status'] ?? 'pending';
        if (status == 'approved') {
          count++;
        }
      }
    }
    return count;
  }
  /**
   * _fetchPendingActivitiesCount counts the total number of pending activities across all students. It queries the 'Users' collection to find all student documents, then iterates through each student to access their 'Activities' subcollection. For each activity document, it checks if the status is 'pending' and increments the count accordingly. The method returns the total count of pending activities as an integer.
   */
  Future<int> _fetchPendingActivitiesCount() async {
    int count = 0;
    final firestore = FirebaseFirestore.instance;
    final students = await firestore
        .collection('Users')
        .where('type', isEqualTo: 'user')
        .get();
    for (final student in students.docs) {
      final activitiesSnapshot = await firestore
          .collection('Users')
          .doc(student.id)
          .collection('Activities')
          .get();
      for (final activityDoc in activitiesSnapshot.docs) {
        final data = activityDoc.data();
        final status = data['status'] ?? 'pending';
        if (status == 'pending') {
          count++;
        }
      }
    }
    return count;
  }
  /**
   * _fetchPendingHoursCount calculates the total number of pending hours across all students. It queries the 'Users' collection to find all student documents, then iterates through each student to access their 'Hours' subcollection. For each hours document, it checks if the status is 'pending' and sums up the hours accordingly. The method returns the total pending hours as a double.
   */
  Future<double> _fetchPendingHoursCount() async {
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
        final status = data['status'] ?? 'pending';
        if (status == 'pending') {
          final hoursValue = data['hours'];
          if (hoursValue is num) {
            total += hoursValue.toDouble();
          } else if (hoursValue is String) {
            total += double.tryParse(hoursValue) ?? 0;
          }
        }
      }
    }
    return total;
  }
  /**
   * _buildStatCardContent is a helper method that builds the content for each statistic card displayed on the dashboard. It takes a value and a label as parameters and returns a widget that displays the value in a large, bold font and the label in a smaller, semi-bold font below it. The content is centered and padded to ensure good spacing and readability within the card.
   */
  Widget _buildStatCardContent(String value, String label) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  /**
   * build constructs the UI for the AdminHomePage. It uses a Scaffold with a centered Column to display a welcome message and a series of statistic cards. The first card shows the total student hours, while the next four cards display average hours per student, count of approved activities, count of pending activities, and total pending hours. Each card uses a FutureBuilder to fetch data asynchronously and displays a loading indicator while waiting for the data. The cards are styled with different background colors and borders to enhance visual appeal and differentiate between the types of statistics being displayed.
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome Admin!',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<double>(
              future: _fetchStudentHours(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final totalHours = snapshot.data ?? 0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 18.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kPrimaryColor.withOpacity(0.5),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Student Hours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor,
                        ),
                      ),
                      Text(
                        totalHours.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                if (index == 0) {
                  return FutureBuilder<double>(
                    future: _fetchAverageHoursPerStudent(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: kAccentOrange,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.2,
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                      final averageHours = snapshot.data ?? 0;
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: kAccentOrange,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1.2),
                        ),
                        child: _buildStatCardContent(
                          averageHours.toStringAsFixed(1),
                          'Avg Hours\nPer Student',
                        ),
                      );
                    },
                  );
                } else if (index == 1) {
                  return FutureBuilder<int>(
                    future: _fetchApprovedActivitiesCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.2,
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                      final approvedActivities = snapshot.data ?? 0;
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1.2),
                        ),
                        child: _buildStatCardContent(
                          approvedActivities.toString(),
                          'Approved\nActivities',
                        ),
                      );
                    },
                  );
                } else if (index == 2) {
                  return FutureBuilder<int>(
                    future: _fetchPendingActivitiesCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: kSecondaryColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.2,
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                      final pendingActivities = snapshot.data ?? 0;
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: kSecondaryColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1.2),
                        ),
                        child: _buildStatCardContent(
                          pendingActivities.toString(),
                          'Pending\nActivities',
                        ),
                      );
                    },
                  );
                } else if (index == 3) {
                  return FutureBuilder<double>(
                    future: _fetchPendingHoursCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: kAccentColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.2,
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                      final pendingHours = snapshot.data ?? 0;
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: kAccentColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1.2),
                        ),
                        child: _buildStatCardContent(
                          pendingHours.toStringAsFixed(1),
                          'Pending\nHours',
                        ),
                      );
                    },
                  );
                } else {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: kAccentColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: kAccentColor.withOpacity(0.5),
                        width: 1.6,
                      ),
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
