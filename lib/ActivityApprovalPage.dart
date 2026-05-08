/**
 * ActivityApprovalPage.dart is a Flutter widget that provides an interface for administrators to review and manage student activity submissions. It displays detailed information about the student and the activity, and allows administrators to approve, reject, or request more information from the student. The page interacts with Firebase Firestore to fetch student data and update activity status based on the administrator's actions. The UI is designed to be clean and user-friendly, making it easy for administrators to effectively manage student activities.
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);
/**
 * ActivityApprovalPage is a Flutter widget that allows administrators to review and manage student activity submissions. It displays detailed information about the student and the activity, and provides options to approve, reject, or request more information from the student. The page interacts with Firebase Firestore to fetch student data and update activity status based on the administrator's actions.
 */
class ActivityApprovalPage extends StatefulWidget {
  final String studentId;
  final String activityId;
  final Map<String, dynamic> activityData;

  const ActivityApprovalPage({
    super.key,
    required this.studentId,
    required this.activityId,
    required this.activityData,
  });

  @override
  State<ActivityApprovalPage> createState() =>
      _ActivityApprovalPageState();
}
/**
 * _ActivityApprovalPageState manages the state of the ActivityApprovalPage widget. It handles fetching student information from Firebase Firestore, updating the activity status based on administrator actions (approve, reject, request more info), and displaying appropriate feedback to the user through SnackBars. The state also manages loading states to prevent multiple actions while a request is being processed.
 */
class _ActivityApprovalPageState extends State<ActivityApprovalPage> {
  late Future<Map<String, dynamic>> studentInfoFuture;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    studentInfoFuture = _fetchStudentInfo();
  }
  /**
   * _fetchStudentInfo retrieves the student's information from the 'Users' collection in Firebase Firestore using the provided studentId. It returns a Future that resolves to a Map containing the student's data, which is used to display the student's name and email on the ActivityApprovalPage.
   */
  Future<Map<String, dynamic>> _fetchStudentInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.studentId)
        .get();
    return doc.data() ?? {};
  }
  /**
   * _approveActivity updates the status of the activity to 'approved' in Firebase Firestore. It also records the time of approval. After successfully updating the status, it shows a success SnackBar and navigates back to the previous screens. If an error occurs during the update, it catches the exception and displays an error SnackBar. The method also manages the loading state to prevent multiple submissions while the request is being processed.
   */
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
  /**
   * _rejectActivity updates the status of the activity to 'rejected' in Firebase Firestore. It also records the time of rejection. After successfully updating the status, it shows a rejection SnackBar and navigates back to the previous screens. If an error occurs during the update, it catches the exception and displays an error SnackBar. The method also manages the loading state to prevent multiple submissions while the request is being processed.
   */
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
  /**
   * _requestMoreInfo allows the administrator to request additional information from the student regarding the activity. It opens a dialog where the administrator can enter a message explaining what information is needed. Upon sending, it updates the activity status to 'more_info' in Firebase Firestore and includes the request message and timestamp. It also provides feedback through SnackBars and manages the loading state during the process.
   */
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
  /**
   * build is the main method that constructs the user interface of the ActivityApprovalPage. It uses a Scaffold to create the basic layout, including an AppBar and a body that displays student and activity information. The body utilizes a FutureBuilder to fetch and display student data asynchronously. It also includes action buttons for approving, rejecting, or requesting more information about the activity, with appropriate styling and feedback mechanisms through SnackBars. The UI is designed to be clean and user-friendly, making it easy for administrators to review and manage student activities effectively.
   */
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _approveActivity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Approve'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _rejectActivity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _requestMoreInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('More Info'),
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
  /**
   * _buildInfoRow is a helper method that creates a row widget displaying a label and its corresponding value. It takes in the label, value, and text color as parameters and returns a Row widget with the label on the left and the value on the right. The text styles are applied to differentiate between the label and value, making it visually clear for the user when viewing student information on the ActivityApprovalPage.
   */
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
  /**
   * _buildDetailRow is a helper method that creates a column widget displaying a label and its corresponding value in a vertical layout. It takes in the label and value as parameters and returns a Column widget with the label at the top and the value below it. The method applies specific text styles to the label and value to enhance readability and visual hierarchy when displaying activity details on the ActivityApprovalPage.
   */
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
