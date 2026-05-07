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
    final students = await firestore.collection('Users').where('type', isEqualTo: 'user').get();
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
    final students = await firestore.collection('Users').where('type', isEqualTo: 'user').get();
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
    final students = await firestore.collection('Users').where('type', isEqualTo: 'user').get();
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
    final students = await firestore.collection('Users').where('type', isEqualTo: 'user').get();
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
    final students = await firestore.collection('Users').where('type', isEqualTo: 'user').get();
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
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome Admin!',
              style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 24, 126)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) {
                  if (index == 0) {
                    return FutureBuilder<double>(
                      future: _fetchAverageHoursPerStudent(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF93a1fd),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                          );
                        }
                        final averageHours = snapshot.data ?? 0;
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF93a1fd),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                averageHours.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const Text(
                                'Avg Hours\nPer Student',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
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
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF93a1fd),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                          );
                        }
                        final approvedActivities = snapshot.data ?? 0;
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF93a1fd),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                approvedActivities.toString(),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const Text(
                                'Approved\nActivities',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
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
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF93a1fd),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                          );
                        }
                        final pendingActivities = snapshot.data ?? 0;
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF93a1fd),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                pendingActivities.toString(),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const Text(
                                'Pending\nActivities',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
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
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF93a1fd),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                          );
                        }
                        final pendingHours = snapshot.data ?? 0;
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF93a1fd),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                pendingHours.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const Text(
                                'Pending\nHours',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF93a1fd),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}