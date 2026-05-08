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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final users = snapshot.data!.docs;
          
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
