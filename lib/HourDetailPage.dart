import 'package:flutter/material.dart';
import 'package:served/footer_bar.dart';
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
  State<HourDetailPage> createState() => _HourDetailPageState();
}

class _HourDetailPageState extends State<HourDetailPage> {
  late Future<Map<String, dynamic>> studentInfoFuture;

  @override
  void initState() {
    super.initState();
    studentInfoFuture = _fetchStudentInfo();
    print("In HourDetailPage");
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
      bottomNavigationBar: FooterBar(),
      appBar: AppBar(
        title: const Text('Hour Details'),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      backgroundColor: kBackgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: studentInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final studentInfo = snapshot.data ?? {};
          final studentName =
              '${studentInfo['firstName'] ?? 'Unknown'} ${studentInfo['lastName'] ?? 'Student'}';
          final studentEmail = studentInfo['email'] ?? 'No email';
          final hourDate = widget.hourData['date'] as Timestamp?;
          final place = widget.hourData['place'] ?? 'N/A';
          final hours = widget.hourData['hours'] ?? 'N/A';
          final advisorName = widget.hourData['advisorName'] ?? 'N/A';
          final advisorEmail = widget.hourData['advisorEmail'] ?? 'N/A';
          final signatureUrl = widget.hourData['signatureUrl'] ?? '';

          final formattedDate = hourDate != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  hourDate.millisecondsSinceEpoch,
                ).toString().split(' ')[0]
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
                      _buildDetailRow('Advisor Name', advisorName.toString()),
                      _buildDetailRow('Advisor Email', advisorEmail.toString()),
                      Image.network(
                        signatureUrl,
                        height: 300,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading signature image: $error');
                          return const Text('No signature available');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
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
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _approveHour,
                        icon: const CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.green,
                          ),
                        ),
                        label: const Text('Approve Hours'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _rejectHour,
                        icon: const CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.close, size: 16, color: Colors.red),
                        ),
                        label: const Text('Reject Hours'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
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
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _updateHourStatus(
    String status, [
    String? requestMessage,
  ]) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (requestMessage != null) {
        updateData['requestMessage'] = requestMessage;
        updateData['infoRequestedAt'] = FieldValue.serverTimestamp();
      }

      final userHourRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.studentId)
          .collection('Hours')
          .doc(widget.hourId);

      final userHourDoc = await userHourRef.get();

      if (userHourDoc.exists) {
        await userHourRef.set(updateData, SetOptions(merge: true));
      } else {
        await FirebaseFirestore.instance
            .collection('Hours')
            .doc(widget.hourId)
            .set(updateData, SetOptions(merge: true));
      }

      _showSnackBar(
        status == 'approved'
            ? 'Hour approved'
            : status == 'rejected'
            ? 'Hour rejected'
            : 'Requested more information',
        backgroundColor: status == 'approved'
            ? Colors.green
            : status == 'rejected'
            ? Colors.red
            : Colors.orange,
      );
    } catch (e) {
      _showSnackBar('Failed to update hour: $e');
    }
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void _approveHour() {
    _updateHourStatus('approved').then((_) {
      Navigator.of(context).pop();
    });
  }

  void _rejectHour() {
    _updateHourStatus('rejected').then((_) {
      Navigator.of(context).pop();
    });
  }
}