import 'package:flutter/material.dart';

class FuelForm extends StatelessWidget {
  const FuelForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // This ensures the form doesn't get covered by the keyboard
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
            const TextField(
              decoration: InputDecoration(labelText: 'Amount (Liters)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(labelText: 'Total Price', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(labelText: 'Distance (km)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
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