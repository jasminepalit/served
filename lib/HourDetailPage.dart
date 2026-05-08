/**
 * HourDetailPage.dart is a Flutter widget that displays detailed information about a specific hour entry for a student. It allows administrators to approve, reject, or request more information about the hour entry. The page fetches student information from Firestore and updates the hour status based on the administrator's actions.
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);
/**
 * HourDetailPage is a StatefulWidget that takes in the studentId, hourId, and hourData as parameters. It fetches the student's information from Firestore and displays it along with the hour details. The page provides buttons for administrators to approve, reject, or request more information about the hour entry. The status of the hour entry is updated in Firestore based on the administrator's actions.
 */
class HourDetailPage extends StatefulWidget {
  final String studentId;
  final String hourId;
  final Map<String, dynamic> hourData;
/**
 * The constructor for HourDetailPage initializes the studentId, hourId, and hourData properties. These properties are required to fetch the relevant information from Firestore and display it on the page. The constructor also calls the super constructor with the key parameter to ensure proper widget initialization.
 */
  const HourDetailPage({
    super.key,
    required this.studentId,
    required this.hourId,
    required this.hourData,
  });
/**
 * createState creates the mutable state for this widget. It returns an instance of _HourDetailPageState, which manages the state and logic for fetching student information and handling hour entry actions.
 */
  @override
  State<HourDetailPage> createState() =>
      _HourDetailPageState();
}
/**
 * _HourDetailPageState is the state class for HourDetailPage. It manages the fetching of student information and handles the logic for approving, rejecting, or requesting more information about the hour entry. The state class uses a FutureBuilder to display the student information and hour details once they are fetched from Firestore. It also defines methods to update the hour status in Firestore based on the administrator's actions.
 */
class _HourDetailPageState extends State<HourDetailPage> {
  late Future<Map<String, dynamic>> studentInfoFuture;
/**
 * initState is called when the state object is first created. It initializes the studentInfoFuture by calling the _fetchStudentInfo method, which retrieves the student's information from Firestore based on the studentId provided in the widget. This allows the FutureBuilder in the build method to display the student information once it is fetched.
 */
  @override
  void initState() {
    super.initState();
    studentInfoFuture = _fetchStudentInfo();
  }
/**
 * _fetchStudentInfo is an asynchronous method that retrieves the student's information from Firestore. It accesses the 'Users' collection and fetches the document corresponding to the studentId provided in the widget. The method returns a map containing the student's information, which is used to display the student's name and email on the HourDetailPage.
 */
  Future<Map<String, dynamic>> _fetchStudentInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.studentId)
        .get();
    return doc.data() ?? {};
  }
/**
 * build is the method that describes the part of the user interface represented by this widget. It returns a Scaffold containing an AppBar and a body that uses a FutureBuilder to display the student information and hour details. The FutureBuilder waits for the studentInfoFuture to complete and then displays the relevant information. The page also includes buttons for approving, rejecting, or requesting more information about the hour entry, which trigger the corresponding methods to update the hour status in Firestore.
 */
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
/**
 * _buildDetailRow is a helper method that builds a row for displaying a label and its corresponding value. It takes in a label and a value as parameters and returns a Column widget that displays the label in a bold font and the value below it. This method is used to display the student information and hour details in a consistent format throughout the HourDetailPage.
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
/**
 * _updateHourStatus is an asynchronous method that updates the status of the hour entry in Firestore. It takes in a status string and an optional requestMessage string as parameters. The method constructs an updateData map that includes the new status and the current timestamp. If a requestMessage is provided, it also includes the requestMessage and the infoRequestedAt timestamp. The method then checks if a user-specific hour document exists in the 'Users' collection and updates it accordingly. If it doesn't exist, it updates the hour document in the 'Hours' collection. After updating, it shows a SnackBar with a message indicating the result of the action.
 */
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
/**
 * _showRequestInformationDialog is an asynchronous method that displays a dialog for the administrator to enter a message when requesting more information about the hour entry. It uses a TextEditingController to capture the input from the TextField in the dialog. The method returns the entered message when the "Send" button is pressed, or null if the "Cancel" button is pressed or if the input is empty. This message is then used to update the hour status in Firestore with a request for more information.
 */
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
/**
 * _showSnackBar is a helper method that displays a SnackBar with a given message. It uses the ScaffoldMessenger to show the SnackBar at the bottom of the screen. This method is called after updating the hour status to provide feedback to the administrator about the result of their action (e.g., hour approved, hour rejected, or requested more information).
 */
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