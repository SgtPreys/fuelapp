import 'package:flutter/material.dart';

class StationForm extends StatefulWidget {
  const StationForm({super.key});

  @override
  State<StationForm> createState() => _StationFormState();
}

class _StationFormState extends State<StationForm> {
  // Standardized list of gas station types
  final List<String> _typeOptions = [
    'Standard / City', 
    'Highway / Autobahn', 
    'Supermarket', 
    'Unmanned / Automatic',
    'Other'
  ];

  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('Add Gas Station', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            // 1. Name
            const TextField(
              decoration: InputDecoration(labelText: 'Name (e.g. Shell, Aral)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            // 2. Location
            const TextField(
              decoration: InputDecoration(labelText: 'Location / City', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            // 3. Type Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              initialValue: _selectedType,
              items: _typeOptions.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue;
                });
              },
            ),
            const SizedBox(height: 10),

            // 4. Additional Information
            const TextField(
              decoration: InputDecoration(labelText: 'Additional Information / Notes', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // We'll add the saving logic here later!
                  Navigator.pop(context);
                },
                child: const Text('Save Gas Station'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}