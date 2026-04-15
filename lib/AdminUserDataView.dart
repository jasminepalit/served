import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'VolunteerFormPage.dart';
import 'auth_helpers.dart';

class AdminUserDataView extends StatefulWidget {
  const AdminUserDataView({super.key, required this.uid});
  final String uid;

  @override
  State<AdminUserDataView> createState() => _AdminUserDataViewState();
}

class _AdminUserDataViewState extends State<AdminUserDataView> {
  final _firestore = FirebaseFirestore.instance;
  late final Future<String> firstNameFuture;
  late final Future<String> lastNameFuture;
  late final Future<String> nameFuture;

  @override
  void initState() {
    super.initState();
    firstNameFuture = loadFirstNameSpecific(widget.uid);
    lastNameFuture = loadLastNameSpecific(widget.uid);
    nameFuture = Future.wait([firstNameFuture, lastNameFuture]).then((values) => '${values[0]} ${values[1]}');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = FutureBuilder<String>(
      future: nameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }
        return Text(snapshot.data ?? 'No One');
      },
    );

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No authenticated user.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: nameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            return Text(snapshot.data ?? 'No One');
          },
        ),
      ),
      body: Center(
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
                stream: _firestore
                    .collection('Users')
                    .doc(widget.uid)
                    .collection('Hours')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No entries yet.'));

                  return Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Place')),
                          DataColumn(label: Text('Hours')),
                          DataColumn(label: Text('Date')),
                        ],
                        rows: docs.map((doc) {
                          final data = doc.data()! as Map<String, dynamic>;
                          final timestamp = data['date'] as Timestamp?;
                          final dateStr = timestamp != null ? timestamp.toDate().toLocal().toString().split(' ')[0] : '';
                          return DataRow(cells: [
                            DataCell(Text(data['name'] ?? '')),
                            DataCell(Text(data['place'] ?? '')),
                            DataCell(Text(data['hours']?.toString() ?? '')),
                            DataCell(Text(dateStr)),
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
      ),
    );
  }
}
