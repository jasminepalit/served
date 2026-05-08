/**
 * AdminUserDataView.dart - This file defines the AdminUserDataView widget, which is a screen that displays a specific user's volunteer hours in a DataTable format. It fetches the user's first and last name to display in the AppBar title and lists all their volunteer entries with place, hours, and date. The data is retrieved from Firestore and updates in real-time as changes occur.
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'VolunteerFormPage.dart';
import 'auth_helpers.dart';
/**
 * AdminUserDataView is a screen that displays a specific user's volunteer hours in a DataTable format. It fetches the user's first and last name to display in the AppBar title and lists all their volunteer entries with place, hours, and date. The data is retrieved from Firestore and updates in real-time as changes occur.
 */
class AdminUserDataView extends StatefulWidget {
  const AdminUserDataView({super.key, required this.uid});
  final String uid;
  /**
   * Creates the state for AdminUserDataView, which manages the loading of user data and the display of volunteer hours in a DataTable. It initializes futures to load the user's first and last name and combines them for display in the AppBar title. The build method constructs the UI, including a StreamBuilder to listen for real-time updates to the user's volunteer hours from Firestore.
   */
  @override
  State<AdminUserDataView> createState() => _AdminUserDataViewState();
}
/**
 * _AdminUserDataViewState is the state class for AdminUserDataView. It initializes futures to load the user's first and last name from Firestore and combines them for display in the AppBar title. The build method constructs the UI, including a StreamBuilder that listens for real-time updates to the user's volunteer hours from Firestore. It displays the data in a DataTable format, showing the place, hours, and date of each volunteer entry. If there are no entries, it shows a message indicating that there are no entries yet.
 */
class _AdminUserDataViewState extends State<AdminUserDataView> {
  final _firestore = FirebaseFirestore.instance;
  late final Future<String> firstNameFuture;
  late final Future<String> lastNameFuture;
  late final Future<String> nameFuture;
  /**
   * Initializes the state by loading the user's first and last name from Firestore using the provided UID. It sets up futures for both the first and last name, and then combines them into a single future that will be used to display the user's full name in the AppBar title. This allows the UI to show a loading state while fetching the data and then update once the names are retrieved.
   */
  @override
  void initState() {
    super.initState();
    firstNameFuture = loadFirstNameSpecific(widget.uid);
    lastNameFuture = loadLastNameSpecific(widget.uid);
    nameFuture = Future.wait([firstNameFuture, lastNameFuture]).then((values) => '${values[0]} ${values[1]}');
  }
  /**
   * Builds the UI for the AdminUserDataView screen. It checks if there is an authenticated user and displays a message if not. If there is a user, it constructs a Scaffold with an AppBar that shows the user's full name (loaded from Firestore) and a body that contains a StreamBuilder. The StreamBuilder listens to the 'Hours' collection for the specific user and displays the volunteer entries in a DataTable format. Each entry shows the place, hours, and date of volunteering. If there are no entries, it shows a message indicating that there are no entries yet.
   */
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = FutureBuilder<String>(
      future: nameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }
        return Text(snapshot.data ?? 'No One');
      },
    );

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No authenticated user.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: nameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            return Text(snapshot.data ?? 'No One');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
    
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('Users')
                    .doc(widget.uid)
                    .collection('Hours')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No entries yet.'));

                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: DataTable(
                                  border: TableBorder(
                                    horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
                                  ),
                                  columnSpacing: 40,
                                  horizontalMargin: 24,
                                  headingRowHeight: 56,
                                  dataRowHeight: 52,
                                  headingTextStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  headingRowColor: MaterialStateProperty.resolveWith(
                                    (states) => Theme.of(context).colorScheme.primary.withOpacity(0.95),
                                  ),
                                  dataRowColor: MaterialStateProperty.resolveWith((states) {
                                    if (states.contains(MaterialState.selected)) {
                                      return Theme.of(context).colorScheme.primary.withOpacity(0.12);
                                    }
                                    return Colors.white;
                                  }),
                                  columns: const [
                                    DataColumn(label: Text('Place')),
                                    DataColumn(label: Text('Hours')),
                                    DataColumn(label: Text('Date')),
                                  ],
                                  rows: docs.map((doc) {
                                    final data = doc.data()! as Map<String, dynamic>;
                                    final timestamp = data['date'] as Timestamp?;
                                    final dateStr = timestamp != null ? timestamp.toDate().toLocal().toString().split(' ')[0] : '';
                                    return DataRow(cells: [
                                      DataCell(Text(data['place'] ?? '')),
                                      DataCell(Text(data['hours']?.toString() ?? '')),
                                      DataCell(Text(dateStr)),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
