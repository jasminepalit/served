import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class HourApprovalPage extends StatefulWidget {
  final String studentId;
  final String hourId;
  final Map<String, dynamic> hourData;

  const HourApprovalPage({
    super.key,
    required this.studentId,
    required this.hourId,
    required this.hourData,
  });

  @override
  State<HourApprovalPage> createState() =>
      _HourApprovalPageState();
}

class _HourApprovalPageState extends State<HourApprovalPage> {
  late Future<Map<String, dynamic>> studentInfoFuture;
  bool isLoading = false;

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

  Future<void> _approveHour() async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.studentId)
          .collection('Hours')
          .doc(widget.hourId)
          .update({'status': 'approved', 'approvedAt': Timestamp.now()});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hour approved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _rejectHour() async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.studentId)
          .collection('Hours')
          .doc(widget.hourId)
          .update({'status': 'rejected', 'rejectedAt': Timestamp.now()});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hour rejected.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _requestMoreInfo() {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request More Information'),
        content: TextField(
          controller: messageController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Explain what additional information you need...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final requestMessage = messageController.text.trim();
              if (requestMessage.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a message before sending.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              setState(() => isLoading = true);
              try {
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(widget.studentId)
                    .collection('Hours')
                    .doc(widget.hourId)
                    .update({
                  'status': 'more_info',
                  'requestMessage': requestMessage,
                  'moreInfoRequestedAt': Timestamp.now(),
                });

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('More information request sent to student.'),
                    backgroundColor: kAccentOrange,
                  ),
                );
                Navigator.pop(context, true);
                Navigator.pop(context, true);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              } finally {
                if (mounted) setState(() => isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kAccentOrange),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hour Approval'),
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
                // Header Card
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.3),
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
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Student Name', studentName, Colors.white),
                      const SizedBox(height: 12),
                      _buildInfoRow('Student Email', studentEmail, Colors.white),
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

                const SizedBox(height: 32),

                // Action Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _approveHour,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve Hour'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _rejectHour,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject Hour'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _requestMoreInfo,
                      icon: const Icon(Icons.info),
                      label: const Text('Request More Information'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.9),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
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
