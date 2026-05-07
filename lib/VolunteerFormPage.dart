import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomePage.dart';
const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class VolunteerFormPage extends StatefulWidget {
  final VoidCallback? onSuccess;
  const VolunteerFormPage({super.key, this.onSuccess});

  @override
  State<VolunteerFormPage> createState() => _VolunteerFormPageState();
}

class _VolunteerFormPageState extends State<VolunteerFormPage> {
  String _selectedPlace = '';
  final _hoursController = TextEditingController();
  DateTime? _selectedDate;

  final _firestore = FirebaseFirestore.instance;

  Future<void> _addEntry() async {
    final place = _selectedPlace;
    final hours = double.tryParse(_hoursController.text.trim());
    final date = _selectedDate;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (place.isEmpty || hours == null || date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out place, hours, and date.')),
      );
      return;
    }

    await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Hours')
        .add({
      'place': place,
      'hours': hours,
      'date': Timestamp.fromDate(date),
      'status': 'pending',
    });

    if (!context.mounted) return;

    // Clear form
    _selectedPlace = '';
    _hoursController.clear();
    setState(() {
      _selectedDate = null;
    });

    widget.onSuccess?.call();
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
      appBar: AppBar(title: const Text('Log Hours')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Log Hours', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 2),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('Activities')
                        .where('status', isEqualTo: 'approved')  
                        .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final activities = snapshot.data!.docs;
                        final organizations = activities.map((doc) => doc['organization'] as String).toSet().toList();
                        return DropdownButtonFormField<String>(
                          value: _selectedPlace.isEmpty ? null : _selectedPlace,
                          decoration: const InputDecoration(labelText: 'Place'),
                          items: organizations.map((org) {
                            return DropdownMenuItem<String>(
                              value: org,
                              child: Text(org),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlace = value ?? '';
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: _hoursController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hours')),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'No date selected'
                                : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSecondaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _pickDate,
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(onPressed: _addEntry, child: const Text('Save Hours')),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(title: 'Home')));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        side: BorderSide(color: kPrimaryColor),
                      ),
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}