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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Users').orderBy('yearOfGraduation', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No users found.'));

                return Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('First Name')),
                            DataColumn(label: Text('Last Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label:  Text('Year of Graduation')),
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
                          DataCell(Text(data['yearOfGraduation'] ?? '', textAlign: TextAlign.center)),
                          DataCell(Text((data['type']== 'admin') ? 'Admin' : 'User', textAlign: TextAlign.center)),
                          DataCell(
                            TextButton(
                              onPressed: () async {
                                // Show confirmation dialog
                            
                                    // Delete all Hours sub-documents first
                                if (data['type'] == 'user') {
                                final docs = await _firestore
                                        .collection('Users')
                                        .doc(doc.id)
                                        .get();
                                    if (docs.exists) {
                                      
                                      await _firestore.collection('Users').doc(doc.id).update({'type': 'admin'});
                                    }
                                } else {

                                    
                                      
                                      await _firestore.collection('Users').doc(doc.id).update({'type': 'user'});
                                    

                                  }
                                }
                              ,
                              child: Text(data['type'] == 'admin' ? 'Make User' : 'Make Admin'),
                            ),
                          ),
                          DataCell(Text(data['status'] ?? '', textAlign: TextAlign.center)),
                          DataCell(
                            TextButton(
                              onPressed: () async {
                                // Show confirmation dialog
                                if (data['status'] == 'Active') {

                                    // Delete all Hours sub-documents first
                                    final docs = await _firestore
                                        .collection('Users')
                                        .doc(doc.id)
                                        .get();
                                    if (docs.exists) {
                                      
                                      await _firestore.collection('Users').doc(doc.id).update({'status': 'Inactive'});

                                    // Delete the main user document
                                    }
                                } else {
                                  await _firestore.collection('Users').doc(doc.id).update({'status': 'Active'});
                                  
                                }
                              },
                              child:  Text(data['status'] == 'Active' ? 'Deactivate' : 'Activate'),
                            ),
                          ),



                        ]);
                      }).toList(),
                    ),
                  ),
                )));
              },
            ),
          ),
        ],
      ),
    );
  }
}


