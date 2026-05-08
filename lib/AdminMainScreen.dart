/**
 * AdminMainScreen.dart is the main screen for admin users in the Served app. It provides a navigation bar with options for viewing user data, editing user status, approving activities, and approving hours. The screen displays the admin's first name in the title and allows them to sign out. The content of the screen changes based on the selected option in the navigation bar, providing access to different admin functionalities.
 */
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:served/AdminDatabaseView.dart';
import 'package:served/AdminDeleteAccounts.dart';
import 'LoginPage.dart';
import 'AdminHomePage.dart';
import 'auth_helpers.dart';
import 'AdminActivityApproval.dart';
import 'AdminHourApproval.dart';
/**
 * AdminMainScreen is the main screen for admin users. It contains a navigation bar with options to view user data, edit user status, approve activities, and approve hours. The main content of the screen changes based on the selected option in the navigation bar.
 */
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});
  /**
   * Creates the state for the AdminMainScreen widget.
   * @return A new instance of _AdminMainScreenState which manages the state of the AdminMainScreen widget.
   */
  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}
/**
 * _AdminMainScreenState is the state class for AdminMainScreen. It manages the selected index of the navigation bar and loads user information such as first name, last name, and user type. It also handles the sign-out functionality and updates the main content based on the selected option in the navigation bar.
 */
class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  /**
   * _getPage returns the appropriate widget based on the selected index of the navigation bar. It checks the value of _selectedIndex and returns the corresponding page widget for each option in the navigation bar. If the index does not match any of the defined options, it defaults to returning the AdminHomePage widget.
   * @return A widget corresponding to the selected index in the navigation bar.
    - If _selectedIndex is 0, it returns AdminHomePage.
    - If _selectedIndex is 1, it returns AdminDatabaseView.
    - If _selectedIndex is 2, it returns AdminDeleteAccounts.
    - If _selectedIndex is 3, it returns AdminActivityApproval.
    - If _selectedIndex is 4, it returns AdminHourApproval.
   * If none of the above conditions are met, it returns AdminHomePage by default.
   */
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
    else if (_selectedIndex == 4) {
      return const AdminHourApproval();
    }
    else{
    return const AdminHomePage();
    }
  }

  String userType = 'user';
  String firstName = 'Loading...';
  String lastName = 'Loading...';
  /**
   * initState is called when the state object is first created. It initializes the state of the AdminMainScreen by loading the user's first name, last name, and user type from the database. The loaded values are then set to the corresponding state variables and printed to the console for debugging purposes. The method also ensures that the widget is still mounted before updating the state to avoid any potential issues with asynchronous operations.
   */
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
  /**
   * build is the method that builds the UI of the AdminMainScreen. It returns a Scaffold widget that contains an AppBar and a body. The AppBar includes a title with the user's first name, a sign-out button, and navigation buttons for different admin functionalities. The body of the Scaffold displays the content based on the selected index from the navigation bar, which is determined by the _getPage method. The navigation buttons update the selected index and change their color to indicate which page is currently active.
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('lib/images/servd.png', height: 40),
            const SizedBox(width: 8),
            Text(firstName, style: const TextStyle(color: Colors.white)),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5128B5),
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
          TextButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 4;
              });
            },
            child: Text(
              'Approve Hours',
              style: TextStyle(
                color: _selectedIndex == 4 ? Color(0xFFFF8600) : Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: _getPage(),
    );
  }
}
