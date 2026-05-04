// Import necessary packages for Flutter, Firebase, and local files
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart';
import 'HomePage.dart';
import 'VolunteerFormPage.dart';

// Define color constants for the app's theme
const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

// Activity form page widget for submitting new activities
class ActivityFormPage extends StatefulWidget {
  const ActivityFormPage({super.key});

  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

// State class for ActivityFormPage
class _ActivityFormPageState extends State<ActivityFormPage> {
  // Controllers for form fields
  final _organizationController = TextEditingController();
  final _advisorNameController = TextEditingController();
  final _advisorEmailController = TextEditingController();
  final _advisorNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _highNeedsDescriptionController = TextEditingController();
  // Flag for high needs activity
  bool _isHighNeeds = false;

  // Firestore instance
  final _firestore = FirebaseFirestore.instance;

  // Function to add activity entry to Firestore
  Future<void> _addEntry() async {
    // Get trimmed text from controllers
    final organization = _organizationController.text.trim();
    final advisorName = _advisorNameController.text.trim();
    final advisorEmail = _advisorEmailController.text.trim();
    final advisorNumber = _advisorNumberController.text.trim();
    final description = _descriptionController.text.trim();
    final highNeedsDescription = _isHighNeeds ? _highNeedsDescriptionController.text.trim() : '';
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Validate required fields
    if (organization.isEmpty || advisorName.isEmpty || advisorEmail.isEmpty || 
        advisorNumber.isEmpty || description.isEmpty || 
        (_isHighNeeds && highNeedsDescription.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.')),
      );
      return;
    }

    // Add activity to user's Activities subcollection
    await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Activities')
        .add({
      
      'organization': organization,
      'advisorName': advisorName,
      'advisorEmail': advisorEmail,
      'advisorNumber': advisorNumber,
      'description': description,
      'isHighNeeds': _isHighNeeds,
      'highNeedsDescription': highNeedsDescription,
      'status': 'pending',
    });

    if (!context.mounted) return;

    // Clear form fields after submission
    _organizationController.clear();
    _advisorNameController.clear();
    _advisorEmailController.clear();
    _advisorNumberController.clear();
    _descriptionController.clear();
    _highNeedsDescriptionController.clear();
    setState(() {
      
      _isHighNeeds = false;
    });

    // Navigate back
    Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title
      appBar: AppBar(title: const Text('Activity Form')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Form title
                const Text('Add Activity', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Activity information section
                          const Text('Activity Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          // Organization name field
                          TextField(controller: _organizationController, decoration: const InputDecoration(labelText: 'Organization Name', border: OutlineInputBorder())),
                          const SizedBox(height: 8),
                          // Activity description field
                          TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Activity Description', border: OutlineInputBorder())),
                          const SizedBox(height: 8),
                          
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Advisor information section
                          const Text('Advisor Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          // Advisor name field
                          TextField(controller: _advisorNameController, decoration: const InputDecoration(labelText: 'Advisor Name', border: OutlineInputBorder())),
                          const SizedBox(height: 8),
                          // Advisor email field
                          TextField(controller: _advisorEmailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Advisor Email', border: OutlineInputBorder())),
                          const SizedBox(height: 8),
                          // Advisor phone number field
                          TextField(controller: _advisorNumberController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Advisor Phone Number', border: OutlineInputBorder())),
                          const SizedBox(height: 8),
                          // High needs checkbox
                          CheckboxListTile(
                            title: const Text('High Needs Activity'),
                            value: _isHighNeeds,
                            onChanged: (value) => setState(() => _isHighNeeds = value ?? false),
                            contentPadding: EdgeInsets.zero,
                          ),
                          // Conditional high needs description field
                          if (_isHighNeeds)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TextField(controller: _highNeedsDescriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Why is it high needs?', border: OutlineInputBorder())),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Submit button
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _addEntry, child: const Text('Add Entry'))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


