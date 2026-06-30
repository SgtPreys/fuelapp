import 'package:flutter/material.dart';

class MaintenanceForm extends StatefulWidget {
  const MaintenanceForm({super.key});

  @override
  State<MaintenanceForm> createState() => _MaintenanceFormState();
}

class _MaintenanceFormState extends State<MaintenanceForm> {
  // --- Temporary Dummy Data ---
  final List<String> _myCars = ['Daily Driver', 'Weekend Car'];
  final List<String> _companies = ['Local Mechanic', 'Tire Shop', 'Dealership', 'Other'];
  
  // NEW: Standardized list of maintenance occurrences
  final List<String> _occurrences = [
    'Oil Change', 
    'Tire Replacement / Alignment', 
    'Brake Service', 
    'Inspection', 
    'General Repair', 
    'Other'
  ];

  String? _selectedCar;
  String? _selectedCompany;
  String? _selectedOccurrence; // NEW: Variable to remember the selected occurrence

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
          children: [
            const Text('Add Maintenance Stop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // 1. Car Selection Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Car', border: OutlineInputBorder()),
              initialValue: _selectedCar,
              items: _myCars.map((String car) {
                return DropdownMenuItem<String>(value: car, child: Text(car));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCar = newValue;
                });
              },
            ),
            const SizedBox(height: 10),

            // 2. Company/Shop Selection Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Company/Shop', border: OutlineInputBorder()),
              initialValue: _selectedCompany,
              items: _companies.map((String company) {
                return DropdownMenuItem<String>(value: company, child: Text(company));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCompany = newValue;
                });
              },
            ),
            const SizedBox(height: 10),

            // 3. UPDATED: Occurrence Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Occurrence / Type of Service', border: OutlineInputBorder()),
              initialValue: _selectedOccurrence,
              items: _occurrences.map((String occurrence) {
                return DropdownMenuItem<String>(value: occurrence, child: Text(occurrence));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedOccurrence = newValue;
                });
              },
            ),
            const SizedBox(height: 10),

            // 4. Total Price
            const TextField(
              decoration: InputDecoration(labelText: 'Total Price', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            // 5. Additional Info 
            const TextField(
              decoration: InputDecoration(labelText: 'Additional Info / Notes', border: OutlineInputBorder()),
              maxLines: 3, 
            ),
            const SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: () {
                // We'll add the saving logic here later!
                Navigator.pop(context);
              },
              child: const Text('Save Entry'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}