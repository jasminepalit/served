import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HourDetailPage.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class AdminHourApproval extends StatelessWidget {
  const AdminHourApproval({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hour Approvals'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('Hours')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _getPendingHours(snapshot.data!.docs),
            builder: (context, hoursSnapshot) {
              if (!hoursSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final pendingHours = hoursSnapshot.data ?? [];

              if (pendingHours.isEmpty) {
                return const Center(
                  child: Text('No pending hours for approval.'),
                );
              }

              return ListView.builder(
                itemCount: pendingHours.length,
                itemBuilder: (context, index) {
                  final item = pendingHours[index];
                  final studentName = item['studentName'] as String;
                  final studentEmail = item['studentEmail'] as String;
                  final studentId = item['studentId'] as String;
                  final hoursValue = item['hours'];
                  final place = item['place'] as String;
                  final dateText = item['dateText'] as String;
                  final hourId = item['hourId'] as String;
                  final hourData = item['hourData'] as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(studentName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Email: $studentEmail'),
                          Text('Hours: $hoursValue'),
                          Text('Place: $place'),
                          Text('Date: $dateText'),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HourDetailPage(
                            studentId: studentId,
                            hourId: hourId,
                            hourData: hourData,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getPendingHours(
  List<QueryDocumentSnapshot> hourDocs,
) async {
  final futures = hourDocs.map((hourDoc) async {
    final hourData = hourDoc.data() as Map<String, dynamic>;

    final studentId = hourDoc.reference.parent.parent?.id ?? '';
    if (studentId.isEmpty) return null;

    final studentDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(studentId)
        .get();

    final userData = studentDoc.data() ?? {};

    final firstName = userData['firstName'] ?? 'Unknown';
    final lastName = userData['lastName'] ?? 'Student';

    final rawDate = hourData['date'];
    DateTime? parsedDate;

    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    }

    final dateText =
        parsedDate?.toLocal().toString().split(' ')[0] ?? 'No date';

    return {
      'studentName': '$firstName $lastName',
      'studentEmail': userData['email'] ?? 'No email',
      'studentId': studentId,
      'hours': hourData['hours'] ?? 'N/A',
      'place': hourData['place'] ?? 'Unknown Place',
      'dateText': dateText,
      'hourId': hourDoc.id,
      'hourData': hourData,
      'dateValue': parsedDate,
    };
  });

  final results = await Future.wait(futures);

  final pendingHours = results
      .whereType<Map<String, dynamic>>()
      .toList();

  pendingHours.sort((a, b) {
    final aDate = a['dateValue'] as DateTime?;
    final bDate = b['dateValue'] as DateTime?;

    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;

    return bDate.compareTo(aDate);
  });

  return pendingHours;
}
}