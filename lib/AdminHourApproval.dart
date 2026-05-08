/**
 * AdminHourApproval.dart is a Flutter screen that allows administrators to view and manage pending hour submissions from students. It retrieves all users from the Firestore database, checks for any hours with a "pending" status, and displays them in a list. Each list item shows the student's name, email, hours submitted, place, and date. Tapping on an item navigates to a detailed view of the hour submission where the admin can approve or reject it.
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HourDetailPage.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);
/**
 * AdminHourApproval is a screen that allows administrators to view and manage pending hour submissions from students. It retrieves all users from the Firestore database, checks for any hours with a "pending" status, and displays them in a list. Each list item shows the student's name, email, hours submitted, place, and date. Tapping on an item navigates to a detailed view of the hour submission where the admin can approve or reject it.
 */
class AdminHourApproval extends StatelessWidget {
  const AdminHourApproval({super.key});
  /**
   * Builds the AdminHourApproval screen with an AppBar and a body that listens to changes in the 'Users' collection in Firestore. It uses a StreamBuilder to fetch user data and a FutureBuilder to retrieve pending hours for each user. The pending hours are displayed in a ListView, and tapping on an item navigates to the HourDetailPage for that specific hour submission.
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hour Approvals'),
        backgroundColor: kPrimaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final users = snapshot.data!.docs;
          /**
           * The FutureBuilder is used here to fetch pending hours for all users. It calls the _getPendingHours method, which iterates through each user and retrieves their hours with a "pending" status. The resulting list of pending hours is then displayed in a ListView. Each item in the ListView shows details about the hour submission, and tapping on it navigates to a detailed view of that submission.
           */
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _getPendingHours(users),
            builder: (context, hoursSnapshot) {
              if (!hoursSnapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final pendingHours = hoursSnapshot.data ?? [];
              
              if (pendingHours.isEmpty) {
                return const Center(child: Text('No pending hours for approval.'));
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
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
  /**
   * Retrieves pending hours for a list of users. It iterates through each user document, fetches their hours with a "pending" status, and compiles a list of maps containing relevant information about each pending hour submission, including the student's name, email, hours submitted, place, date, and the hour's document ID. This method is used in the FutureBuilder to display pending hours in the UI.
   */
  Future<List<Map<String, dynamic>>> _getPendingHours(List<QueryDocumentSnapshot> users) async {
    final pendingHours = <Map<String, dynamic>>[];
    
    for (final userDoc in users) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final firstName = userData['firstName'] ?? 'Unknown';
      final lastName = userData['lastName'] ?? 'Student';
      final studentName = '$firstName $lastName';
      final studentEmail = userData['email'] ?? 'No email';
      final studentId = userDoc.id;
      
      final hoursSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(studentId)
          .collection('Hours')
          .where('status', isEqualTo: 'pending')
          .get();
      
      for (final hourDoc in hoursSnapshot.docs) {
        final hourData = hourDoc.data();
        final dateText = hourData['date']?.toDate()?.toString().split(' ')[0] ?? 'No date';
        final place = hourData['place'] ?? 'Unknown Place';
        final hoursValue = hourData['hours'] ?? 'N/A';
        
        pendingHours.add({
          'studentName': studentName,
          'studentEmail': studentEmail,
          'studentId': studentId,
          'hours': hoursValue,
          'place': place,
          'dateText': dateText,
          'hourId': hourDoc.id,
          'hourData': hourData,
        });
      }
    }
      
    return pendingHours;
  }
}
