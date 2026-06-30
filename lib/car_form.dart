import 'package:flutter/material.dart';
import 'database/database_helper.dart'; // NEW: Import the database
import 'models/car.dart';             // NEW: Import the Car model

class CarForm extends StatefulWidget {
  const CarForm({super.key});

  @override
  State<CarForm> createState() => _CarFormState();
}

class _CarFormState extends State<CarForm> {
  // --- NEW: Controllers to grab the text from the input fields ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _tuevController = TextEditingController();
  final TextEditingController _boughtDateController = TextEditingController();
  final TextEditingController _boughtPriceController = TextEditingController();
  final TextEditingController _soldDateController = TextEditingController();
  final TextEditingController _soldPriceController = TextEditingController();

  // Dropdown options
  final List<String> _statusOptions = ['Active', 'Sold', 'Retired'];
  final List<String> _fuelOptions = ['Gasoline', 'Diesel', 'Electric', 'Hybrid', 'Other'];
  final List<String> _tireOptions = ['Summer', 'Winter', 'All-Season', 'Track/Semi-Slick'];

  String? _selectedStatus = 'Active'; 
  String? _selectedFuel;
  String? _selectedTire;

  // IMPORTANT: We must clean up controllers when the form closes to save memory
  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _tuevController.dispose();
    _boughtDateController.dispose();
    _boughtPriceController.dispose();
    _soldDateController.dispose();
    _soldPriceController.dispose();
    super.dispose();
  }

  // --- NEW: The function that actually saves the data ---
  Future<void> _saveCar() async {
    // 1. Check if the required name field is empty
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Car Name!')),
      );
      return;
    }

    // 2. Package all the data into our Car Model
    final newCar = Car(
      carName: _nameController.text,
      manufacturer: _manufacturerController.text,
      yearOfManufacture: _yearController.text,
      status: _selectedStatus,
      licensePlate: _plateController.text,
      nextTuev: _tuevController.text,
      fuelType: _selectedFuel,
      tireType: _selectedTire,
      boughtDate: _boughtDateController.text,
      // We convert the text to a number (double). If it fails, it saves as null.
      boughtPrice: double.tryParse(_boughtPriceController.text),
      soldDate: _soldDateController.text,
      soldPrice: double.tryParse(_soldPriceController.text),
    );

    // 3. Send it to the Database
    await DatabaseHelper.instance.insertCar(newCar.toMap());

    // 4. Close the form
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
              child: Text('Add New Vehicle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            // --- Basic Info ---
            const Text('Basic Information', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController, // Assigned Controller
              decoration: const InputDecoration(labelText: 'Car Name (e.g. Daily Driver)*', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _manufacturerController, // Assigned Controller
              decoration: const InputDecoration(labelText: 'Manufacturer', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _yearController, // Assigned Controller
              decoration: const InputDecoration(labelText: 'Year of Manufacture', border: OutlineInputBorder()), 
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              value: _selectedStatus,
              items: _statusOptions.map((String status) {
                return DropdownMenuItem<String>(value: status, child: Text(status));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedStatus = newValue),
            ),
            const SizedBox(height: 20),

            // --- Specifications ---
            const Text('Specifications & Details', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _plateController, // Assigned Controller
              decoration: const InputDecoration(labelText: 'License Plate', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tuevController, // Assigned Controller
              decoration: const InputDecoration(labelText: 'Next TÜV (MM/YYYY)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Fuel Type', border: OutlineInputBorder()),
              value: _selectedFuel,
              items: _fuelOptions.map((String fuel) {
                return DropdownMenuItem<String>(value: fuel, child: Text(fuel));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedFuel = newValue),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Tire Type', border: OutlineInputBorder()),
              value: _selectedTire,
              items: _tireOptions.map((String tire) {
                return DropdownMenuItem<String>(value: tire, child: Text(tire));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedTire = newValue),
            ),
            const SizedBox(height: 20),

            // --- Financials ---
            const Text('Financials', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _boughtDateController, // Assigned Controller
              decoration: const InputDecoration(labelText: 'Bought Date', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _boughtPriceController, // Assigned Controller
              decoration: const InputDecoration(labelText: 'Bought Price', border: OutlineInputBorder()), 
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _soldDateController, // Assigned Controller
              decoration: const InputDecoration(labelText: 'Sold Date', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _soldPriceController, // Assigned Controller
              decoration: const InputDecoration(labelText: 'Sold Price', border: OutlineInputBorder()), 
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: _saveCar, // <--- Now triggers our save function!
                child: const Text('Save Vehicle'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}