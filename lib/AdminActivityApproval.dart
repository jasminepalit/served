/**
 * AdminActivityApproval.dart is a Flutter page that allows administrators to view and approve pending activities submitted by students. It listens to the Firestore collection for any activities with a status of "pending" and displays them in a list. Each list item shows the organization name and whether the activity is marked as high needs. Tapping on an activity navigates to the ActivityApprovalDetailPage, where administrators can review the details and approve or reject the activity.
 */
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
/**
 * AdminActivityApproval is a page that allows administrators to view and approve pending activities submitted by students. It listens to the Firestore collection for any activities with a status of "pending" and displays them in a list. Each list item shows the organization name and whether the activity is marked as high needs. Tapping on an activity navigates to the ActivityApprovalDetailPage, where administrators can review the details and approve or reject the activity.
 */
class AdminActivityApproval extends StatefulWidget {
  const AdminActivityApproval({super.key});

  @override
  State<AdminActivityApproval> createState() => _AdminActivityApprovalState();
}
/**
 * _AdminActivityApprovalState is the state class for AdminActivityApproval. It manages the search query state and builds the UI for displaying pending activities. It uses a StreamBuilder to listen to changes in the Firestore collection and updates the list of activities in real-time. Each activity is displayed as a ListTile, and tapping on it navigates to the detail page for that activity.
 */
class _AdminActivityApprovalState extends State<AdminActivityApproval> {
  String _searchQuery = '';
  /**
   * build is the method that constructs the UI for the AdminActivityApproval page. It creates a Scaffold with an AppBar and a body that contains a StreamBuilder. The StreamBuilder listens to the Firestore collection for pending activities and builds a ListView of ListTiles for each activity. Each ListTile displays the organization name and whether the activity is high needs, and allows navigation to the detail page when tapped.
   */
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
