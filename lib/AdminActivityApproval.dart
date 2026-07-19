import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/painting/text_style.dart';
import 'auth_helpers.dart';
import 'ActivityApprovalDetailPage.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class AdminActivityApproval extends StatefulWidget {
  const AdminActivityApproval({super.key});

  @override
  State<AdminActivityApproval> createState() => _AdminActivityApprovalState();
}

class _AdminActivityApprovalState extends State<AdminActivityApproval> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    
    print("AdminActivityApproval");
  }
  DateTime? _activityDate(Map<String, dynamic> activityData) {
    final dateValue = activityData['date'];
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    }
    if (dateValue is DateTime) {
      return dateValue;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Approvals'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('Activities')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final activities = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final aDate = _activityDate(a.data() as Map<String, dynamic>);
              final bDate = _activityDate(b.data() as Map<String, dynamic>);

              if (aDate == null && bDate == null) return 0;
              if (aDate == null) return 1;
              if (bDate == null) return -1;
              return aDate.compareTo(bDate);
            });

          if (activities.isEmpty) {
            return const Center(
              child: Text('No pending activities for approval.'),
            );
          }

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activityDoc = activities[index];
              final activityData = activityDoc.data() as Map<String, dynamic>;
              final studentId = activityDoc.reference.parent.parent!.id;
              final isHighNeeds = activityData['isHighNeeds'] ?? false;
              final activityDate = _activityDate(activityData);
              final formattedDate = activityDate != null
                  ? '${activityDate.toLocal().year}-${activityDate.toLocal().month.toString().padLeft(2, '0')}-${activityDate.toLocal().day.toString().padLeft(2, '0')}'
                  : 'No date';

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(studentId)
                    .get(),
                builder: (context, studentSnapshot) {
                  final studentData =
                      studentSnapshot.data?.data() ?? <String, dynamic>{};
                  final studentName =
                      '${studentData['firstName'] ?? ''} ${studentData['lastName'] ?? ''}'
                          .trim();
                  final studentEmail =
                      studentData['email']?.toString() ?? 'No email';
                  final displayName = studentName.isNotEmpty
                      ? studentName
                      : 'Unknown Student';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 4),
                          Text(activityData['organization']?.toString() ?? 'Unknown Organization'),
                          Text('Email: $studentEmail'),
                          Text('Date: $formattedDate'),
                          if (isHighNeeds)
                            const Text(
                              'High Needs: Yes',
                              style: TextStyle(
                                color: Color.fromARGB(255, 72, 175, 77),
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else
                            const Text(
                              'High Needs: No',
                              style: TextStyle(
                                color: Color.fromARGB(255, 209, 65, 65),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityApprovalDetailPage(
                            studentId: studentId,
                            activityId: activityDoc.id,
                            activityData: activityData,
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
}
