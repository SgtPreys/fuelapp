import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/station.dart';

class StationForm extends StatefulWidget {
  final Station? existingStation; // NEW: Accepts an existing station

  const StationForm({super.key, this.existingStation});

  @override
  State<StationForm> createState() => _StationFormState();
}

class _StationFormState extends State<StationForm> {
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
  void initState() {
    super.initState();
    // NEW: Pre-fill data if editing
    if (widget.existingStation != null) {
      _nameController.text = widget.existingStation!.name;
      _locationController.text = widget.existingStation!.location ?? '';
      _selectedType = widget.existingStation!.type;
      _infoController.text = widget.existingStation!.additionalInfo ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _saveStation() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Station Name!')),
      );
      return;
    }

    final stationData = Station(
      id: widget.existingStation?.id, // Keep ID if editing
      name: _nameController.text,
      location: _locationController.text,
      type: _selectedType,
      additionalInfo: _infoController.text,
    );

    if (widget.existingStation == null) {
      await DatabaseHelper.instance.insertStation(stationData.toMap());
    } else {
      await DatabaseHelper.instance.updateStation(stationData.toMap());
    }

    if (mounted) {
      Navigator.pop(context, true); // Pass 'true' back to trigger refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingStation != null;

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
            Center(
              child: Text(
                isEditing ? 'Edit Gas Station' : 'Add Gas Station', 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
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
                onPressed: _saveStation,
                child: Text(isEditing ? 'Update Gas Station' : 'Save Gas Station'),
              ),
            ),
            
            // --- NEW: DELETE BUTTON ---
            if (isEditing) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () async {
                    // Tell the database to delete this ID
                    await DatabaseHelper.instance.deleteStation(widget.existingStation!.id!);
                    if (mounted) {
                      Navigator.pop(context, true); // Close form and trigger refresh
                    }
                  },
                  child: const Text('Delete Gas Station', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}