import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'VolunteerFormPage.dart';
import 'auth_helpers.dart';
import 'AdminUserDataView.dart';
import 'main.dart';

class AdminDeleteAccounts extends StatefulWidget {
  const AdminDeleteAccounts({super.key});


  @override
  State<AdminDeleteAccounts> createState() => _AdminDeleteAccountsState();
}

class _AdminDeleteAccountsState extends State<AdminDeleteAccounts> {
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
      return const Center(child: Text('No authenticated user.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Users').where('type', isEqualTo: 'user').snapshots(),
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
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Deactivate')),
                        DataColumn(label: Text('Activate')),
                      ],
                      rows: docs.map((doc) {
                        final data = doc.data()! as Map<String, dynamic>;
                        return DataRow(cells: [
                          DataCell(Text(data['firstName'] ?? '', textAlign: TextAlign.center)),
                          DataCell(Text(data['lastName'] ?? '', textAlign: TextAlign.center)),
                          DataCell(Text(data['email'] ?? '', textAlign: TextAlign.center)),
                          DataCell(Text(data['status'] ?? '', textAlign: TextAlign.center)),
                          DataCell(
                            TextButton(
                              onPressed: () async {
                                // Show confirmation dialog
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Deactivate User'),
                                    content: const Text('Are you sure you want to deactivate this user?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Deactivate'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                    // Delete all Hours sub-documents first
                                    final docs = await _firestore
                                        .collection('Users')
                                        .doc(doc.id)
                                        .get();
                                    if (docs.exists) {
                                      
                                      await _firestore.collection('Users').doc(doc.id).update({'status': 'Inactive'});

                                    // Delete the main user document

                                  }
                                }
                              },
                              child: const Text('Deactivate'),
                            ),
                          ),
                          DataCell(
                            TextButton(
                              onPressed: () async {
                                // Show confirmation dialog
                               
                                    // Delete all Hours sub-documents first
                                final docs = await _firestore
                                        .collection('Users')
                                        .doc(doc.id)
                                        .get();
                                    if (docs.exists) {
                                      
                                      await _firestore.collection('Users').doc(doc.id).update({'status': 'Active'});

                                    // Delete the main user document

                                  }
                                }
                              ,
                              child: const Text('Activate'),
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


