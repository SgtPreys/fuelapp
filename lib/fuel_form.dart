import 'package:flutter/material.dart';

class FuelForm extends StatefulWidget {
  const FuelForm({super.key});

  @override
  State<FuelForm> createState() => _FuelFormState();
}

class _FuelFormState extends State<FuelForm> {
  // --- Temporary Dummy Data ---
  // Later, we will pull these lists directly from your database!
  final List<String> _myCars = ['Daily Driver', 'Weekend Car'];
  final List<String> _gasStations = ['Shell', 'Aral', 'Esso', 'Other'];

  // These variables remember what the user actually selected
  String? _selectedCar;
  String? _selectedStation;

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
            const Text('Add Fuel Stop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

            // 2. Gas Station Selection Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Gas Station', border: OutlineInputBorder()),
              initialValue: _selectedStation,
              items: _gasStations.map((String station) {
                return DropdownMenuItem<String>(value: station, child: Text(station));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStation = newValue;
                });
              },
            ),
            const SizedBox(height: 10),

            // 3. Distance
            const TextField(
              decoration: InputDecoration(labelText: 'Distance (km)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            // 4. Amount in Liters
            const TextField(
              decoration: InputDecoration(labelText: 'Amount (Liters)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            // 5. Total Price
            const TextField(
              decoration: InputDecoration(labelText: 'Total Price', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
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