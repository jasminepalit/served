# served

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


**Instructions:**

**Download Flutter**
  Open up VS Code as the editor
  Install the flutter SDK in the marketplace page
**Download Firebase**
  Install Node.js
    [Node.js — Download Node.js®](https://nodejs.org/en/download)
  In the firebase terminal for Bash
    npm install -g firebase-tools
    firebase login
  Run 
    dart pub global activate flutterfire_cli
  Make sure this is in you PATH (in edit environment variable on computer)
    C:\Users\YOUR_USERNAME\AppData\Local\Pub\Cache\bin
  Run
    Flutterfire configure
  Run
    flutter pub add firebase_core
    flutter pub add firebase_auth
    flutter pub add cloud_firestore
  To run the app type a. In the bash terminal
    Flutter run

**Citations**
Firebase and related tools were made with the help of https://firebase.google.com/docs/ 
Flutter widget and tools were done with the help of https://docs.flutter.dev/
To work with different types of widgets: https://www.geeksforgeeks.org/flutter/flutter-stateful-vs-stateless-widgets/
To help with displaying data searching: https://www.youtube.com/watch?v=ClR8OxekmhE, https://medium.flutterdevs.com/datatable-in-flutter-9242b4a19e67
To read and write data to the firebase database: https://firebase.google.com/docs/database/flutter/read-and-write 
To authenticate users: https://firebase.google.com/docs/auth/flutter/start 
To get our color scheme: https://coolors.co/ 
To help with navbar creation: https://api.flutter.dev/flutter/material/NavigationBar-class.html 
To initially start our project: https://codelabs.developers.google.com/codelabs/flutter-codelab-first#3 
To help set up dependencies: https://firebase.google.com/docs/flutter/setup


This app was made with the help of CoPilot:

Prompt: How do I make a data table in flutter with my firebase data base

Response:
Connecting Flutter to Firebase for a data table is a classic move. To get this working, you’ll essentially be building a bridge between a **Stream** (from Firestore) and a **DataTable** widget.

Because Firestore data is asynchronous, the best practice is to wrap your table in a `StreamBuilder`. This ensures that whenever your database updates, your table reflects those changes in real-time.

### 1. The Basic Architecture

The flow looks like this:

1. **Firestore Request:** Ask for a specific collection.
2. **StreamBuilder:** Listen for changes.
3. **Data Mapping:** Convert the Firestore documents into `DataRow` objects.
4. **DataTable:** Render those rows into a clean UI.

---

### 2. Implementation Example

Here is a streamlined way to fetch a collection (let’s call it "users") and display it.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inventory Database")),
      body: StreamBuilder<QuerySnapshot>(
        // 1. Point to your collection
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Something went wrong');
          if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();

          // 2. Build the table
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Allows horizontal scrolling for wide tables
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Age')),
                DataColumn(label: Text('Role')),
              ],
              // 3. Map the Firestore documents to DataRows
              rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                return DataRow(
                  cells: [
                    DataCell(Text(data['name'] ?? '')),
                    DataCell(Text(data['age']?.toString() ?? '')),
                    DataCell(Text(data['role'] ?? '')),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

```

---

### 3. Key Tips for a Better Table

* **Handling Nulls:** Firestore fields can sometimes be missing. Always use the null-coalescing operator (`??`) to provide a fallback string so your app doesn't crash on a null value.
* **Performance:** If you have hundreds of rows, `DataTable` can become sluggish because it renders everything at once. For massive datasets, consider using the **`PaginatedDataTable`** widget or a package like `syncfusion_flutter_datagrid`.
* **Scrolling:** Standard `DataTable` widgets don't scroll horizontally by default. Wrapping it in a `SingleChildScrollView` with `scrollDirection: Axis.horizontal` is a lifesaver for mobile screens.

### 4. Common Pitfalls

* **Permissions:** If your table is empty but you know there's data, check your **Firestore Rules**. By default, they often deny all reads.
* **Data Types:** Remember that Firestore numbers often come back as `int` or `double`. Always call `.toString()` when passing them into a `Text()` widget inside a `DataCell`.

Would you like to see how to add **Sorting** or **Editing** capabilities to these rows?

Prompt: How do I setup a navbar with an image

Response: 
Setting up a navbar (an `AppBar` in Flutter terms) with an image is straightforward, but there are two distinct ways to do it depending on where you want the image: as a **Logo** next to the title, or as a **Background** behind the entire bar.

### Option 1: The Image as a Logo

This is the most common approach. You use the `title` or `leading` property. Using a `Row` in the title gives you the most control over spacing.

```dart
AppBar(
  backgroundColor: Colors.white,
  title: Row(
    children: [
      Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
        height: 32, // Control the size of your logo
      ),
      const SizedBox(width: 10), // Space between logo and text
      const Text("My App", style: TextStyle(color: Colors.black)),
    ],
  ),
)

```

---

### Option 2: The Image as a Background

If you want a photographic or gradient background for the navbar, you use the `flexibleSpace` property. This allows the image to sit behind the title and icons.

```dart
AppBar(
  title: const Text("Profile"),
  flexibleSpace: Image(
    image: AssetImage('assets/background.jpg'),
    fit: BoxFit.cover,
  ),
  backgroundColor: Colors.transparent, // Make the bar transparent to see the image
  elevation: 0, // Optional: removes the shadow
)

```

---

### 3. Key Implementation Details

| Feature | Property to Use | Best For |
| --- | --- | --- |
| **Leading Icon** | `leading` | Small profile pics or menu icons on the far left. |
| **Logo & Text** | `title` (using `Row`) | Branding and app identification. |
| **Full Background** | `flexibleSpace` | Stylized headers or "Hero" style designs. |

### Important Checklist:

1. **The `pubspec.yaml`:** Ensure your image is declared in your assets folder, or Flutter won't find it.
```yaml
assets:
  - assets/logo.png

```


2. **Image Sizing:** `AppBar` has a fixed default height (**56.0 pixels**). If your image is too tall, it will either get clipped or stretch the bar awkwardly. Always provide a `height` constraint to your `Image` widget.
3. **Contrast:** If you use a background image, ensure your `title` text color has enough contrast to be readable (e.g., white text on a dark image).

Are you looking to use a local asset file, or are you trying to pull a user's profile picture from a URL?

Prompt: How do I access other user's databases if I have their uid and all users are under a general Users collection

Response:
To access another user's data in Firestore, you simply need to point your `DocumentReference` or `CollectionReference` to the path containing that specific UID.

In Firestore, the UID acts as the **Document ID** within your `Users` collection. Accessing it is a matter of constructing the correct string path.

### 1. The Path Structure

If your database is structured like this:
`Users (Collection) -> {uid} (Document) -> profile_data (Fields/Subcollections)`

You can access a specific user's document using the following code:

```dart
// Replace 'target_user_uid' with the actual UID string you have
DocumentSnapshot userDoc = await FirebaseFirestore.instance
    .collection('Users')
    .doc('target_user_uid') 
    .get();

if (userDoc.exists) {
  print(userDoc.data());
}

```

---

### 2. Implementation in a Data Table

Since you were previously working on a `DataTable`, here is how you would fetch a specific user’s sub-collection (like "orders" or "posts") if you have their UID:

```dart
StreamBuilder<QuerySnapshot>(
  // Accessing a subcollection under a specific user
  stream: FirebaseFirestore.instance
      .collection('Users')
      .doc(targetUid) 
      .collection('orders')
      .snapshots(),
  builder: (context, snapshot) {
    // ... build your DataRows here ...
  },
)

```

---

### 3. The "Security Rules" Hurdle (Crucial)

This is where most developers get stuck. By default, many Firebase security rules are set to `allow read: if request.auth.uid == userId;`. This prevents users from snooping on each other.

If you want User A to be able to see User B's data, you must update your **Firestore Rules** in the Firebase Console:

**To allow any logged-in user to read any other user's profile:**

```javascript
service cloud.firestore {
  match /databases/{database}/documents {
    match /Users/{userId} {
      // Allow any authenticated user to read, but only the owner to write
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}

```

---

### 4. Best Practices for "Public" vs "Private" Data

If you have sensitive data (like phone numbers or addresses) mixed with public data (like usernames), don't put them in the same document.

* **Public Info:** Store in a `Users/{uid}` document with open read rules.
* **Private Info:** Store in a `Users/{uid}/private/settings` sub-collection with strict `request.auth.uid == userId` rules.

**Quick Tip:** If you are passing UIDs between screens in Flutter, make sure you are passing them through the constructor of your Widget to keep your code clean and reactive!

Are you planning to let users search for these UIDs, or are they being pulled from a list of friends/connections?

Prompt: How do I force my page to wait until the data has loaded in from firebase before displaying default values (ex. their name that is stored in the database and appears on the homepage)?

Response:
To prevent that "flicker" where the app shows "Loading..." or a default name like "Guest" before snapping to the actual data, you need to manage the **Widget Lifecycle**.

In Flutter, the most elegant way to "force" a wait is to use a **`FutureBuilder`** or **`StreamBuilder`**. These widgets are designed specifically to switch between a "Loading State" and a "Data State."

### 1. Using a `FutureBuilder`

If you only need to fetch the name once when the page loads, a `FutureBuilder` is the cleanest approach. It holds the UI in a loading state until the asynchronous Firebase call completes.

```dart
class HomePage extends StatelessWidget {
  final String uid;
  HomePage({required this.uid});

  // This function fetches the data once
  Future<DocumentSnapshot> getUserData() {
    return FirebaseFirestore.instance.collection('Users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: getUserData(),
        builder: (context, snapshot) {
          // 1. Check if the connection is still active
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Handle errors
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Error loading profile"));
          }

          // 3. Data is finally here!
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String name = userData['name'] ?? 'No Name';

          return Center(
            child: Text("Welcome back, $name!", style: TextStyle(fontSize: 24)),
          );
        },
      ),
    );
  }
}

```

---

### 2. Why this works better than "Default Values"

When you use the logic above, you are essentially telling Flutter:

* **Wait State:** If the data hasn't arrived (`ConnectionState.waiting`), show a spinner or a blank splash screen.
* **Ready State:** Only once `snapshot.hasData` is true, render the actual `Text` widget with the username.

This eliminates the "jumpy" UI where a label changes from "Guest" to "John" after half a second.

---

### 3. Pro-Tip: The "Skeleton" Screen

If you don't like `CircularProgressIndicator`, you can create a "Skeleton" or "Shimmer" effect. Instead of returning a loading spinner in the `waiting` block, you return a grey box that looks like the text that is about to appear.

### 4. Handling Global Data (The "Once and Done" approach)

If you need the user's name on **multiple pages**, you shouldn't fetch it over and over. You should fetch it once at the start of your app (e.g., in your `main.dart` or a `Wrapper` widget) and provide it to the rest of the app using a State Management tool like **Provider** or **Riverpod**.

1. **Splash Screen:** Show your logo while the data fetches.
2. **Navigation:** Only navigate to the `HomePage` once the data object is fully populated.

### 5. Quick Troubleshooting

* **Blank Screen:** If you get a blank screen, ensure your `uid` isn't null. Log the `uid` to the console before the Firebase call.
* **Type Errors:** If your app crashes with `Expected a type 'Map<String, dynamic>', but got...`, make sure you are casting the data correctly using `snapshot.data!.data() as Map<String, dynamic>`.

Does your homepage have a lot of other components, or is the user's name the main thing you're waiting for?

-This app was made with the help of Claude.ai-

### 1 help with trouble shooting of page loading indefinitely

Prompt: Why is it that when I access this page it is just loading and how do I fix it

Response: 
Looking at your code, the infinite loading is almost certainly caused by the collectionGroup query in AdminActivityApprovalPage. Here are the likely culprits:

1. Missing Firestore Index (Most Common Cause)
A collectionGroup query with a where filter requires a composite index in Firestore. Without it, the query silently hangs.

Fix: Check your Flutter debug console — Firestore usually prints a direct link to create the missing index. Click it, wait ~1 minute for it to build, then retry.

You can also manually create it in the Firebase Console under Firestore → Indexes → Composite:

Collection group: Activities
Field: status (Ascending)
Query scope: Collection group
2. No Documents Match (Minor Issue)
If the index exists but there are no documents where status == 'pending', it won't load forever — but double-check your Firestore data actually has that exact string "pending" in the status field.

3. Security Rules Blocking the Query
Your Firestore rules may not allow collection group queries. Make sure your rules permit reading Activities across all user subcollections:

match /{path=**}/Activities/{activityId} {
  allow read: if request.auth != null && 
    get(/databases/$(database)/documents/Users/$(request.auth.uid)).data.role == 'admin';
}
4. Add Error Handling to the StreamBuilder
Right now your builder has no error state, so failures look like loading. Add this to help diagnose:

dart
builder: (context, snapshot) {
  if (snapshot.hasError) {
    return Center(child: Text('Error: ${snapshot.error}')); // Add this
  }
  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
  // ...
}
Start with #4 — it will immediately tell you if it's a permissions error vs. an index error vs. something else.

Prompt: Where in my code do I put part 4

Response:
In your AdminActivityApprovalPage, find this section in the StreamBuilder:
dartbuilder: (context, snapshot) {
  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
And replace it with:
dartbuilder: (context, snapshot) {
  if (snapshot.hasError) {
    return Center(child: Text('Error: ${snapshot.error}'));
  }
  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
Just one line added right before the existing if (!snapshot.hasData) check.

Prompt: Picture of the error

Response:
It's a permissions error. You need to update your Firestore Security Rules to allow collection group queries on Activities.
Go to Firebase Console → Firestore → Rules and add this rule:
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Your existing rules here...

    // Add this for the collection group query
    match /{path=**}/Activities/{activityId} {
      allow read, write: if request.auth != null;
    }
  }
}
If you want it restricted to admins only (recommended), use this instead:
match /{path=**}/Activities/{activityId} {
  allow read, write: if request.auth != null &&
    get(/databases/$(database)/documents/Users/$(request.auth.uid)).data.role == 'admin';
}
This second version checks that the logged-in user has role == 'admin' in their Users document. Make sure the field name matches exactly what you store in Firestore — if you use a different field like isAdmin: true, adjust accordingly.
After saving the rules, publish them and refresh your app. The error should be gone.

Prompt: Picture of error again

This is the missing index error. The fix is simple — click the link in the error message. It starts with https://console.firebase.google.com/v1/r/project/servd-4430e/firestore/indexes?create_exemption=...
That link will take you directly to Firebase Console with the index pre-configured. Just click "Create Index" and wait about 1-2 minutes for it to build.
Once it shows a green checkmark in the Firebase Console under Firestore → Indexes, refresh your app and it should work.
Click the "Manual" tab (top right, next to "Automatic")
Click "Create Index" (or the "+" button)
Fill in the fields:

Collection ID: Activities
Query scope: Collection group
Fields to index: status → Ascending


Click "Create"

Then wait 1-2 minutes for the status to show a green checkmark, and your app should work.

### 2: asking for help for making only approved activities show up in the activities drop down for hours approval

Prompt: in the activities dropdown, only make approved activities show up

Response: In your StreamBuilder query, just add a where filter for approved activities:
Find this:
dartstream: _firestore
    .collection('Users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('Activities')
    .snapshots(),
Replace with:
dartstream: _firestore
    .collection('Users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('Activities')
    .where('status', isEqualTo: 'approved')
    .snapshots(),
That's the only change needed

### 3: Spacing for activities page

Prompt: how do you make it so that the boxes with the info about the activity are evenly spaced from each other and not all on the left.

Response: Find this in your SingleChildScrollView:
dartpadding: const EdgeInsets.all(20),
child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
Replace with:
dartpadding: const EdgeInsets.all(20),
child: Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
That single change makes all the cards stretch to fill the full width evenly. The spacing between them is already consistent with your SizedBox(height: 24) gaps so everything should look balanced.

### 4: Adding stats on the admin home screen

Prompt: How do I add text in the third box from the left on the screen that says the number of different activities that the admin has approved.

Response: 
Find this in your build method:
dartRow(
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
Replace it with:
dartRow(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF93a1fd),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF93a1fd),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('Activities')
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF93a1fd),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Approved',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    ),
    Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF93a1fd),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  ],
),
This requires the collection group index for Activities on status that you already set up earlier, so it should work right away.

### 5: Showing an hour tracking bar for the student page

Prompt: How to create a bar at the top of the page that shows the total hours completed by the student, as the number of hours gets closer to 50, the bar will edge towards the end of the bar (fill up). if the person gets more than 50 hours, the bar will just remain full and not extend past the page.

Response: Find this in your build method:

dart
Text('Service Hours', style: Theme.of(context).textTheme.headlineSmall),
const SizedBox(height: 12),
Replace it with:

dart
Text('Service Hours', style: Theme.of(context).textTheme.headlineSmall),
const SizedBox(height: 12),
StreamBuilder<QuerySnapshot>(
  stream: _firestore
      .collection('Users')
      .doc(user.uid)
      .collection('Hours')
      .snapshots(),
  builder: (context, snapshot) {
    double totalHours = 0;
    if (snapshot.hasData) {
      for (final doc in snapshot.data!.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final h = data['hours'];
        if (h is num) totalHours += h.toDouble();
      }
    }
    final progress = (totalHours / 50).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${totalHours.toStringAsFixed(1)} / 50 hours',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(
              totalHours >= 50 ? '✓ Goal reached!' : '${(50 - totalHours).toStringAsFixed(1)} hrs to go',
              style: TextStyle(
                fontSize: 13,
                color: totalHours >= 50 ? Colors.green : Colors.grey,
                fontWeight: totalHours >= 50 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 14,
            backgroundColor: kAccentColor.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              totalHours >= 50 ? Colors.green : kPrimaryColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  },
),
This shows the total hours, a progress bar that fills toward 50, turns green and shows a checkmark when the goal is reached, and caps at full even if they exceed 50.

### 6: Issues with the nav bar not showing up on specific pages

Prompt: is there any code in this that causes the nav bar not to show up all the time
Response: Looking at your code, I don't see anything that would cause a nav bar to disappear — but that's actually the issue: there's no bottom navigation bar defined in this file at all.
This file only contains two pages (AdminActivityApprovalPage and ActivityApprovalDetailPage), and neither has a BottomNavigationBar or NavigationBar widget in their Scaffold.
The nav bar would need to come from a parent widget — typically a root/shell widget that wraps your routes. A few common reasons it disappears on these pages:
1. Navigator pushes a new route on top of the shell
If your app uses a root Scaffold with a bottom nav bar, and you use Navigator.push(...) (which this file does), the new page covers the entire screen including the nav bar. This is the most likely culprit — ActivityApprovalDetailPage is pushed via Navigator.push, so it renders without the parent shell's nav bar.
2. The fix — use a persistent shell router
If you want the nav bar to persist across pages, you'd typically switch to go_router with a ShellRoute, or restructure so that only the body content changes while the nav bar stays in a persistent parent Scaffold.
3. Quick check
Look at wherever your bottom nav bar lives (likely a MainPage or HomePage widget). If it pushes routes with Navigator.push, those pages will cover the nav bar. If it swaps an IndexedStack or body content instead, the nav bar persists.
Would you like help restructuring the navigation to keep the bar visible, or is the goal just to understand why it disappears on these specific pages?



