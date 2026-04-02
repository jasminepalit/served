import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final DateTime date;
  final String organization;
  final String advisorName;
  final String advisorEmail;
  final String advisorPhone;
  final String description;
  final bool isHighNeeds;
  final String? highNeedsDescription;

  Activity({
    required this.date,
    required this.organization,
    required this.advisorName,
    required this.advisorEmail,
    required this.advisorPhone,
    required this.description,
    required this.isHighNeeds,
    this.highNeedsDescription,
  });
}

class LogActivitiesPage extends StatefulWidget {
  const LogActivitiesPage({super.key});

  @override
  State<LogActivitiesPage> createState() => _LogActivitiesPageState();
}

class _LogActivitiesPageState extends State<LogActivitiesPage> {
  final _formKey = GlobalKey<FormState>();
  final _organizationController = TextEditingController();
  final _advisorNameController = TextEditingController();
  final _advisorEmailController = TextEditingController();
  final _advisorPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _highNeedsDescriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _isHighNeeds = false;
  final List<Activity> _activities = [];

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

  Future<void> _submitActivity() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final activity = Activity(
        date: _selectedDate!,
        organization: _organizationController.text.trim(),
        advisorName: _advisorNameController.text.trim(),
        advisorEmail: _advisorEmailController.text.trim(),
        advisorPhone: _advisorPhoneController.text.trim(),
        description: _descriptionController.text.trim(),
        isHighNeeds: _isHighNeeds,
        highNeedsDescription: _isHighNeeds
            ? _highNeedsDescriptionController.text.trim()
            : null,
      );

      // Save to Firestore
      try {
        await FirebaseFirestore.instance.collection('activities').add({
          'date': activity.date,
          'organization': activity.organization,
          'advisorName': activity.advisorName,
          'advisorEmail': activity.advisorEmail,
          'advisorPhone': activity.advisorPhone,
          'description': activity.description,
          'isHighNeeds': activity.isHighNeeds,
          'highNeedsDescription': activity.highNeedsDescription,
        });
        setState(() {
          _activities.add(activity);
        });
        // Clear form
        _organizationController.clear();
        _advisorNameController.clear();
        _advisorEmailController.clear();
        _advisorPhoneController.clear();
        _descriptionController.clear();
        _highNeedsDescriptionController.clear();
        setState(() {
          _selectedDate = null;
          _isHighNeeds = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity logged successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to log activity: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Date Picker
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No date selected'
                            : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                      ),
                    ),
                    TextButton(
                      onPressed: _pickDate,
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Organization
                TextFormField(
                  controller: _organizationController,
                  decoration: const InputDecoration(
                    labelText: 'Organization Name',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter organization name' : null,
                ),
                // Advisor Name
                TextFormField(
                  controller: _advisorNameController,
                  decoration: const InputDecoration(labelText: 'Advisor Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter advisor name' : null,
                ),
                // Advisor Email
                TextFormField(
                  controller: _advisorEmailController,
                  decoration: const InputDecoration(labelText: 'Advisor Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter advisor email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                      return 'Please enter a valid email';
                    return null;
                  },
                ),
                // Advisor Phone
                TextFormField(
                  controller: _advisorPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Advisor Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty
                      ? 'Please enter advisor phone number'
                      : null,
                ),
                // General Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'General Description',
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a description' : null,
                ),
                // High Needs Checkbox
                CheckboxListTile(
                  title: const Text('High Needs'),
                  value: _isHighNeeds,
                  onChanged: (value) => setState(() => _isHighNeeds = value!),
                ),
                // High Needs Description (conditional)
                if (_isHighNeeds)
                  TextFormField(
                    controller: _highNeedsDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'High Needs Description',
                    ),
                    maxLines: 2,
                    validator: (value) => value!.isEmpty
                        ? 'Please enter high needs description'
                        : null,
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitActivity,
                  child: const Text('Submit Activity'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Activities Table
          if (_activities.isNotEmpty)
            DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Organization')),
                DataColumn(label: Text('Advisor')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('High Needs')),
              ],
              rows: _activities.map((activity) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(activity.date.toLocal().toString().split(' ')[0]),
                    ),
                    DataCell(Text(activity.organization)),
                    DataCell(Text(activity.advisorName)),
                    DataCell(Text(activity.description)),
                    DataCell(Text(activity.isHighNeeds ? 'Yes' : 'No')),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
