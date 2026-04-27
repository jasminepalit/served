import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SignUpPage.dart';
import 'main.dart';
import 'LoginPage.dart';
import 'AdminActivityApproval.dart';
import 'AdminDeleteAccounts.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class Adminhomepage extends StatefulWidget {
  const Adminhomepage({super.key});


  @override
  State<Adminhomepage> createState() => _AdminhomepageState();
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFF93a1fd),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(userData['email'] ?? 'No email'),
                subtitle: Text('Role: ${userData['type'] ?? 'user'}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminhomepageState extends State<Adminhomepage> {
 

  Future<double> _fetchStudentHours() async {
    double total = 0;
    final firestore = FirebaseFirestore.instance;
    final students = await firestore.collection('Users').where('type', isEqualTo: 'user').get();
    for (final student in students.docs) {
      final hoursSnapshot = await firestore
          .collection('Users')
          .doc(student.id)
          .collection('Hours')
          .get();
      for (final hoursDoc in hoursSnapshot.docs) {
        final data = hoursDoc.data();
        final hoursValue = data['hours'];
        if (hoursValue is num) {
          total += hoursValue.toDouble();
        } else if (hoursValue is String) {
          total += double.tryParse(hoursValue) ?? 0;
        }
      }
    }
    return total;
  }
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servd Admin'),
         centerTitle: true,
        backgroundColor: const Color(0xFF93a1fd),
        leading: TextButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
              return LoginPage();}), (route) => false,);
          },
          child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        ),
        actions: [
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPage())),
              child: const Text('View Users', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminActivityApprovalPage())),
              child: const Text('Approve Activities', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminDeleteAccounts()),
    ),
    child: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
  ),
          ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome Admin!',
              style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 24, 126)),
            ),
            const SizedBox(height: 20),
            FutureBuilder<double>(
              future: _fetchStudentHours(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final totalHours = snapshot.data ?? 0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF93a1fd),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Student Hours',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      Text(
                        totalHours.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) => Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF93a1fd),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}