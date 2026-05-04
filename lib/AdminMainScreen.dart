// Import necessary packages for Flutter, Firebase, and local files
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:served/AdminDatabaseView.dart';
import 'package:served/AdminDeleteAccounts.dart';
import 'LoginPage.dart';
import 'AdminHomePage.dart';
import 'auth_helpers.dart';
import 'AdminActivityApproval.dart';

// Admin main screen widget for admin navigation
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

// State class for AdminMainScreen
class _AdminMainScreenState extends State<AdminMainScreen> {
  // Selected index for navigation
  int _selectedIndex = 0;

  // Get the current page based on selected index
  Widget _getPage() {
    if (_selectedIndex == 0) {
      return const AdminHomePage();
    } else if (_selectedIndex == 1) {
      return const AdminDatabaseView();
    }
    else if (_selectedIndex == 2) {
       return const AdminDeleteAccounts();
    }
    else if (_selectedIndex == 3) {
      return const AdminActivityApproval();
    }
    else{
    return const AdminHomePage();
    }
  }

  // User data variables
  String userType = 'user';
  String firstName = 'Loading...';
  String lastName = 'Loading...';
  
  @override
  void initState() {
    super.initState();
    print("Mainscreen");

    // Load user data asynchronously
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
      // App bar with sign out button and navigation buttons
      appBar: AppBar(
        title: Text(firstName),
        centerTitle: true,
        backgroundColor: const Color(0xFF5128B5),
        // Sign out button
        leading: TextButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
              return LoginPage();}), (route) => false,);
          },
          child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        ),
        actions: [
          // Admin Home button
          TextButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 0;
              });
            },
            child: Text(
              'Admin Home',
              style: TextStyle(
                color: _selectedIndex == 0 ? Color(0xFFFF8600) : Colors.white,
              ),
            ),
          ),
          // View User Data button
          TextButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
            child: Text(
              'View User Data',
              style: TextStyle(
                color: _selectedIndex == 1 ? Color(0xFFFF8600) : Colors.white,
              ),
            ),
          ),

          // Edit User Status button
          TextButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 2;
              });
            },
            child: Text(
              'Edit User Status',
              style: TextStyle(
                color: _selectedIndex == 2 ? Color(0xFFFF8600) : Colors.white,
              ),
            ),
          ),
          // Approve Activities button
          TextButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 3;
              });
            },
            child: Text(
              'Approve Activities',
              style: TextStyle(
                color: _selectedIndex == 3 ? Color(0xFFFF8600) : Colors.white,
              ),
            ),
          ),
        ],
      ),
      // Body displays the selected page
      body: _getPage(),
    );
  }
}
