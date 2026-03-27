import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Volunteer App',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const HomePage(title: 'HomePage'),
    );
  }
}

class VolunteerFormPage extends StatefulWidget {
  const VolunteerFormPage({super.key});

  @override
  State<VolunteerFormPage> createState() => _VolunteerFormPageState();
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const VolunteerFormPage();
          }));
        },
          child: const Text('Next'),
        ),
      ),
    );
  }
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

    if (name.isEmpty || place.isEmpty || hours == null || date == null) return;

    await _firestore.collection('adrika2').add({
      'name': name,
      'place': place,
      'hours': hours,
      'date': Timestamp.fromDate(date),
    });

    // Clear form
    _nameController.clear();
    _placeController.clear();
    _hoursController.clear();
    setState(() {
      _selectedDate = null;
    });
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
            const Text('Entries:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // DataTable
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('adrika2').orderBy('date', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No entries yet.'));

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Place')),
                        DataColumn(label: Text('Hours')),
                        DataColumn(label: Text('Date')),
                      ],
                      rows: docs.map((doc) {
                        final data = doc.data()! as Map<String, dynamic>;
                        final timestamp = data['date'] as Timestamp?;
                        final dateStr = timestamp != null ? timestamp.toDate().toLocal().toString().split(' ')[0] : '';
                        return DataRow(cells: [
                          DataCell(Text(data['name'] ?? '')),
                          DataCell(Text(data['place'] ?? '')),
                          DataCell(Text(data['hours']?.toString() ?? '')),
                          DataCell(Text(dateStr)),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}