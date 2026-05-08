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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Approvals'),
        backgroundColor: kPrimaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collectionGroup('Activities').where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
  if (snapshot.hasError) {
    return Center(child: Text('Error: ${snapshot.error}'));
  }
  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final activities = snapshot.data!.docs;
          if (activities.isEmpty) {
            return const Center(child: Text('No pending activities for approval.'));
          }
          
          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activityDoc = activities[index];
              final activityData = activityDoc.data() as Map<String, dynamic>;
              final studentId = activityDoc.reference.parent.parent!.id; // Get user ID from path
              final isHighNeeds = activityData['isHighNeeds'] ?? false;
             
              return ListTile(
                title: Text(activityData['organization'] ?? 'Unknown Organization'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    if (isHighNeeds)
                      const Text(
                        'High Needs: Yes',
                        style: TextStyle(color: Color.fromARGB(255, 54, 244, 114), fontWeight: FontWeight.bold),
                      )
                    else
                      const Text(
                        'High Needs: No',
                        style: TextStyle(color: Color.fromARGB(255, 255, 0, 0), fontWeight: FontWeight.bold),
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
              );
            },
          );
        },
      ),
    );
  }
}
