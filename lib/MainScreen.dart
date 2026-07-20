import 'package:flutter/material.dart';
import 'package:served/footer_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart';
import 'HomePage.dart';
import 'VolunteerFormPage.dart';
import 'ActivityFormPage.dart';
import 'StudentActivityPage.dart';
import 'main.dart';
import 'auth_helpers.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _selectedLogOption = 'Log Hours';

  Widget _getPage() {
    if (_selectedIndex == 0) return HomePage(title: "Home");
    if (_selectedIndex == 2)
      return const StudentActivityPage(showFooter: false);
    return _getLogPage();
  }

  Widget _getLogPage() {
    if (_selectedLogOption == 'Log Hours') {
      return VolunteerFormPage(
        onSuccess: () => setState(() => _selectedIndex = 0),
      );
    } else {
      return ActivityFormPage(
        onSuccess: () => setState(() => _selectedIndex = 0),
      );
    }
  }

  String userType = 'user';
  String firstName = 'Loading...';
  String lastName = 'Loading...';

  @override
  void initState() {
    super.initState();
    print("Mainscreen");
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
          children: [Image.asset('lib/images/servd.png', height: 40)],
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
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
                      if (value == 99) {
                        // Log menu
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Select an option'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('Log Hours'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _selectedIndex = 1;
                                      _selectedLogOption = 'Log Hours';
                                    });
                                  },
                                ),
                                ListTile(
                                  title: const Text('Add Activity'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _selectedIndex = 1;
                                      _selectedLogOption = 'Add Activity';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        _selectedIndex = value;
                      }
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 0,
                      child: Text('Home'),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Text('Activities'),
                    ),
                    const PopupMenuItem(
                      value: 99,
                      child: Text('Log'),
                    ),
                  ],
                  icon: const Icon(Icons.menu, color: Colors.white),
                ),
              ]
            : [
                Flexible(
                  child: TextButton(
                    onPressed: () => setState(() => _selectedIndex = 0),
                    child: const Text('Home', 
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Flexible(
                  child: TextButton(
                    onPressed: () => setState(() => _selectedIndex = 2),
                    child: const Text(
                      'Activities',
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Flexible(
                  child: PopupMenuButton<String>(
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
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Log', 
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
      ),
      body: _getPage(),
    );
  }
}