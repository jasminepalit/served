import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:served/AdminDatabaseView.dart';
import 'LoginPage.dart';
import 'HomePage.dart';
import 'VolunteerFormPage.dart';
import 'ActivityFormPage.dart';
import 'auth_helpers.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  String _selectedLogOption = 'Home';

  Widget _getPage() {
    if (_selectedIndex == 0) return AdminDatabaseView();
    return _getLogPage();
  }

  Widget _getLogPage() {
    if (_selectedLogOption == 'Log Hours') {
      return const VolunteerFormPage();
    } else {
      return const ActivityFormPage();
    }
  }

  String userType = 'user';
  String firstName = 'Loading...';
  String lastName = 'Loading...';
  
  @override
  void initState() {
    super.initState();
    print("Mainscreen");

    loadFirstName().then((value) {
      if (!mounted) return;
      setState(() {
        firstName = value;
        print(value);
      });
    });
    loadLastName().then((value) {
      if (!mounted) return;
      setState(() {
        lastName = value;
        print(value);
      });
    });
    loadUserType().then((value) {
      if (!mounted) return;
      setState(() {
        userType = value;
        print("Mainscreen sees $value");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(firstName),
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
          if (_selectedIndex == 1) ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
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
        ],
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() {
          _selectedIndex = index;
          if (index == 0) {
            _selectedLogOption = 'Home';
          }
        }),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Log',
          ),
        ],
      ),
    );
  }
}
