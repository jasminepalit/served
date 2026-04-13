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
  const ActivityFormPage({super.key});

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
  DateTime? _selectedDate;
  bool _isHighNeeds = false;

  final _firestore = FirebaseFirestore.instance;

  Future<void> _addEntry() async {
    final date = _selectedDate;
    final organization = _organizationController.text.trim();
    final advisorName = _advisorNameController.text.trim();
    final advisorEmail = _advisorEmailController.text.trim();
    final advisorNumber = _advisorNumberController.text.trim();
    final description = _descriptionController.text.trim();
    final highNeedsDescription = _isHighNeeds ? _highNeedsDescriptionController.text.trim() : '';
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (date == null) return;

    await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Activities')
        .add({
      'date': Timestamp.fromDate(date),
      'organization': organization,
      'advisorName': advisorName,
      'advisorEmail': advisorEmail,
      'advisorNumber': advisorNumber,
      'description': description,
      'isHighNeeds': _isHighNeeds,
      'highNeedsDescription': highNeedsDescription,
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
      _selectedDate = null;
      _isHighNeeds = false;
    });

    Navigator.push(context, MaterialPageRoute(builder: (context) { // ignore: use_build_context_synchronously
            return HomePage(title: "HomePage");
          }));

  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
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
                          Row(
                            children: [
                              Expanded(child: Text(_selectedDate == null ? 'No date selected' : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}')),
                              TextButton(onPressed: _pickDate, child: const Text('Pick Date')),
                            ],
                          ),
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


