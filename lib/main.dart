import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'log_activities_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servd',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const MainScreen(), // Updated to use MainScreen
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servd'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.add), text: 'Log Hours'),
            Tab(icon: Icon(Icons.add), text: 'Log Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomePage(),
          const VolunteerFormPage(),
          const LogActivitiesPage(),
        ],
      ),
    );
  }
}

// Your existing HomePage (modified to not have Scaffold)
class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('adrika2')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return const Center(child: Text('No entries yet.'));

                return Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
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
                        final dateStr = timestamp != null
                            ? timestamp.toDate().toLocal().toString().split(
                                ' ',
                              )[0]
                            : '';
                        return DataRow(
                          cells: [
                            DataCell(Text(data['name'] ?? '')),
                            DataCell(Text(data['place'] ?? '')),
                            DataCell(Text(data['hours']?.toString() ?? '')),
                            DataCell(Text(dateStr)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Your existing VolunteerFormPage (modified to not have Scaffold)
class VolunteerFormPage extends StatefulWidget {
  const VolunteerFormPage({super.key});

  @override
  State<VolunteerFormPage> createState() => _VolunteerFormPageState();
}

class _VolunteerFormPageState extends State<VolunteerFormPage> {
  String? _selectedActivityId;
  List<Map<String, dynamic>> _activities = [];
  bool _loadingActivities = true;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() => _loadingActivities = true);
    final snapshot = await _firestore
        .collection('activities')
        .orderBy('date', descending: true)
        .get();
    setState(() {
      _activities = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      _loadingActivities = false;
    });
  }

  final _nameController = TextEditingController();
  final _hoursController = TextEditingController();
  DateTime? _selectedDate;

  final _firestore = FirebaseFirestore.instance;

  Future<void> _addEntry() async {
    final name = _nameController.text.trim();
    final hours = double.tryParse(_hoursController.text.trim());
    final date = _selectedDate;

    if (name.isEmpty || _selectedActivityId == null || hours == null || date == null) return;

    final selectedActivity = _activities.firstWhere((a) => a['id'] == _selectedActivityId);
    final place = selectedActivity['organization'];

    await _firestore.collection('adrika2').add({
      'name': name,
      'place': place,
      'hours': hours,
      'date': Timestamp.fromDate(date),
    });

    // Clear form
    _nameController.clear();
    _hoursController.clear();
    setState(() {
      _selectedDate = null;
      _selectedActivityId = null;
    });

    // Show a snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Entry added successfully!')));
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Activity Dropdown
          _loadingActivities
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<String>(
                  value: _selectedActivityId,
                  decoration: const InputDecoration(
                    labelText: 'Select Activity',
                  ),
                  items: _activities.map((activity) {
                    final desc = activity['description'] ?? '';
                    final org = activity['organization'] ?? '';
                    return DropdownMenuItem<String>(
                      value: activity['id'],
                      child: Text('$org - $desc'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedActivityId = val;
                    });
                  },
                ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _hoursController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Hours'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? 'No date selected'
                      : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                ),
              ),
              TextButton(onPressed: _pickDate, child: const Text('Pick Date')),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _addEntry, child: const Text('Add Entry')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
