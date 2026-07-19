import 'package:flutter/material.dart';
import 'package:served/footer_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:served/AdminDatabaseView.dart';
import 'package:served/AdminDeleteAccounts.dart';
import 'LoginPage.dart';
import 'AdminHomePage.dart';
import 'auth_helpers.dart';
import 'AdminActivityApproval.dart';
import 'AdminHourApproval.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  Widget _getPage() {
    if (_selectedIndex == 0) {
      return const AdminHomePage();
    } else if (_selectedIndex == 1) {
      return const AdminDatabaseView();
    } else if (_selectedIndex == 2) {
      return const AdminDeleteAccounts();
    } else if (_selectedIndex == 3) {
      return const AdminActivityApproval();
    } else if (_selectedIndex == 4) {
      return const AdminHourApproval();
    } else {
      return const AdminHomePage();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Scaffold(
      bottomNavigationBar: FooterBar(),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('lib/images/servd.png', height: 40),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5128B5),
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return LoginPage();
                },
              ),
              (route) => false,
            );
          },
        ),
        actions: isSmallScreen
            ? [
                PopupMenuButton<int>(
                  onSelected: (value) {
                    setState(() {
                      _selectedIndex = value;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Text(
                        'Admin Home',
                        style: TextStyle(
                          color: _selectedIndex == 0 ? const Color(0xFFFF8600) : Colors.black,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        'View User Data',
                        style: TextStyle(
                          color: _selectedIndex == 1 ? const Color(0xFFFF8600) : Colors.black,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text(
                        'Edit User Status',
                        style: TextStyle(
                          color: _selectedIndex == 2 ? const Color(0xFFFF8600) : Colors.black,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: Text(
                        'Approve Activities',
                        style: TextStyle(
                          color: _selectedIndex == 3 ? const Color(0xFFFF8600) : Colors.black,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 4,
                      child: Text(
                        'Approve Hours',
                        style: TextStyle(
                          color: _selectedIndex == 4 ? const Color(0xFFFF8600) : Colors.black,
                        ),
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.menu, color: Colors.white),
                ),
              ]
            : [
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: Text(
                      'Admin Home',
                      style: TextStyle(
                        color: _selectedIndex == 0 ? const Color(0xFFFF8600) : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    child: Text(
                      'View User Data',
                      style: TextStyle(
                        color: _selectedIndex == 1 ? const Color(0xFFFF8600) : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                    child: Text(
                      'Edit User Status',
                      style: TextStyle(
                        color: _selectedIndex == 2 ? const Color(0xFFFF8600) : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                    child: Text(
                      'Approve Activities',
                      style: TextStyle(
                        color: _selectedIndex == 3 ? const Color(0xFFFF8600) : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 4;
                      });
                    },
                    child: Text(
                      'Approve Hours',
                      style: TextStyle(
                        color: _selectedIndex == 4 ? const Color(0xFFFF8600) : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
      ),
      body: _getPage(),
    );
  }
}