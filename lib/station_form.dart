import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/station.dart';

class StationForm extends StatefulWidget {
  const StationForm({super.key});

  @override
  State<StationForm> createState() => _StationFormState();
}

class _StationFormState extends State<StationForm> {
  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();

  final List<String> _typeOptions = [
    'Standard / City', 
    'Highway / Autobahn', 
    'Supermarket', 
    'Unmanned / Automatic',
    'Other'
  ];

  String? _selectedType;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  // --- Save Logic ---
  Future<void> _saveStation() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Station Name!')),
      );
      return;
    }

    final newStation = Station(
      name: _nameController.text,
      location: _locationController.text,
      type: _selectedType,
      additionalInfo: _infoController.text,
    );

    await DatabaseHelper.instance.insertStation(newStation.toMap());

    if (mounted) {
      Navigator.pop(context);
    }
  }

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

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name (e.g. Shell, Aral)*', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location / City', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              initialValue: _selectedType,
              items: _typeOptions.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedType = newValue),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _infoController,
              decoration: const InputDecoration(labelText: 'Additional Information / Notes', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _saveStation, // Calls our save function!
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