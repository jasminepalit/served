/**
 * StudentActivityPage.dart is a Flutter widget that displays a list of activities logged by the currently authenticated student user. It retrieves activity data from Firestore and shows it in a DataTable format. Each activity displays the organization, date, status, and any admin feedback if applicable. If an activity requires more information, the student can click an "Edit & Resubmit" button to navigate to an edit page where they can update the activity details and resubmit it for approval. The page also handles loading states and error messages gracefully.
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);
/**
 * StudentActivityPage is a StatelessWidget that displays the logged activities of the currently authenticated student user. It listens to changes in the Firestore collection for the user's activities and updates the UI accordingly. Each activity shows its organization, date, status, and any admin feedback if the status is "more_info". If an activity requires more information, a button is provided to navigate to an edit page where the student can update the activity details and resubmit it for approval.
 */
class StudentActivityPage extends StatelessWidget {
  const StudentActivityPage({super.key});

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'more_info':
        return 'More Info Requested';
      case 'pending':
        return 'Pending';
      default:
        return 'Pending';
    }
  }
/**
 * _statusTextStyle returns a TextStyle based on the activity status. Approved activities are shown in green, rejected in red, and those requiring more information in orange. Pending activities are displayed in a default black color. This method helps visually differentiate the status of each activity in the DataTable.
 */
  TextStyle _statusTextStyle(String status) {
    switch (status) {
      case 'approved':
        return const TextStyle(color: Colors.green, fontWeight: FontWeight.bold);
      case 'rejected':
        return const TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
      case 'more_info':
        return const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold);
      case 'pending':
      default:
        return const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold);
    }
  }
/**
 * build method constructs the UI for the StudentActivityPage. It first checks if there is a logged-in user and retrieves their activities from Firestore. The activities are displayed in a DataTable with columns for organization, date, status, and action. The status column uses the _statusLabel and _statusTextStyle methods to display the status with appropriate text and color. If an activity requires more information, an "Edit & Resubmit" button is shown that navigates to the ActivityEditPage, allowing the student to update the activity details and resubmit it for approval. The page also handles loading states and displays messages when there are no activities or if an error occurs while fetching data.
 */
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('All Activities'), backgroundColor: kPrimaryColor),
        body: const Center(child: Text('No logged-in user found.')),
      );
    }

    final activitiesStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Activities')
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('My Activities'), backgroundColor: kPrimaryColor),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: activitiesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text('No activities logged yet.'));
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(kSecondaryColor.withOpacity(0.18)),
                            dataRowColor: MaterialStateProperty.all(Colors.white),
                            headingTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                            dataTextStyle: const TextStyle(color: Colors.black87),
                            columnSpacing: 30,
                            columns: const [
                              DataColumn(label: Text('Organization')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: docs.map((doc) {
                              final data = doc.data()! as Map<String, dynamic>;
                              final status = (data['status'] ?? 'pending').toString();
                              final requestMessage = data['requestMessage']?.toString() ?? '';
                              final timestamp = data['date'] as Timestamp?;
                              final dateStr = timestamp != null
                              ? timestamp.toDate().toLocal().toString().split(' ')[0]
                              : 'No date';

                              return DataRow(cells: [
                                DataCell(Text(data['organization']?.toString() ?? '')),
                                DataCell(Text(dateStr)),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_statusLabel(status), style: _statusTextStyle(status)),
                                      if (status == 'more_info' && requestMessage.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          requestMessage,
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                       ),
                                      ],
                                    ],   
                                  ),
                               ),
                                DataCell(
                                  status == 'more_info'
                                  ? TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ActivityEditPage(
                                              activityId: doc.id,
                                              activityData: data,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Edit & Resubmit'),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
/**
 * ActivityEditPage is a StatefulWidget that allows students to edit and resubmit an activity that requires more information. It takes the activity ID and its current data as parameters. The page pre-fills the form fields with the existing activity data, allowing the student to make necessary changes. The student can update the organization, description, date, advisor information, and specify if it's a high needs activity along with a description for it. Upon saving, the updated activity is sent back to Firestore with its status reset to "pending" and any previous admin feedback removed. The page also handles loading states and displays success or error messages accordingly.
 */
class ActivityEditPage extends StatefulWidget {
  final String activityId;
  final Map<String, dynamic> activityData;

  const ActivityEditPage({super.key, required this.activityId, required this.activityData});

  @override
  State<ActivityEditPage> createState() => _ActivityEditPageState();
}
/**
 * _ActivityEditPageState is the state class for ActivityEditPage. It manages the form fields for editing an activity, including organization, description, date, advisor information, and high needs details. The state initializes the form fields with the existing activity data and provides functionality to pick a date and save changes back to Firestore. When saving, it updates the activity document with the new data, resets the status to "pending", and removes any previous admin feedback. The state also handles loading states and displays appropriate messages based on the success or failure of the save operation.
 */
class _ActivityEditPageState extends State<ActivityEditPage> {
  final _organizationController = TextEditingController();
  final _advisorNameController = TextEditingController();
  final _advisorEmailController = TextEditingController();
  final _advisorNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _highNeedsDescriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _isHighNeeds = false;
  bool _isSaving = false;
/**
 * initState initializes the form fields with the existing activity data passed from the previous page. It retrieves the organization, advisor information, description, high needs details, and date from the activity data and populates the respective controllers and state variables. This allows the student to see the current values of the activity and make necessary edits before resubmitting it for approval.
 */
  @override
  void initState() {
    super.initState();
    final data = widget.activityData;
    _organizationController.text = data['organization']?.toString() ?? '';
    _advisorNameController.text = data['advisorName']?.toString() ?? '';
    _advisorEmailController.text = data['advisorEmail']?.toString() ?? '';
    _advisorNumberController.text = data['advisorNumber']?.toString() ?? '';
    _descriptionController.text = data['description']?.toString() ?? '';
    _highNeedsDescriptionController.text = data['highNeedsDescription']?.toString() ?? '';
    _isHighNeeds = data['isHighNeeds'] ?? false;
    final timestamp = data['date'] as Timestamp?;
    _selectedDate = timestamp?.toDate();
  }
/**
 * pickDate shows a date picker dialog to the user, allowing them to select a new date for the activity. The initial date shown in the picker is either the currently selected date or the current date if no date is selected. The user can choose a date between January 1, 2000, and December 31, 2100. If the user picks a date, it updates the _selectedDate state variable with the new value, which will be displayed in the form and saved back to Firestore when the user saves their changes.
 */
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
/**
 * saveChanges validates the form data and updates the activity document in Firestore with the new values entered by the student. It first checks if there is a logged-in user and if a date has been selected. If validation passes, it sets the _isSaving state to true to show a loading indicator. It then updates the activity document with the new organization, advisor information, description, date, high needs details, and resets the status to "pending" while removing any previous admin feedback. After a successful update, it shows a success message and navigates back to the previous page. If an error occurs during the save operation, it catches the exception and displays an error message to the user. Finally, it resets the _isSaving state to false regardless of the outcome.
 */
  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date before resubmitting.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Activities')
          .doc(widget.activityId)
          .update({
        'organization': _organizationController.text.trim(),
        'advisorName': _advisorNameController.text.trim(),
        'advisorEmail': _advisorEmailController.text.trim(),
        'advisorNumber': _advisorNumberController.text.trim(),
        'description': _descriptionController.text.trim(),
        'date': Timestamp.fromDate(_selectedDate!),
        'isHighNeeds': _isHighNeeds,
        'highNeedsDescription': _isHighNeeds ? _highNeedsDescriptionController.text.trim() : '',
        'status': 'pending',
        'requestMessage': FieldValue.delete(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity resubmitted for approval.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving activity: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
/**
 * build method constructs the UI for the ActivityEditPage. It displays a form with fields pre-filled with the existing activity data, allowing the student to edit the organization, description, date, advisor information, and high needs details. If there is an admin request for more information, it shows a highlighted message at the top of the form. The student can pick a new date using a date picker and save their changes by clicking the "Save and Resubmit" button. The button shows a loading indicator while the save operation is in progress. The page also includes a back button in the app bar to navigate back to the previous page without saving changes.
 */
  @override
  Widget build(BuildContext context) {
    final requestMessage = widget.activityData['requestMessage']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Activity'),
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false, // removes the back arrow
        leading: IconButton(                          // ADD THIS
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
  ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (requestMessage.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Admin Requested More Information', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    const SizedBox(height: 8),
                    Text(requestMessage, style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            TextField(controller: _organizationController, decoration: const InputDecoration(labelText: 'Organization', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Activity Description', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(_selectedDate == null ? 'No date selected' : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}')),
                TextButton(onPressed: _pickDate, child: const Text('Pick Date')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _advisorNameController, decoration: const InputDecoration(labelText: 'Advisor Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _advisorEmailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Advisor Email', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _advisorNumberController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Advisor Phone Number', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('High Needs Activity'),
              value: _isHighNeeds,
              onChanged: (value) => setState(() => _isHighNeeds = value ?? false),
              contentPadding: EdgeInsets.zero,
            ),
            if (_isHighNeeds) ...[
              const SizedBox(height: 8),
              TextField(controller: _highNeedsDescriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Why is it high needs?', border: OutlineInputBorder())),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save and Resubmit'),
            ),
          ],
        ),
      ),
    );
  }
}
