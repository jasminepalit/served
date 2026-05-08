/**
 * HourApprovalPage.dart is a Flutter widget that allows administrators to review and manage student hour submissions. It fetches student information and hour details from Firestore, and provides options to approve, reject, or request more information about the submitted hours. The page is designed with a clean and modern UI, utilizing custom colors and styles for an enhanced user experience.
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);
/**
 * HourApprovalPage is a StatefulWidget that displays detailed information about a student's hour submission and provides options for administrators to approve, reject, or request more information. It fetches student details from Firestore and updates the hour's status based on the administrator's actions.
 */
class HourApprovalPage extends StatefulWidget {
  final String studentId;
  final String hourId;
  final Map<String, dynamic> hourData;
/**
 * The constructor for HourApprovalPage initializes the widget with the necessary data, including the student ID, hour ID, and hour details. This information is essential for fetching the relevant data from Firestore and managing the approval process effectively.
 */
  const HourApprovalPage({
    super.key,
    required this.studentId,
    required this.hourId,
    required this.hourData,
  });
/**
 * createState creates the mutable state for the HourApprovalPage widget, allowing it to manage and update its internal state based on user interactions and data changes. The state is responsible for fetching student information, handling approval/rejection actions, and updating the UI accordingly.
 */
  @override
  State<HourApprovalPage> createState() =>
      _HourApprovalPageState();
}
/**
 * _HourApprovalPageState is the state class for HourApprovalPage, responsible for managing the internal state of the widget. It handles fetching student information from Firestore, processing approval and rejection actions, and updating the UI based on user interactions. The state ensures that the page remains responsive and provides feedback to the administrator during the approval process.
 */
class _HourApprovalPageState extends State<HourApprovalPage> {
  late Future<Map<String, dynamic>> studentInfoFuture;
  bool isLoading = false;
/**
 * initState initializes the state of the HourApprovalPage by calling the _fetchStudentInfo method to retrieve the student's information from Firestore. This method is called once when the widget is first created, ensuring that the necessary data is available for display and interaction on the page.
 */
  @override
  void initState() {
    super.initState();
    studentInfoFuture = _fetchStudentInfo();
  }
/**
 * _fetchStudentInfo is an asynchronous method that retrieves the student's information from Firestore based on the provided student ID. It accesses the 'Users' collection, fetches the document corresponding to the student ID, and returns the data as a map. This information is essential for displaying the student's details on the HourApprovalPage and providing context for the hour submission being reviewed.
 */
  Future<Map<String, dynamic>> _fetchStudentInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.studentId)
        .get();
    return doc.data() ?? {};
  }
/**
 * _approveHour is an asynchronous method that updates the status of the hour submission to 'approved' in Firestore. It also records the time of approval using a timestamp. The method provides feedback to the administrator through SnackBar notifications and navigates back to the previous screens upon successful approval. If an error occurs during the process, it displays an error message to the administrator.
 */
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
/**
 * _rejectHour is an asynchronous method that updates the status of the hour submission to 'rejected' in Firestore. It also records the time of rejection using a timestamp. Similar to the approval method, it provides feedback to the administrator through SnackBar notifications and navigates back to the previous screens upon successful rejection. If an error occurs during the process, it displays an error message to the administrator.
 */
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
/**
 * _requestMoreInfo is a method that allows administrators to request additional information from the student regarding their hour submission. It opens a dialog where the administrator can enter a message explaining what information is needed. Upon sending the request, it updates the hour's status to 'more_info' in Firestore and includes the request message and timestamp. The method also provides feedback to the administrator through SnackBar notifications and navigates back to the previous screens upon successful submission of the request. If an error occurs during the process, it displays an error message to the administrator.
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
/**
 * build is the method responsible for constructing the UI of the HourApprovalPage. It uses a Scaffold to provide a basic layout with an AppBar and a body that displays the student's information and hour details. The body utilizes a FutureBuilder to fetch and display student information asynchronously, and includes buttons for approving, rejecting, or requesting more information about the hour submission. The UI is designed with custom colors and styles to enhance the user experience for administrators reviewing hour submissions.
 */
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
/**
 * _buildInfoRow is a helper method that constructs a row widget for displaying a label and its corresponding value. It takes in the label, value, and text color as parameters, and returns a Row widget with the label on the left and the value on the right. The text styles are designed to differentiate between the label and value, with the label having a slightly lighter color and the value being bold for emphasis. This method is used to display student information in a clean and organized manner on the HourApprovalPage.
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
 * _buildDetailRow is a helper method that constructs a column widget for displaying a label and its corresponding value in a vertical layout. It takes in the label and value as parameters, and returns a Column widget with the label at the top and the value below it. The label is styled with a primary color and a slightly smaller font size, while the value is styled with a darker color for better readability. This method is used to display hour details in an organized and visually appealing manner on the HourApprovalPage.
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
