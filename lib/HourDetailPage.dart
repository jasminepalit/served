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
                          child: Icon(Icons.check, size: 16, color: Colors.green),
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
                      ElevatedButton.icon(
                        onPressed: _requestMoreInformation,
                        icon: const Icon(Icons.info, color: Colors.white),
                        label: const Text('Request More Information'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
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

  Future<void> _updateHourStatus(String status, [String? requestMessage]) async {
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
      );
    } catch (e) {
      _showSnackBar('Failed to update hour: $e');
    }
  }

  Future<String?> _showRequestInformationDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request More Information'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'What additional details do you need?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

  void _requestMoreInformation() async {
    final message = await _showRequestInformationDialog();
    if (message == null || message.trim().isEmpty) return;
    await _updateHourStatus('needs_information', message.trim()).then((_) {
      Navigator.of(context).pop();
    });
  }
}