// Import necessary packages for Flutter, Firebase, and other components
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'VolunteerFormPage.dart';
import 'auth_helpers.dart';
import 'AdminUserDataView.dart';
import 'main.dart';

// Admin delete accounts widget for managing user roles and status
class AdminDeleteAccounts extends StatefulWidget {
  const AdminDeleteAccounts({super.key});

  @override
  State<AdminDeleteAccounts> createState() => _AdminDeleteAccountsState();
}

// State class for AdminDeleteAccounts
class _AdminDeleteAccountsState extends State<AdminDeleteAccounts> {
  final _firestore = FirebaseFirestore.instance;
  late final Future<List<String>> displayInfoFuture;

  @override
  void initState() {
    super.initState();
    // Load admin's first name and user type
    displayInfoFuture = Future.wait([loadFirstName(), loadUserType()]);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('No authenticated user.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Stream of all users from Firestore
              stream: _firestore.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No users found.'));

                return Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('First Name')),
                        DataColumn(label: Text('Last Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Change Role')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Change Status')),
                      ],
                      rows: docs.map((doc) {
                        final data = doc.data()! as Map<String, dynamic>;
                        return DataRow(cells: [
                          DataCell(Text(data['firstName'] ?? '', textAlign: TextAlign.center)),
                          DataCell(Text(data['lastName'] ?? '', textAlign: TextAlign.center)),
                          DataCell(Text(data['email'] ?? '', textAlign: TextAlign.center)),
                          DataCell(Text(data['type'] ?? '', textAlign: TextAlign.center)),
                          DataCell(
                            TextButton(
                              // Toggle user role between admin and user
                              onPressed: () async {
                                if (data['type'] == 'user') {
                                  await _firestore.collection('Users').doc(doc.id).update({'type': 'admin'});
                                } else {
                                  await _firestore.collection('Users').doc(doc.id).update({'type': 'user'});
                                }
                              },
                              child: Text(data['type'] == 'admin' ? 'Make User' : 'Make Admin'),
                            ),
                          ),
                          DataCell(Text(data['status'] ?? '', textAlign: TextAlign.center)),
                          DataCell(
                            TextButton(
                              // Toggle user status between Active and Inactive
                              onPressed: () async {
                                if (data['status'] == 'Active') {
                                  await _firestore.collection('Users').doc(doc.id).update({'status': 'Inactive'});
                                } else {
                                  await _firestore.collection('Users').doc(doc.id).update({'status': 'Active'});
                                }
                              },
                              child: Text(data['status'] == 'Active' ? 'Deactivate' : 'Activate'),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


