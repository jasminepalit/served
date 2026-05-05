import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class HourDetailPage extends StatefulWidget {
  final String studentId;
  final String hourId;
  final Map<String, dynamic> hourData;

  const HourDetailPage({
    super.key,
    required this.studentId,
    required this.hourId,
    required this.hourData,
  });

  @override
  State<HourDetailPage> createState() =>
      _HourDetailPageState();
}

class _HourDetailPageState extends State<HourDetailPage> {
  late Future<Map<String, dynamic>> studentInfoFuture;

  @override
  void initState() {
    super.initState();
    studentInfoFuture = _fetchStudentInfo();
  }

  Future<Map<String, dynamic>> _fetchStudentInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.studentId)
        .get();
    return doc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hour Details'),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      backgroundColor: kBackgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: studentInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final studentInfo = snapshot.data ?? {};
          final studentName = '${studentInfo['firstName'] ?? 'Unknown'} ${studentInfo['lastName'] ?? 'Student'}';
          final studentEmail = studentInfo['email'] ?? 'No email';
          final hourDate = widget.hourData['date'] as Timestamp?;
          final place = widget.hourData['place'] ?? 'N/A';
          final hours = widget.hourData['hours'] ?? 'N/A';

          final formattedDate = hourDate != null
              ? DateTime.fromMillisecondsSinceEpoch(hourDate.millisecondsSinceEpoch)
                  .toString()
                  .split(' ')[0]
              : 'No date';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Student Information Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Student Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Name', studentName),
                      _buildDetailRow('Email', studentEmail),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Hour Details Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Hour Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Hours', hours.toString()),
                      _buildDetailRow('Place', place),
                      _buildDetailRow('Date', formattedDate),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: kPrimaryColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

