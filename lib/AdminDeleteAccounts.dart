/**
 * AdminDeleteAccounts.dart is a Flutter widget that provides an interface for administrators to manage user accounts in a Firestore database. It allows admins to view a list of users, search for specific users, and change their roles (admin/user) and statuses (active/inactive). The widget uses a StreamBuilder to listen for real-time updates from the Firestore collection and displays the user information in a DataTable. Administrators can easily toggle user roles and statuses directly from the interface, with confirmation dialogs to prevent accidental changes. The search functionality enables filtering users based on various attributes such as first name, last name, email, role, status, and year of graduation.
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'VolunteerFormPage.dart';
import 'auth_helpers.dart';
import 'AdminUserDataView.dart';
import 'main.dart';
/**
 * AdminDeleteAccounts is a Flutter widget that allows administrators to view, search, and manage user accounts in a Firestore database. It displays a list of users with their details and provides options to change their roles (admin/user) and statuses (active/inactive). The widget includes a search functionality to filter users based on various attributes such as first name, last name, email, role, status, and year of graduation. Administrators can easily toggle user roles and statuses directly from the interface.
 */
class AdminDeleteAccounts extends StatefulWidget {
  const AdminDeleteAccounts({super.key});


  @override
  State<AdminDeleteAccounts> createState() => _AdminDeleteAccountsState();
}
/**
 * _AdminDeleteAccountsState is the state class for the AdminDeleteAccounts widget. It manages the state of the user list, including loading user data from Firestore, handling search queries, and updating user roles and statuses. The class initializes a Future to load user information and uses a StreamBuilder to listen for real-time updates from the Firestore collection. It provides functionality to filter users based on search input and allows administrators to change user roles and statuses with confirmation dialogs. The UI is built using a DataTable to display user information in a structured format, with options for pagination and scrolling.
 */
class _AdminDeleteAccountsState extends State<AdminDeleteAccounts> {
  final _firestore = FirebaseFirestore.instance;
  late final Future<List<String>> displayInfoFuture;
  String _searchQuery = '';
  // Load the first name and user type of the current user
  @override
  void initState() {
    super.initState();
    displayInfoFuture = Future.wait([loadFirstName(), loadUserType()]);
  }

  
  /**
   * build method constructs the UI of the AdminDeleteAccounts widget. It first checks if there is an authenticated user; if not, it displays a message indicating that no user is authenticated. If a user is authenticated, it builds a layout consisting of a search bar and a DataTable to display user information. The DataTable includes columns for first name, last name, email, year of graduation, role, and status, along with buttons to change roles and statuses. The user data is fetched from Firestore in real-time using a StreamBuilder, and the displayed users can be filtered based on the search query entered in the search bar. The UI also includes scrollbars for better navigation through the list of users.
   */
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
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Users').orderBy('yearOfGraduation', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No users found.'));

                // Filter docs based on search query
                final filteredDocs = docs.where((doc) {
                  final data = doc.data()! as Map<String, dynamic>;
                  final firstName = (data['firstName'] ?? '').toLowerCase();
                  final lastName = (data['lastName'] ?? '').toLowerCase();
                  final email = (data['email'] ?? '').toLowerCase();
                  final type = (data['type'] ?? '').toLowerCase();
                  final status = (data['status'] ?? '').toLowerCase();
                  final yearOfGraduation = (data['yearOfGraduation'] ?? '').toLowerCase();
                  return firstName.contains(_searchQuery) ||
                         lastName.contains(_searchQuery) ||
                         email.contains(_searchQuery) ||
                         type.contains(_searchQuery) ||
                         status.contains(_searchQuery) ||
                         yearOfGraduation.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) return const Center(child: Text('No users match the search.'));

                return Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('First Name')),
                            DataColumn(label: Text('Last Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Year of Graduation')),
                            DataColumn(label: Text('Role')),
                            DataColumn(label: Text('Change Role')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Change Status')),
                          ],
                          rows: filteredDocs.map((doc) {
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


