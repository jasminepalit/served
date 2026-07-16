import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:served/footer_bar.dart';
import 'package:served/AdminUserDataView.dart';
import 'package:served/AdminDeleteAccounts.dart';

class AdminWipePanel extends StatefulWidget {
  const AdminWipePanel({super.key});

  @override
  State<AdminWipePanel> createState() => _AdminWipePanelState();
}

class _AdminWipePanelState extends State<AdminWipePanel> {
  final TextEditingController _yogController = TextEditingController();
  bool _isLoading = false;

  // 1. Core execution method that communicates with your Python Cloud Function
  Future<void> _executeBackendWipe(int targetYear) async {
    setState(() => _isLoading = true);

    try {
      final FirebaseFunctions functions = FirebaseFunctions.instanceFor(
        region: 'us-east1',
      );
      final HttpsCallable callable = functions.httpsCallable(
        'delete_users_by_yog_callable',
      );

      final HttpsCallableResult result = await callable.call({
        'yearOfGraduation': targetYear,
        'yog': targetYear,
      });

      final data = result.data as Map;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Action completed.'),
          backgroundColor: Colors.green,
        ),
      );

      _yogController.clear();
    } on FirebaseFunctionsException catch (e) {
      final details = e.details;
      final messageParts = <String>[
        e.message ?? 'Unknown Firebase Functions error',
        if (details != null && details.toString().isNotEmpty)
          details.toString(),
      ];
      final fullMessage = messageParts.join(' - ');
      print('Cloud function error: $fullMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(fullMessage), backgroundColor: Colors.red),
      );
    } catch (e, stackTrace) {
      print('Unexpected wipe error: $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. Structural Warning Dialog UI Window
  void _showConfirmationDialog() {
    final String targetYearStr = _yogController.text.trim();
    if (targetYearStr.isEmpty) return;

    final int? targetYear = int.tryParse(targetYearStr);
    if (targetYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid numeric year.')),
      );
      return;
    }

    final TextEditingController _verifyController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside the box
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text('DANGER: Permanent Wipe'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will permanently delete ALL users graduating in $targetYearStr forever. There will be no way to restore account data.',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              const Text(
                'This action cannot be undone. To proceed, type the year below to confirm:',
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _verifyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Type $targetYearStr again',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Safely aborts action
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Only execute if input match patterns verify successfully
                if (_verifyController.text.trim() == targetYearStr) {
                  Navigator.pop(context); // Close the dialog box
                  _executeBackendWipe(targetYear); // Fire backend task loop
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDeleteAccounts(),
                    ),
                  ); // Return to previous screen after execution
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Confirmation year mismatch. Aborted.'),
                    ),
                  );
                }
              },
              child: const Text(
                'PROCEED WITH DELETION',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FooterBar(),
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _yogController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Target YOG Year',
                hintText: 'e.g., 2024',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _showConfirmationDialog, // Trigger verification layer
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Wipe All Users in YOG',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
