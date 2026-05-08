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

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
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
