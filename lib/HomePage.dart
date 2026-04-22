import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'VolunteerFormPage.dart';
import 'ActivityFormPage.dart';
import 'StudentActivityPage.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class HomePage extends StatelessWidget {
  HomePage({super.key, required this.title});
  final String title;
  final _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Service Hours', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const ActivityFormPage();
                      }));
                    },
                    child: const Text('Log Activity'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const VolunteerFormPage();
                      }));
                    },
                    child: const Text('Log Hours'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const StudentActivityPage();
                }));
              },
              child: const Text('View Submitted Activities'),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Card(
                clipBehavior: Clip.hardEdge,
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                            headingRowColor: WidgetStateProperty.all(kSecondaryColor.withValues(alpha: 0.18)),
                            dataRowColor: WidgetStateProperty.all(Colors.white),
                            dividerThickness: 1,
                            headingTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                            dataTextStyle: const TextStyle(color: Colors.black87),
                            columnSpacing: 32,
                            columns: const [
                              DataColumn(label: Text('Place')),
                              DataColumn(label: Text('Hours')),
                              DataColumn(label: Text('Date')),
                            ],
                            rows: docs.map((doc) {
                              final data = doc.data()! as Map<String, dynamic>;
                              final timestamp = data['date'] as Timestamp?;
                              final dateStr = timestamp != null ? timestamp.toDate().toLocal().toString().split(' ')[0] : '';
                              return DataRow(cells: [
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
