import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'MainScreen.dart';
import 'package:signature/signature.dart';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:signature/signature.dart';
import 'package:firebase_storage/firebase_storage.dart';

const Color kPrimaryColor = Color(0xFF5128B5);
const Color kSecondaryColor = Color(0xFF758BFD);
const Color kAccentColor = Color(0xFFAEB8FE);
const Color kBackgroundColor = Color(0xFFF2F1F6);
const Color kAccentOrange = Color(0xFFFF8600);

class VolunteerFormPage extends StatefulWidget {
  final VoidCallback? onSuccess;
  const VolunteerFormPage({super.key, this.onSuccess});

  @override
  State<VolunteerFormPage> createState() => _VolunteerFormPageState();
}

class _VolunteerFormPageState extends State<VolunteerFormPage> {
  String _selectedPlace = '';
  final _hoursController = TextEditingController();
  DateTime? _selectedDate;

  final _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  void _resetForm() {
    _selectedPlace = '';
    _hoursController.clear();
    _controller.clear();
    setState(() {
      _selectedDate = null;
    });
  }

  Future<void> _addEntry() async {
    print('Adding entry...');
    final place = _selectedPlace;
    final hours = double.tryParse(_hoursController.text.trim());
    final date = _selectedDate;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (place.isEmpty || hours == null || date == null || _controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out place, hours, date, and signature.'),
        ),
      );
      return;
    }

    print('Getting signature...');
    final signatureUrl = await exportImage(context);

    await _firestore.collection('Users').doc(user.uid).collection('Hours').add({
      'place': place,
      'hours': hours,
      'date': Timestamp.fromDate(date),
      'status': 'pending',
      'signatureUrl': signatureUrl,
    });

    if (!context.mounted) return;

    _resetForm();
    widget.onSuccess?.call();

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    strokeCap: StrokeCap.butt,
    strokeJoin: StrokeJoin.miter,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
    onDrawStart: () => log('onDrawStart called!'),
    onDrawEnd: () => log('onDrawEnd called!'),
  );

  @override
  void initState() {
    super.initState();
    _controller
      ..addListener(() => log('Value changed'))
      ..onDrawEnd = () => setState(() {
        // setState for build to update value of "empty label" in gui
      });
  }

  @override
  void dispose() {
    // IMPORTANT to dispose of the controller
    _controller.dispose();
    super.dispose();
  }

  Future<String?> exportImage(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(key: Key('snackbarPNG'), content: Text('No content')),
      );
      return null;
    }

    final Uint8List? data = await _controller.toPngBytes(
      height: 300,
      width: 300,
    );
    if (data == null) {
      return null;
    }
    try {
      // 3. Create a unique filename using timestamp
      final String fileName =
          'signatures/${DateTime.now().millisecondsSinceEpoch}.png';

      // 4. Reference Firebase Storage and upload using putData
      final Reference storageRef = FirebaseStorage.instance.ref().child(
        fileName,
      );

      // Metadata is recommended to let browsers/apps view it properly
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/png',
      );

      final UploadTask uploadTask = storageRef.putData(data, metadata);

      // 5. Wait for the upload task to finish
      final TaskSnapshot snapshot = await uploadTask;

      // 6. Optional: Grab the download URL if you need to save it to Firestore
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hours uploaded successfully!'), backgroundColor: Colors.green),
      );

      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading hours: $e'), backgroundColor: Colors.red));
      return null;
    }
  }

  Future<void> exportSVG(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(key: Key('snackbarSVG'), content: Text('No content')),
      );
      return;
    }
    String? rawSVGoptimized = _controller.toRawSVG();
    String? rawSVGnonoptimized = _controller.toRawSVG(
      minDistanceBetweenPoints: 0,
    );
    debugPrint('Raw svg without optimalizations: ');

    debugPrint("----");
    debugPrint('size is: ${rawSVGnonoptimized?.length ?? 0} chars long');
    debugPrint('Raw svg with optimalizations: ');

    debugPrint("----");
    debugPrint('size is: ${rawSVGoptimized?.length ?? 0} chars long');

    final SvgPicture data = _controller.toSVG()!;

    if (!mounted) return;
  }

  void _navigateBackToHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Hours'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBackToHome,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
           
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 2),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('Activities')
                          .where('status', isEqualTo: 'approved')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final activities = snapshot.data!.docs;
                        final organizations = activities
                            .map((doc) => doc['organization'] as String)
                            .toSet()
                            .toList();
                        return DropdownButtonFormField<String>(
                          value: _selectedPlace.isEmpty ? null : _selectedPlace,
                          decoration: const InputDecoration(labelText: 'Place'),
                          items: organizations.map((org) {
                            return DropdownMenuItem<String>(
                              value: org,
                              child: Text(org),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlace = value ?? '';
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Hours'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'No date selected'
                                : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSecondaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _pickDate,
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                                            const SizedBox(height: 16),

                    Signature(
                      controller: _controller,
                      width: 300,
                      height: 300,
                      backgroundColor: Colors.white,
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _addEntry,
                      child: const Text('Save Hours'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _navigateBackToHome,
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}