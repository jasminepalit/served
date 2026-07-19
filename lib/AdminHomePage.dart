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
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
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
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    
    // Responsive font size
    final headingFontSize = isSmallScreen ? 36.0 : isMediumScreen ? 48.0 : 64.0;
    
    // Available width after Column padding (16px on each side)
    final availableWidth = screenWidth - 32.0;
    
    final cardWidth = isSmallScreen
        ? (availableWidth - 12) / 2  // 2 columns on small screens, 12px gap
        : isMediumScreen
            ? (availableWidth - 16) / 2  // 2 columns on medium screens, 16px gap
            : (availableWidth - 48) / 4;  // 4 columns on large screens, 48px total gaps (3 gaps × 16px)
    final cardHeight = cardWidth;
    
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: screenWidth - 32),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Welcome Admin!',
                      style: TextStyle(
                        fontSize: headingFontSize,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                    return SizedBox(
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0.0),
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
                        child: isSmallScreen
                            ? Column(
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: screenWidth - 64),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: const Text(
                                        'Total Student Hours',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: kPrimaryColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    totalHours.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ],
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 300),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: const Text(
                                          'Total Student Hours',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
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
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: isSmallScreen ? 12 : 16,
                  runSpacing: isSmallScreen ? 12 : 16,
                  alignment: WrapAlignment.start,
                  children: List.generate(4, (index) {
                    Color cardColor;
                    String label;
                    Future<dynamic> future;

                    if (index == 0) {
                      cardColor = kAccentOrange;
                      label = 'Avg Hours\nPer Student';
                      future = _fetchAverageHoursPerStudent();
                    } else if (index == 1) {
                      cardColor = kPrimaryColor;
                      label = 'Approved\nActivities';
                      future = _fetchApprovedActivitiesCount();
                    } else if (index == 2) {
                      cardColor = kSecondaryColor;
                      label = 'Pending\nActivities';
                      future = _fetchPendingActivitiesCount();
                    } else {
                      cardColor = kAccentColor;
                      label = 'Pending\nHours';
                      future = _fetchPendingHoursCount();
                    }

                    return FutureBuilder<dynamic>(
                      future: future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            width: cardWidth,
                            height: cardHeight,
                            decoration: BoxDecoration(
                              color: cardColor,
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

                        final value = snapshot.data ?? 0;
                        String displayValue;
                        if (value is double) {
                          displayValue = value.toStringAsFixed(1);
                        } else {
                          displayValue = value.toString();
                        }

                        return Container(
                          width: cardWidth,
                          height: cardHeight,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24, width: 1.2),
                          ),
                          child: _buildStatCardContent(displayValue, label),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}