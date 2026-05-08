/**
 * ActivityApprovalDetailPage.dart is a Flutter page that provides a detailed view for administrators to review and manage student-submitted activities. It displays comprehensive information about the student and the activity, and offers options to approve, reject, or request more information from the student. The page interacts with Firestore to fetch necessary data and update the activity status based on admin actions. The UI is designed to be clean and organized, with clear sections for student information, activity details, and advisor information, along with visually distinct buttons for administrative actions.
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/painting/text_style.dart';
import 'auth_helpers.dart';


const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);
/**
 * ActivityApprovalDetailPage is a detailed view for administrators to review and manage student-submitted activities. It displays comprehensive information about the student and the activity, and provides options to approve, reject, or request more information from the student. The page fetches necessary data from Firestore and updates the activity status based on admin actions.
 */
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
/**
 * The _ActivityApprovalDetailPageState class manages the state of the ActivityApprovalDetailPage. It handles fetching student information from Firestore, displaying activity details, and processing admin actions such as approving, rejecting, or requesting more information. The state includes loading indicators and error handling to ensure a smooth user experience for administrators reviewing student activities.
 */
class _ActivityApprovalDetailPageState extends State<ActivityApprovalDetailPage> {
  late Future<Map<String, dynamic>> studentInfoFuture;
  bool isLoading = false;
  // The initState method initializes the state of the page by calling the _fetchStudentInfo method to retrieve the student's information from Firestore. This information is essential for displaying the student's name and email on the activity approval detail page. The studentInfoFuture variable is used to manage the asynchronous operation of fetching data, allowing the UI to react accordingly while waiting for the data to load.
  @override
  void initState() {
    super.initState();
    studentInfoFuture = _fetchStudentInfo();
  }
  /**
   * _fetchStudentInfo is a private method that retrieves the student's information from Firestore based on the provided studentId. It accesses the 'Users' collection, fetches the document corresponding to the studentId, and returns the data as a Map. If the document does not exist, it returns an empty Map. This information is used to display the student's name and email on the activity approval detail page.
   */
  Future<Map<String, dynamic>> _fetchStudentInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.studentId)
        .get();
    return doc.data() ?? {};
  }
  /**
   * _approveActivity is a private method that updates the status of the activity to 'approved' in Firestore. It sets the 'approvedAt' timestamp to the current time. The method also includes error handling and displays a success message upon successful approval, or an error message if something goes wrong. After approving the activity, it navigates back to the previous screen, passing a boolean value to indicate that an update occurred.
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
   * _rejectActivity is a private method that updates the status of the activity to 'rejected' in Firestore. It sets the 'rejectedAt' timestamp to the current time. Similar to _approveActivity, it includes error handling and displays appropriate messages based on the outcome of the operation. After rejecting the activity, it navigates back to the previous screen, indicating that an update occurred.
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
   * _requestMoreInfo is a private method that allows administrators to request additional information from the student regarding the submitted activity. It opens a dialog where the admin can enter a message explaining what information is needed. Upon sending the request, it updates the activity's status to 'more_info' in Firestore and includes the request message and timestamp. The method also handles validation to ensure a message is entered before sending, and provides feedback to the admin about the success or failure of the operation.
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
   * The build method constructs the UI of the ActivityApprovalDetailPage. It uses a Scaffold to provide a basic layout with an AppBar and a body. The body contains a FutureBuilder that waits for the student information to load before displaying the content. Once the data is available, it displays the student's name and email, activity details such as date, organization, description, and advisor information. It also includes action buttons for approving, rejecting, or requesting more information about the activity. The UI is designed to be clean and organized, with clear sections for different types of information and visually distinct buttons for actions.
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
          final firstName = studentInfo['firstName']?.toString() ?? '';
          final lastName = studentInfo['lastName']?.toString() ?? '';
          final studentName = (firstName.isNotEmpty || lastName.isNotEmpty)
              ? '$firstName $lastName'.trim()
              : 'Unknown Student';
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
  /**
   * _buildInfoRow is a helper method that creates a row widget for displaying a label and its corresponding value. It takes in a label, value, and text color as parameters, and returns a Row widget with the label on the left and the value on the right. The text styles are designed to differentiate the label from the value, with the label being slightly less prominent than the value. This method is used to display student information such as name and email in a consistent format throughout the page.
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
   * _buildDetailRow is a helper method that creates a column widget for displaying a label and its corresponding value in a vertical format. It takes in a label and value as parameters, and returns a Column widget with the label displayed above the value. The label is styled to be slightly more prominent than the value, using a different color and font weight. This method is used to display various details about the activity and advisor information in a clear and organized manner throughout the page.
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

