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
  bool _showEmailError = false;
  bool _showPhoneError = false;

  final _firestore = FirebaseFirestore.instance;

  bool _isValidEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(trimmed);
  }

  bool _isValidPhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10;
  }

  Future<void> _addEntry() async {
    final organization = _organizationController.text.trim();
    final advisorName = _advisorNameController.text.trim();
    final advisorEmail = _advisorEmailController.text.trim();
    final advisorNumber = _advisorNumberController.text.trim();
    final description = _descriptionController.text.trim();
    final highNeedsDescription = _isHighNeeds
        ? _highNeedsDescriptionController.text.trim()
        : '';
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final hasValidEmail = _isValidEmail(advisorEmail);
    final hasValidPhone = _isValidPhone(advisorNumber);

    setState(() {
      _showEmailError = !hasValidEmail;
      _showPhoneError = !hasValidPhone;
    });

    if (organization.isEmpty ||
        advisorName.isEmpty ||
        advisorEmail.isEmpty ||
        advisorNumber.isEmpty ||
        description.isEmpty ||
        (_isHighNeeds && highNeedsDescription.isEmpty) ||
        !hasValidEmail ||
        !hasValidPhone) {
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
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add Activity',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Activity Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _organizationController,
                            decoration: const InputDecoration(
                              labelText: 'Organization Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Activity Description',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Advisor Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _advisorNameController,
                            decoration: const InputDecoration(
                              labelText: 'Advisor Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _advisorEmailController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => setState(() {
                              _showEmailError = false;
                            }),
                            decoration: InputDecoration(
                              labelText: 'Advisor Email',
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _showEmailError
                                      ? kAccentOrange
                                      : Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _showEmailError
                                      ? kAccentOrange
                                      : Colors.grey,
                                  width: _showEmailError ? 2 : 1,
                                ),
                              ),
                              errorText: _showEmailError
                                  ? 'Enter a valid email'
                                  : null,
                              errorStyle: const TextStyle(color: kAccentOrange),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _advisorNumberController,
                            keyboardType: TextInputType.phone,
                            onChanged: (_) => setState(() {
                              _showPhoneError = false;
                            }),
                            decoration: InputDecoration(
                              labelText: 'Advisor Phone Number',
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _showPhoneError
                                      ? kAccentOrange
                                      : Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _showPhoneError
                                      ? kAccentOrange
                                      : Colors.grey,
                                  width: _showPhoneError ? 2 : 1,
                                ),
                              ),
                              errorText: _showPhoneError
                                  ? 'Enter a valid phone number'
                                  : null,
                              errorStyle: const TextStyle(color: kAccentOrange),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            title: const Text('High Needs Activity'),
                            value: _isHighNeeds,
                            onChanged: (value) =>
                                setState(() => _isHighNeeds = value ?? false),
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (_isHighNeeds)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TextField(
                                controller: _highNeedsDescriptionController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Why is it high needs?',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addEntry,
                    child: const Text('Add Entry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
