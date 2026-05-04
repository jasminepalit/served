// Import necessary packages for Flutter, Firebase, and local files
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'VolunteerFormPage.dart';
import 'ActivityFormPage.dart';
import 'StudentActivityPage.dart';
import 'auth_helpers.dart';

// Define color constants for the app's theme
const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

// Home page widget displaying user's service hours and navigation options
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

// State class for HomePage
class _HomePageState extends State<HomePage> {
  // Firestore instance
  final _firestore = FirebaseFirestore.instance;
  // Current user
  final user = FirebaseAuth.instance.currentUser;
  // Future for loading first name
  late final Future<String> firstNameFuture;

  @override
  void initState() {
    super.initState();
    // Load first name asynchronously
    firstNameFuture = loadFirstName();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Check if user is authenticated
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No authenticated user.')),
      );
    }

    return Scaffold(
      // App bar with user's first name as title
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: firstNameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            return Text(snapshot.data ?? 'No One');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                // Section title for service hours
                Text('Service Hours', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                // Stream builder for user's hours data
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('Users')
                      .doc(user.uid)
                      .collection('Hours')
                      .snapshots(),
                  builder: (context, snapshot) {
                    double totalHours = 0;
                    // Calculate total hours from documents
                    if (snapshot.hasData) {
                      for (final doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final h = data['hours'];
                        if (h is num) totalHours += h.toDouble();
                      }
                    }
                    // Calculate progress towards 50 hours goal
                    final progress = (totalHours / 50).clamp(0.0, 1.0);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display total hours and remaining
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${totalHours.toStringAsFixed(1)} / 50 hours',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            Text(
                              totalHours >= 50 ? '🎉 Goal reached!' : '${(50 - totalHours).toStringAsFixed(1)} hrs to go',
                              style: TextStyle(
                                fontSize: 13,
                                color: totalHours >= 50 ? Colors.green : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 16,
                            backgroundColor: kAccentColor.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              totalHours >= 50 ? Colors.green : kPrimaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
            // Buttons for logging activity and hours
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
            // Button to view submitted activities
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const StudentActivityPage();
                }));
              },
              child: const Text('View Submitted Activities'),
            ),
            const SizedBox(height: 18),
            // Card containing the hours log table
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

                      // Scrollable data table for hours entries
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
