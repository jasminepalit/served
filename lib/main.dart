import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Ideal time to initialize
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //...
  FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseAuth.instance
  .idTokenChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseAuth.instance
  .userChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user != null) {
      print(user.uid);
    }
  });

  

  runApp(const MyApp());
}

Future<User?> signUp(String email, String password) async {
  print("Received sign up request for email: $email");
  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    print("User signed up: ${credential.user?.uid}");

    final user = credential.user;

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .set({
      'email': user.email,
      'createdAt': Timestamp.now(),
    });

    return user;
  } catch (e) {
    print("Sign up error: $e");
    return null;
  }
}

Future<User?> signIn(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  } catch (e) {
    print("Login error: $e");
    return null;
  }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servd',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: LoginPage(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _selectedLogOption = 'Log Hours';

  Widget _getPage() {
    if (_selectedIndex == 0) return HomePage();
    return _getLogPage();
  }

  Widget _getLogPage() {
    if (_selectedLogOption == 'Log Hours') {
      return const VolunteerFormPage();
    } else {
      return const LogActivitiesPage();
    }
  }

class HomePage extends StatelessWidget {
  HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  final _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servd'),
        centerTitle: true,
        backgroundColor: const Color(0xFF93a1fd),
        leading: TextButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            // Optionally, navigate to login screen or show message
          },
          child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _selectedIndex = 0),
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedIndex = 1;
                _selectedLogOption = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Log Hours', child: Text('Log Hours')),
              PopupMenuItem(value: 'Add Activity', child: Text('Add Activity')),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Log', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: _getPage(),
    );
  }
}

// Your existing HomePage (modified to not have Scaffold)
class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
          child: Text(
            'Welcome',
            style: TextStyle(
              fontSize: 75,
              color: const Color(0xFF27187e),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
              child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Users')
                  .doc(user!.uid)
                  .collection('Hours')
                  .orderBy('date', descending: true)
                  .snapshots(),                
                  builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No entries yet.'));

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
                ),
              );
            },
          ),
        ),
      ],
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (name.isEmpty || _selectedActivityId == null || hours == null || date == null) return;

    final selectedActivity = _activities.firstWhere((a) => a['id'] == _selectedActivityId);
    final place = selectedActivity['organization'];

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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
            onPressed: () async {
              final user = await signIn(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              );

              if (user != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(title: "HomePage"),
                  ),
                );
              }
            },
            child: const Text('Login'),
          ),
            ElevatedButton(
              onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(),
                    ),
                  );
                
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print("Attempting to sign up with email: ${_emailController.text.trim()}");
                final user = await signUp(_emailController.text.trim(), _passwordController.text.trim());
                print("User signed up: ${user?.uid}");
                if (user != null) {

                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(title: "HomePage")));
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
