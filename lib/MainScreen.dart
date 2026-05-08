/**
 * MainScreen.dart is the main screen of the app that users see after logging in. It contains a bottom navigation bar with three options: Home, Log, and Activities. The Home page shows a welcome message and some basic information about the user. The Log page allows users to log their volunteer hours or add new activities. The Activities page displays a list of all the activities that the user has participated in. The MainScreen also includes a logout button in the app bar that allows users to sign out of their account.
 */
import 'package:flutter/material.dart';
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
/**
 * MainScreen is a StatefulWidget that manages the state of the main screen of the app. It uses a bottom navigation bar to switch between different pages (Home, Log, Activities) and a popup menu to select between logging hours or adding an activity. The MainScreen also handles user authentication and allows users to log out of their account. The state of the selected page and log option is managed using setState to update the UI accordingly.
 */
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}
/**
 * _MainScreenState is the state class for MainScreen that manages the selected page and log option. It uses a method _getPage to determine which page to display based on the selected index and log option. The initState method is used to perform any necessary initialization when the state is created. The build method constructs the UI of the main screen, including the app bar with navigation options and the body that displays the selected page.
 */
class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _selectedLogOption = 'Log Hours';
/**
 * The _getPage method returns the appropriate page widget based on the selected index and log option. If the selected index is 0, it returns the HomePage widget. If the selected index is 2, it returns the StudentActivityPage widget. For any other selected index (which would be 1 in this case), it calls the _getLogPage method to determine whether to show the VolunteerFormPage or the ActivityFormPage based on the selected log option. This method is used in the build method to display the correct page in the body of the Scaffold.
 */
  Widget _getPage() {
    if (_selectedIndex == 0) return HomePage(title: "Home",);
    if (_selectedIndex == 2) return const StudentActivityPage();
    return _getLogPage();
  }
/**
 * The _getLogPage method returns the appropriate log page widget based on the selected log option. If the selected log option is 'Log Hours', it returns the VolunteerFormPage widget, which allows users to log their volunteer hours. If the selected log option is 'Add Activity', it returns the ActivityFormPage widget, which allows users to add new activities. Both widgets have an onSuccess callback that sets the selected index back to 0 (Home) when the form submission is successful. This method is called by the _getPage method when the selected index is 1 (Log) to determine which log page to display.
 */
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
  /**
   * The initState method is called when the state of the MainScreen is created. It initializes the state by calling the super.initState() method and then prints "Mainscreen" to the console. This method can be used to perform any necessary setup or initialization tasks when the MainScreen is first displayed, such as fetching user data or setting up listeners.
   */
  @override
  void initState() {
    super.initState();
    print("Mainscreen");
  }
/**
 * The build method constructs the UI of the MainScreen. It returns a Scaffold widget that contains an AppBar and a body. The AppBar includes a title with an image, a logout button that signs the user out and navigates back to the LoginPage, and navigation options for Home, Log, and Activities. The body of the Scaffold displays the page returned by the _getPage method, which is determined based on the selected index and log option. The navigation options in the AppBar allow users to switch between different pages of the app, while the logout button provides a way for users to sign out of their account.
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
          
          ],
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
              return LoginPage();}), (route) => false,);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _selectedIndex = 0),
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedIndex = 2),
            child: const Text('Activities', style: TextStyle(color: Colors.white)),
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

  


