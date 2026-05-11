/**
 * HomePage.dart is the main screen of the app where students can view their service hours, log new activities, and see the status of their submissions. It connects to Firestore to fetch and display the user's service hour entries in a table format, showing the place, hours, date, and approval status. The page also includes a progress bar to visualize how close the student is to reaching the 50-hour goal, with a special highlight for high-needs hours.
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'VolunteerFormPage.dart';
import 'ActivityFormPage.dart';
import 'StudentActivityPage.dart';
import 'auth_helpers.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

/**
 * HomePage is a StatefulWidget that displays the main dashboard for students. It shows their total service hours, allows them to log new activities, and view the status of their submissions. The page uses Firestore to fetch the user's service hour entries and displays them in a DataTable, along with a progress bar to track their progress towards the 50-hour goal.
 */
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}
/**
 * _HomePageState manages the state of the HomePage widget. It initializes a connection to Firestore and retrieves the current user's information. The state includes a Future to load the user's first name for display in the app bar, and it builds the UI to show the service hours, log activity buttons, and a table of submitted hours with their statuses. The build method also handles the case where there is no authenticated user.
 */
class _HomePageState extends State<HomePage> {
  final _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  late final Future<String> firstNameFuture;
  String statusName = 'Loading...';
/**
 * initState initializes the state of the HomePage. It calls the loadFirstName function to fetch the user's first name from Firestore and stores it in a Future. This Future is then used in a FutureBuilder to display the user's name in the app bar once it is loaded.
 */
  @override
  void initState() {
    super.initState();
    firstNameFuture = loadFirstName();
  }
/** 
  * build constructs the UI of the HomePage. It first checks if there is an authenticated user; if not, it displays a message indicating that no user is authenticated. If a user is present, it builds a Scaffold with an AppBar that shows the user's first name (loaded asynchronously). The body of the Scaffold includes a section for service hours with a progress bar, buttons to log new activities and hours, and a DataTable that lists all submitted service hour entries along with their place, hours, date, and approval status. The DataTable updates in real-time using a StreamBuilder that listens to changes in the Firestore collection for the user's hours.
  */
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No authenticated user.')),
      );
    }

    return Scaffold(
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
                Text('Service Hours', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('Users')
                      .doc(user.uid)
                      .collection('Hours')
                      .snapshots(),
                  builder: (context, snapshot) {
                    double totalHours = 0;
                    double highNeedsHours = 0;
                    if (snapshot.hasData) {
                      for (final doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final status = data['status'] ?? 'pending';
                        if (status == 'approved') {
                          final h = data['hours'];
                          if (h is num) {
                            totalHours += h.toDouble();
                            final isHighNeeds = data['high_needs'] ?? false;
                            if (isHighNeeds) {
                              highNeedsHours += h.toDouble();
                            }
                          }
                        }
                      }
                    }
                    final progress = (totalHours / 50).clamp(0.0, 1.0);
                    final highNeedsProgress = (highNeedsHours / 50).clamp(0.0, 1.0);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              LinearProgressIndicator(
                                value: progress,
                                minHeight: 16,
                                backgroundColor: kAccentColor.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  totalHours >= 50 ? Colors.green : kPrimaryColor,
                                ),
                              ),
                              LinearProgressIndicator(
                                value: highNeedsProgress,
                                minHeight: 16,
                                backgroundColor: Colors.transparent,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  kAccentOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
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

                      return Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 32,
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(kSecondaryColor.withOpacity(0.18)),
                                  dataRowColor: MaterialStateProperty.all(Colors.white),
                              dividerThickness: 1,
                              headingTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                              dataTextStyle: const TextStyle(color: Colors.black87),
                              columnSpacing: 40,
                              horizontalMargin: 24,
                              columns: const [
                              DataColumn(label: Text('Place')),
                              DataColumn(label: Text('Hours')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: docs.map((doc) {
                              final data = doc.data()! as Map<String, dynamic>;
                              final timestamp = data['date'] as Timestamp?;
                              final dateStr = timestamp != null ? timestamp.toDate().toLocal().toString().split(' ')[0] : '';
                              final status = data['status'] ?? 'pending';
                              
                              Color statusColor;
                              if (status == 'approved') {
                                statusColor = Colors.green;
                              } else if (status == 'rejected') {
                                statusColor = Colors.red;
                              } else {
                                statusColor = kAccentOrange;
                              }

                              switch (status) {
                                case 'approved':
                                  statusName = 'Approved';
                                  break;
                                case 'rejected':
                                  statusName = 'Rejected';
                                  break;
                                default:
                                  statusName = 'Pending';
                              }
                              
                              return DataRow(cells: [
                                DataCell(Text(data['place'] ?? '')),
                                DataCell(Text(data['hours']?.toString() ?? '')),
                                DataCell(Text(dateStr)),
                                DataCell(Text(statusName, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold))),
                              ]);
                            }).toList(),
                              ),
                          ),
                        ),
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
