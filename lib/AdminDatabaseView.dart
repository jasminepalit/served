/**
 * AdminDatabaseView is a StatefulWidget that displays a searchable and sortable table of all users in the Firestore database. It allows admins to view user details, including first name, last name, email, year of graduation, user type, total hours, and high needs hours. The table supports real-time updates and includes a search bar for filtering users based on their information. Each user row has a "View" button that navigates to a detailed view of the user's data.
 */
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

/**
 * AdminDatabaseView is a StatefulWidget that displays a searchable and sortable table of all users in the Firestore database. It allows admins to view user details, including first name, last name, email, year of graduation, user type, total hours, and high needs hours. The table supports real-time updates and includes a search bar for filtering users based on their information. Each user row has a "View" button that navigates to a detailed view of the user's data.
 */
class AdminDatabaseView extends StatefulWidget {
  const AdminDatabaseView({super.key});


  @override
  State<AdminDatabaseView> createState() => _AdminDatabaseViewState();
}
/**
 * _AdminDatabaseViewState is the state class for AdminDatabaseView. It manages the state of the user data table, including fetching user information from Firestore, handling search queries, and updating the UI in real-time as data changes. The state class initializes
 */
class _AdminDatabaseViewState extends State<AdminDatabaseView> {
  final _firestore = FirebaseFirestore.instance;
  late final Future<List<String>> displayInfoFuture;
  String _searchQuery = '';
  // Fetches the first name of the currently authenticated user from Firestore.
  @override
  void initState() {
    super.initState();
    displayInfoFuture = Future.wait([loadFirstName(), loadUserType()]);
  }

  

  /**
   * build method builds the UI for the AdminDatabaseView. It displays a search bar and a DataTable that lists all users in the Firestore database. The DataTable includes columns for first name, last name, email, year of graduation, user type, total hours, and high needs hours. The table supports real-time updates and filtering based on the search query. Each user row has a "View" button that navigates to a detailed view of the user's data.
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
                  final yearOfGraduation = (data['yearOfGraduation'] ?? '').toLowerCase();
                  return firstName.contains(_searchQuery) ||
                         lastName.contains(_searchQuery) ||
                         email.contains(_searchQuery) ||
                         type.contains(_searchQuery) || yearOfGraduation.contains(_searchQuery);
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
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Hours')),
                            DataColumn(label: Text('High Needs Hours')),
                            DataColumn(label: Text('View')),
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



                          )]);
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


