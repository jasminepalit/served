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

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  late final Future<String> firstNameFuture;
  String statusName = 'Loading...';

  @override
  void initState() {
    super.initState();
    firstNameFuture = loadFirstName();
  }

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
            Text(
              'Service Hours',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Users')
                  .doc(user.uid)
                  .collection('Hours')
                  .snapshots(),
              builder: (context, snapshot) {
                double totalHours = 0;
                if (snapshot.hasData) {
                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'pending';
                    if (status == 'approved') {
                      final h = data['hours'];
                      if (h is num) {
                        totalHours += h.toDouble();
                      }
                    }
                  }
                }

                final progress = (totalHours / 50).clamp(0.0, 1.0);

                return FutureBuilder<double>(
                  future: fetchSpecificStudentHighNeedsHours(user.uid),
                  builder: (context, highNeedsSnapshot) {
                    final highNeedsHours = highNeedsSnapshot.data ?? 0.0;
                    final highNeedsProgress = (highNeedsHours / 50).clamp(
                      0.0,
                      1.0,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${totalHours.toStringAsFixed(1)} / 50 hours',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              totalHours >= 50
                                  ? '🎉 Goal reached!'
                                  : '${(50 - totalHours).toStringAsFixed(1)} hrs to go',
                              style: TextStyle(
                                fontSize: 13,
                                color: totalHours >= 50
                                    ? Colors.green
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            Text(
                              'High Needs: ${highNeedsHours.toStringAsFixed(1)} hrs',
                              style: const TextStyle(
                                fontSize: 13,
                                color: kAccentOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Regular: ${(totalHours - highNeedsHours).toStringAsFixed(1)} hrs',
                              style: const TextStyle(
                                fontSize: 13,
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: totalHours >= 50
                              ? LinearProgressIndicator(
                                  value: 1.0,
                                  minHeight: 16,
                                  backgroundColor: Colors.green.withOpacity(
                                    0.2,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.green,
                                      ),
                                )
                              : Stack(
                                  children: [
                                    LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 16,
                                      backgroundColor: kAccentColor.withOpacity(
                                        0.3,
                                      ),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            kPrimaryColor,
                                          ),
                                    ),
                                    LinearProgressIndicator(
                                      value: highNeedsProgress,
                                      minHeight: 16,
                                      backgroundColor: Colors.transparent,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
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
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const ActivityFormPage();
                          },
                        ),
                      );
                    },
                    child: const Text('Log Activity'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const VolunteerFormPage();
                          },
                        ),
                      );
                    },
                    child: const Text('Log Hours'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const StudentActivityPage();
                    },
                  ),
                );
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
                      if (!snapshot.hasData)
                        return const Center(child: CircularProgressIndicator());
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty)
                        return const Center(child: Text('No entries yet.'));

                      return Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 32,
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth:
                                      MediaQuery.of(context).size.width - 32,
                                ),
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                    kSecondaryColor.withOpacity(0.18),
                                  ),
                                  dataRowColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                  dividerThickness: 1,
                                  headingTextStyle: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  dataTextStyle: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                  columnSpacing: 40,
                                  horizontalMargin: 24,
                                  columns: const [
                                    DataColumn(label: Text('Place')),
                                    DataColumn(label: Text('Hours')),
                                    DataColumn(label: Text('Date')),
                                    DataColumn(label: Text('Status')),
                                  ],
                                  rows: docs.map((doc) {
                                    final data =
                                        doc.data()! as Map<String, dynamic>;
                                    final timestamp =
                                        data['date'] as Timestamp?;
                                    final dateStr = timestamp != null
                                        ? timestamp
                                              .toDate()
                                              .toLocal()
                                              .toString()
                                              .split(' ')[0]
                                        : '';
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

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(data['place'] ?? '')),
                                        DataCell(
                                          Text(data['hours']?.toString() ?? ''),
                                        ),
                                        DataCell(Text(dateStr)),
                                        DataCell(
                                          Text(
                                            statusName,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
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
