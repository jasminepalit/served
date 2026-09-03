import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'VolunteerFormPage.dart';
import 'auth_helpers.dart';
import 'AdminUserDataView.dart';
import 'main.dart';
import 'AdminWipeAccounts.dart';

class AdminDeleteAccounts extends StatefulWidget {
  const AdminDeleteAccounts({super.key});

  @override
  State<AdminDeleteAccounts> createState() => _AdminDeleteAccountsState();
}

class _AdminDeleteAccountsState extends State<AdminDeleteAccounts> {
  final _firestore = FirebaseFirestore.instance;
  late final Future<List<String>> displayInfoFuture;
  String _searchQuery = '';

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
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminWipePanel()),
              );
            },
            child: const Text('Wipe Accounts by Year of Graduation'),
          ),
          const SizedBox(height: 12),
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
              stream: _firestore
                  .collection('Users')
                  .orderBy('yearOfGraduation', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return const Center(child: Text('No users found.'));

                // Filter docs based on search query
                final filteredDocs = docs.where((doc) {
                  final data = doc.data()! as Map<String, dynamic>;
                  final firstName = (data['firstName'] ?? '').toLowerCase();
                  final lastName = (data['lastName'] ?? '').toLowerCase();
                  final email = (data['email'] ?? '').toLowerCase();
                  final type = (data['type'] ?? '').toLowerCase();
                  final status = (data['status'] ?? '').toLowerCase();
                  final yearOfGraduation = (data['yearOfGraduation'] ?? '')
                      .toLowerCase();
                  return firstName.contains(_searchQuery) ||
                      lastName.contains(_searchQuery) ||
                      email.contains(_searchQuery) ||
                      type.contains(_searchQuery) ||
                      status.contains(_searchQuery) ||
                      yearOfGraduation.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty)
                  return const Center(
                    child: Text('No users match the search.'),
                  );

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
                            DataColumn(label: Text('Delete Account')),
                          ],
                          rows: filteredDocs.map((doc) {
                            final data = doc.data()! as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    data['firstName'] ?? '',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['lastName'] ?? '',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['email'] ?? '',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['yearOfGraduation'] ?? '',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    (data['type'] == 'admin')
                                        ? 'Admin'
                                        : 'User',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
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
                                          await _firestore
                                              .collection('Users')
                                              .doc(doc.id)
                                              .update({'type': 'admin'});
                                        }
                                      } else {
                                        await _firestore
                                            .collection('Users')
                                            .doc(doc.id)
                                            .update({'type': 'user'});
                                      }
                                    },
                                    child: Text(
                                      data['type'] == 'admin'
                                          ? 'Make User'
                                          : 'Make Admin',
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['status'] ?? '',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
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
                                          await _firestore
                                              .collection('Users')
                                              .doc(doc.id)
                                              .update({'status': 'Inactive'});

                                          // Delete the main user document
                                        }
                                      } else {
                                        await _firestore
                                            .collection('Users')
                                            .doc(doc.id)
                                            .update({'status': 'Active'});
                                      }
                                    },
                                    child: Text(
                                      data['status'] == 'Active'
                                          ? 'Deactivate'
                                          : 'Activate',
                                    ),
                                  ),
                                ),
                                DataCell(
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      final currentUser = FirebaseAuth.instance.currentUser;
                                      if (currentUser != null && currentUser.uid == doc.id) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('You cannot delete your own account from here.'),
                                          ),
                                        );
                                        return;
                                      }

                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: Text('Permanently delete account for ${data['firstName'] ?? ''} ${data['lastName'] ?? ''}? This will remove their Auth account and Firestore data.'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed != true) return;

                                      try {
                                        // Call the existing wipe-by-YOG callable by passing the user's UID via a new callable that deletes a single user.
                                        final FirebaseFunctions functions = FirebaseFunctions.instanceFor(region: 'us-east1');
                                        final HttpsCallable callable = functions.httpsCallable('delete_user_callable');
                                        final HttpsCallableResult result = await callable.call({'uid': doc.id});
                                        final resData = result.data as Map?;
                                        final message = resData != null ? (resData['message'] ?? 'User deleted.') : 'User deleted.';
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(message), backgroundColor: Colors.green),
                                        );
                                      } on FirebaseFunctionsException catch (e) {
                                        final details = e.details;
                                        final messageParts = <String>[e.message ?? 'Cloud function error', if (details != null) details.toString()];
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(messageParts.join(' - ')), backgroundColor: Colors.red),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error deleting user: $e'), backgroundColor: Colors.red),
                                        );
                                      }
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
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
    );
  }
}