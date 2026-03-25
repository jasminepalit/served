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
      title: 'Firebase Word App',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const WordHomePage(),
    );
  }
}

class WordHomePage extends StatefulWidget {
  const WordHomePage({super.key});

  @override
  State<WordHomePage> createState() => _WordHomePageState();
}

class _WordHomePageState extends State<WordHomePage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add word to Firestore
  Future<void> _addWord() async {
    final word = _controller.text.trim();
    if (word.isEmpty) return;

    await _firestore.collection('words').add({
      'word': word,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Word App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter a word',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addWord, child: const Text('Add Word')),
            const SizedBox(height: 20),
            const Text(
              'Words in Database:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Expanded ListView shows all words in real-time
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('words')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Text('No words yet.');

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final word = docs[index]['word'] ?? '';
                      return ListTile(
                        title: Text(word),
                      );
                    },
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