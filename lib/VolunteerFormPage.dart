import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'MainScreen.dart';
import 'HomePage.dart';

class VolunteerFormPage extends StatefulWidget {
  const VolunteerFormPage({super.key});

  @override
  State<VolunteerFormPage> createState() => _VolunteerFormPageState();
}

class _VolunteerFormPageState extends State<VolunteerFormPage> {
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _hoursController = TextEditingController();
  DateTime? _selectedDate;

  final _firestore = FirebaseFirestore.instance;

  Future<void> _addEntry() async {
    final name = _nameController.text.trim();
    final place = _placeController.text.trim();
    final hours = double.tryParse(_hoursController.text.trim());
    final date = _selectedDate;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (name.isEmpty || place.isEmpty || hours == null || date == null) return;

    await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Hours')
        .add({
      'name': name,
      'place': place,
      'hours': hours,
      'date': Timestamp.fromDate(date),
    });

    if (!context.mounted) return;

    // Clear form
    _nameController.clear();
    _placeController.clear();
    _hoursController.clear();
    setState(() {
      _selectedDate = null;
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
      appBar: AppBar(title: const Text('Volunteer Form')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Form Fields
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _placeController, decoration: const InputDecoration(labelText: 'Place')),
            TextField(controller: _hoursController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hours')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(_selectedDate == null
                      ? 'No date selected'
                      : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                ),
                TextButton(onPressed: _pickDate, child: const Text('Pick Date')),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addEntry, child: const Text('Add Entry')),
            const SizedBox(height: 20),
            
            // DataTable
            
          ],
        ),
      ),
    );
  }
}