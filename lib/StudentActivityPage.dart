import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'footer_bar.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class StudentActivityPage extends StatelessWidget {
  final bool showFooter;

  const StudentActivityPage({super.key, this.showFooter = true});

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

  TextStyle _statusTextStyle(String status) {
    switch (status) {
      case 'approved':
        return const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        );
      case 'rejected':
        return const TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
      case 'more_info':
        return const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        );
      case 'pending':
      default:
        return const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('All Activities'),
          backgroundColor: kPrimaryColor,
        ),
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
      bottomNavigationBar: showFooter ? FooterBar() : null,
      appBar: AppBar(
        title: const Text('My Activities'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
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
                            headingRowColor: MaterialStateProperty.all(
                              kSecondaryColor.withOpacity(0.18),
                            ),
                            dataRowColor: MaterialStateProperty.all(
                              Colors.white,
                            ),
                            headingTextStyle: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            dataTextStyle: const TextStyle(
                              color: Colors.black87,
                            ),
                            columnSpacing: 30,
                            columns: const [
                              DataColumn(label: Text('Organization')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('High Needs')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: docs.map((doc) {
                              final data = doc.data()! as Map<String, dynamic>;
                              final status = (data['status'] ?? 'pending')
                                  .toString();
                              final isHighNeedsRaw =
                                  data['isHighNeeds'] ??
                                  data['high_needs'] ??
                                  false;
                              final isHighNeeds = isHighNeedsRaw is bool
                                  ? isHighNeedsRaw
                                  : isHighNeedsRaw.toString().toLowerCase() ==
                                        'true';
                              final requestMessage =
                                  data['requestMessage']?.toString() ?? '';
                              final timestamp = data['date'] as Timestamp?;
                              final dateStr = timestamp != null
                                  ? timestamp
                                        .toDate()
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0]
                                  : 'No date';
                              final isEditable =
                                  status == 'pending' || status == 'more_info';

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      data['organization']?.toString() ?? '',
                                    ),
                                  ),
                                  DataCell(Text(dateStr)),
                                  DataCell(
                                    Text(
                                      isHighNeeds ? 'Yes' : 'No',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isHighNeeds
                                            ? kAccentOrange
                                            : Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _statusLabel(status),
                                          style: _statusTextStyle(status),
                                        ),
                                        if (status == 'more_info' &&
                                            requestMessage.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            requestMessage,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    isEditable
                                        ? TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ActivityEditPage(
                                                        activityId: doc.id,
                                                        activityData: data,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Edit & Resubmit',
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              );
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

class ActivityEditPage extends StatefulWidget {
  final String activityId;
  final Map<String, dynamic> activityData;

  const ActivityEditPage({
    super.key,
    required this.activityId,
    required this.activityData,
  });

  @override
  State<ActivityEditPage> createState() => _ActivityEditPageState();
}

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

  @override
  void initState() {
    super.initState();
    final data = widget.activityData;
    _organizationController.text = data['organization']?.toString() ?? '';
    _advisorNameController.text = data['advisorName']?.toString() ?? '';
    _advisorEmailController.text = data['advisorEmail']?.toString() ?? '';
    _advisorNumberController.text = data['advisorNumber']?.toString() ?? '';
    _descriptionController.text = data['description']?.toString() ?? '';
    _highNeedsDescriptionController.text =
        data['highNeedsDescription']?.toString() ?? '';
    _isHighNeeds = data['isHighNeeds'] ?? false;
    final timestamp = data['date'] as Timestamp?;
    _selectedDate = timestamp?.toDate();
  }

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

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final currentStatus =
        widget.activityData['status']?.toString() ?? 'pending';
    if (currentStatus != 'pending' && currentStatus != 'more_info') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This activity can no longer be edited.'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context);
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date before resubmitting.'),
        ),
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
            'highNeedsDescription': _isHighNeeds
                ? _highNeedsDescriptionController.text.trim()
                : '',
            'status': 'pending',
            'requestMessage': FieldValue.delete(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity resubmitted for approval.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving activity: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestMessage =
        widget.activityData['requestMessage']?.toString() ?? '';

    return Scaffold(
      bottomNavigationBar: FooterBar(),
      appBar: AppBar(
        title: const Text('Edit Activity'),
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false, // removes the back arrow
        leading: IconButton(
          // ADD THIS
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
                    const Text(
                      'Admin Requested More Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      requestMessage,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            TextField(
              controller: _organizationController,
              decoration: const InputDecoration(
                labelText: 'Organization',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Activity Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No date selected'
                        : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _advisorNameController,
              decoration: const InputDecoration(
                labelText: 'Advisor Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _advisorEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Advisor Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _advisorNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Advisor Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('High Needs Activity'),
              value: _isHighNeeds,
              onChanged: (value) =>
                  setState(() => _isHighNeeds = value ?? false),
              contentPadding: EdgeInsets.zero,
            ),
            if (_isHighNeeds) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _highNeedsDescriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Why is it high needs?',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8600),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save and Resubmit'),
            ),
          ],
        ),
      ),
    );
  }
}
