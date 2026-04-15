import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'VolunteerFormPage.dart';
import 'auth_helpers.dart';

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
      return const Center(child: Text('No authenticated user.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const VolunteerFormPage();
              }));
            },
            child: const Text('Next'),
          ),
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
                        DataColumn(label: Text('Type')),
                      ],
                      rows: docs.map((doc) {
                        final data = doc.data()! as Map<String, dynamic>;
                        return DataRow(cells: [
                          DataCell(Text(data['firstName'] ?? '')),
                          DataCell(Text(data['lastName'] ?? '')),
                          DataCell(Text(data['email'] ?? '')),
                          DataCell(Text(data['type'] ?? '')),
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
