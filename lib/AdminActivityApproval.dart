import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/painting/text_style.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class AdminActivityApproval extends StatelessWidget {
  const AdminActivityApproval({super.key});

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
                        style: TextStyle(color: Color.fromARGB(255, 54, 244, 114), fontWeight: FontWeight.bold)
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

class ActivityApprovalDetailPage extends StatefulWidget {
  final String studentId;
  final String activityId;
  final Map<String, dynamic> activityData;

  const ActivityApprovalDetailPage({
    super.key,
    required this.studentId,
    required this.activityId,
    required this.activityData,
  });

  @override
  State<ActivityApprovalDetailPage> createState() =>
      _ActivityApprovalDetailPageState();
}

class _ActivityApprovalDetailPageState extends State<ActivityApprovalDetailPage> {
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

  Future<void> _approveActivity() async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.studentId)
          .collection('Activities')
          .doc(widget.activityId)
          .update({'status': 'approved', 'approvedAt': Timestamp.now()});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity approved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
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

  Future<void> _rejectActivity() async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.studentId)
          .collection('Activities')
          .doc(widget.activityId)
          .update({'status': 'rejected', 'rejectedAt': Timestamp.now()});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity rejected.'),
          backgroundColor: Colors.red,
        ),
      );
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
                    .collection('Activities')
                    .doc(widget.activityId)
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
        title: const Text('Activity Approval'),
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
          final studentName = studentInfo['displayName'] ?? 'Unknown Student';
          final studentEmail = studentInfo['email'] ?? 'No email';
          final activityDate = widget.activityData['date'] as Timestamp?;
          final organization = widget.activityData['organization'] ?? 'N/A';
          final description = widget.activityData['description'] ?? 'N/A';
          final advisorName = widget.activityData['advisorName'] ?? 'N/A';
          final advisorEmail = widget.activityData['advisorEmail'] ?? 'N/A';
          final advisorPhone = widget.activityData['advisorNumber'] ?? 'N/A';
          final isHighNeeds = widget.activityData['isHighNeeds'] ?? false;
          final highNeedsDescription = widget.activityData['highNeedsDescription'] ?? '';

          final formattedDate = activityDate != null
              ? DateTime.fromMillisecondsSinceEpoch(
                      activityDate.millisecondsSinceEpoch)
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

                // Activity Details Card
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
                        'Activity Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Date', formattedDate),
                      _buildDetailRow('Organization', organization),
                      const SizedBox(height: 12),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kAccentColor),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          description,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      if (isHighNeeds) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'High Needs Activity',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Student marked this activity as high needs.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                highNeedsDescription.isNotEmpty
                                    ? highNeedsDescription
                                    : 'No additional high needs description provided.',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Advisor Information Card
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
                        'Advisor Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Advisor Name', advisorName),
                      _buildDetailRow('Phone Number', advisorPhone),
                      _buildDetailRow('Email', advisorEmail),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _approveActivity,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve Activity'),
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
                      onPressed: isLoading ? null : _rejectActivity,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject Activity'),
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

