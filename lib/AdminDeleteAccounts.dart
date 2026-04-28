import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_helpers.dart';
import 'AdminDatabaseView.dart';
import 'LoginPage.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Delete Accounts'),
        centerTitle: true,
        backgroundColor: const Color(0xFF93a1fd),
        leading: TextButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
              return LoginPage();
            }), (route) => false);
          },
          child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const AdminDatabaseView();
              }));
            },
            child: const Text('Users', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}


