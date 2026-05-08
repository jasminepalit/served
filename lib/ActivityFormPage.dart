import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart';
import 'HomePage.dart';
import 'VolunteerFormPage.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class ActivityFormPage extends StatefulWidget {
  final VoidCallback? onSuccess;
  const ActivityFormPage({super.key, this.onSuccess});

  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  final _organizationController = TextEditingController();
  final _advisorNameController = TextEditingController();
  final _advisorEmailController = TextEditingController();
  final _advisorNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _highNeedsDescriptionController = TextEditingController();
  bool _isHighNeeds = false;

  final _firestore = FirebaseFirestore.instance;

  Future<void> _addEntry() async {
    
    final organization = _organizationController.text.trim();
    final advisorName = _advisorNameController.text.trim();
    final advisorEmail = _advisorEmailController.text.trim();
    final advisorNumber = _advisorNumberController.text.trim();
    final description = _descriptionController.text.trim();
    final highNeedsDescription = _isHighNeeds ? _highNeedsDescriptionController.text.trim() : '';
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Validation: Check that all required fields are filled
    if (organization.isEmpty || advisorName.isEmpty || advisorEmail.isEmpty || 
        advisorNumber.isEmpty || description.isEmpty || 
        (_isHighNeeds && highNeedsDescription.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.')),
      );
      return;
    }

    

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
      'date': Timestamp.now(),
    });

    if (!context.mounted) return;

    // Clear form
    _organizationController.clear();
    _advisorNameController.clear();
    _advisorEmailController.clear();
    _advisorNumberController.clear();
    _descriptionController.clear();
    _highNeedsDescriptionController.clear();
    setState(() {
      _isHighNeeds = false;
    });

    if (widget.onSuccess != null) {
      widget.onSuccess!();
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const Text('Add Activity', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Activity Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(controller: _organizationController, decoration: const InputDecoration(labelText: 'Organization Name', border: OutlineInputBorder())),
                          const SizedBox(height: 8),
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
                          const Text('Advisor Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(controller: _advisorNameController, decoration: const InputDecoration(labelText: 'Advisor Name', border: OutlineInputBorder())),
                          const SizedBox(height: 8),
                          TextField(controller: _advisorEmailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Advisor Email', border: OutlineInputBorder())),
                          const SizedBox(height: 8),
                          TextField(controller: _advisorNumberController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Advisor Phone Number', border: OutlineInputBorder())),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            title: const Text('High Needs Activity'),
                            value: _isHighNeeds,
                            onChanged: (value) => setState(() => _isHighNeeds = value ?? false),
                            contentPadding: EdgeInsets.zero,
                          ),
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
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _addEntry, child: const Text('Add Entry'))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


