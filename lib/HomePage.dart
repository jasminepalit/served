import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'MainScreen.dart';
import 'VolunteerFormPage.dart';
import 'main.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key, required this.title});
  final String title;
  final _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  final String firstName = loadFirstName();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(firstName),
      ),
      body: Center(
        child: Column(
        children:[
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
                  .doc(user!.uid)
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
