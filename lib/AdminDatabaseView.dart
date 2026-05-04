import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_helpers.dart';
import 'AdminUserDataView.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);


class AdminDatabaseView extends StatefulWidget {
  const AdminDatabaseView({super.key});


  @override
  State<AdminDatabaseView> createState() => _AdminDatabaseViewState();
}

class _AdminDatabaseViewState extends State<AdminDatabaseView> {
  final _firestore = FirebaseFirestore.instance;
  late final Future<List<String>> displayInfoFuture;

  @override
  void initState() {
    super.initState();
    displayInfoFuture = Future.wait([loadFirstName(), loadUserType()]);
  }

  

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No authenticated user.')),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('Users').where('type', isEqualTo: 'user').where('status', isEqualTo: 'Active').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No users found.'));

                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 1000,
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(kSecondaryColor.withOpacity(0.18)),
                                dataRowColor: MaterialStateProperty.all(Colors.white),
                                headingTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                                dataTextStyle: const TextStyle(color: Colors.black87),
                                columnSpacing: 30,
                                columns: const [
                                  DataColumn(label: Text('First Name')),
                                  DataColumn(label: Text('Last Name')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Type')),
                                  DataColumn(label: Text('Hours')),
                                  DataColumn(label: Text('High Needs Hours')),
                                  DataColumn(label: Text('View'))
                                ],
                                rows: docs.map((doc) {
                                  final data = doc.data()! as Map<String, dynamic>;
                                  return DataRow(cells: [
                                    DataCell(Text(data['firstName'] ?? '', textAlign: TextAlign.center)),
                                    DataCell(Text(data['lastName'] ?? '', textAlign: TextAlign.center)),
                                    DataCell(Text(data['email'] ?? '', textAlign: TextAlign.center)),
                                    DataCell(Text(data['type'] ?? '', textAlign: TextAlign.center)),
                                    DataCell(
                                      FutureBuilder<double>(
                                        future: fetchSpecificStudentHours(doc.id),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Text('Loading...', textAlign: TextAlign.center);
                                          } else if (snapshot.hasError) {
                                            return const Text('Error', textAlign: TextAlign.center);
                                          } else {
                                            return Text(snapshot.data?.toStringAsFixed(1) ?? '0', textAlign: TextAlign.center);
                                          }
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      FutureBuilder<double>(
                                        future: fetchSpecificStudentHighNeedsHours(doc.id),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Text('Loading...', textAlign: TextAlign.center);
                                          } else if (snapshot.hasError) {
                                            return const Text('Error', textAlign: TextAlign.center);
                                          } else {
                                            return Text(snapshot.data?.toStringAsFixed(1) ?? '0', textAlign: TextAlign.center);
                                          }
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return AdminUserDataView(uid: doc.id);
                                          }));
                                        },
                                        child: const Text('View'),
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


