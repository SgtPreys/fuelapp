import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Helps us format dates cleanly
import 'database/database_helper.dart';
import 'models/fuel_stop.dart';

class FuelForm extends StatefulWidget {
  final FuelStop? existingFuelStop;

  const FuelForm({super.key, this.existingFuelStop});

  @override
  State<FuelForm> createState() => _FuelFormState();
}

class _FuelFormState extends State<FuelForm> {
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  List<Map<String, dynamic>> _cars = [];
  List<Map<String, dynamic>> _stations = [];

  int? _selectedCarId;
  int? _selectedStationId;
  bool _isLoading = true; // Wait for dropdown data to load

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()); // Defaults to today
    _loadDropdownData();
  }

  // --- NEW: Fetch Cars and Stations for the Dropdowns ---
  Future<void> _loadDropdownData() async {
    final cars = await DatabaseHelper.instance.getAllCars();
    final stations = await DatabaseHelper.instance.getAllStations();

    setState(() {
      _cars = cars;
      _stations = stations;
      _isLoading = false;

      // If we are editing, pre-fill all the data
      if (widget.existingFuelStop != null) {
        _selectedCarId = widget.existingFuelStop!.carId;
        _selectedStationId = widget.existingFuelStop!.stationId;
        _distanceController.text = widget.existingFuelStop!.distance?.toString() ?? '';
        _litersController.text = widget.existingFuelStop!.liters?.toString() ?? '';
        _priceController.text = widget.existingFuelStop!.totalPrice?.toString() ?? '';
        _dateController.text = widget.existingFuelStop!.date;
      }
    });
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _litersController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveFuelStop() async {
    // Validation
    if (_selectedCarId == null || _selectedStationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a Car and a Gas Station!')),
      );
      return;
    }

    final fuelData = FuelStop(
      id: widget.existingFuelStop?.id,
      carId: _selectedCarId!,
      stationId: _selectedStationId!,
      distance: double.tryParse(_distanceController.text),
      liters: double.tryParse(_litersController.text),
      totalPrice: double.tryParse(_priceController.text),
      date: _dateController.text,
    );

    if (widget.existingFuelStop == null) {
      await DatabaseHelper.instance.insertFuelStop(fuelData.toMap());
    } else {
      await DatabaseHelper.instance.updateFuelStop(fuelData.toMap());
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
    }

    final isEditing = widget.existingFuelStop != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20, left: 20, right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(isEditing ? 'Edit Fuel Stop' : 'Add Fuel Stop', 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            // --- DYNAMIC CAR DROPDOWN ---
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Select Vehicle*', border: OutlineInputBorder()),
              initialValue: _selectedCarId,
              items: _cars.map((car) {
                return DropdownMenuItem<int>(
                  value: car['id'] as int,
                  child: Text(car['carName']),
                );
              }).toList(),
              onChanged: (int? newValue) => setState(() => _selectedCarId = newValue),
              hint: _cars.isEmpty ? const Text('No Cars Available - Add one first!') : null,
            ),
            const SizedBox(height: 10),

            // --- DYNAMIC STATION DROPDOWN ---
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Select Gas Station*', border: OutlineInputBorder()),
              initialValue: _selectedStationId,
              items: _stations.map((station) {
                return DropdownMenuItem<int>(
                  value: station['id'] as int,
                  child: Text(station['name']),
                );
              }).toList(),
              onChanged: (int? newValue) => setState(() => _selectedStationId = newValue),
              hint: _stations.isEmpty ? const Text('No Stations Available - Add one first!') : null,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _distanceController,
              decoration: const InputDecoration(labelText: 'Driven Distance (km)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _litersController,
                    decoration: const InputDecoration(labelText: 'Liters', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Total Price (€)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // --- UPDATED DATE & TIME PICKER FIELD ---
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date & Time*', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
              readOnly: true, // Prevents manual typing
              onTap: () async {
                // 1. Pick the Date
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                
                // 2. If a date was chosen, pick the Time
                if (pickedDate != null && mounted) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  
                  // 3. Combine them and format!
                  if (pickedTime != null) {
                    DateTime combinedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    setState(() { 
                      _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime); 
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _saveFuelStop,
                child: Text(isEditing ? 'Update Fuel Stop' : 'Save Fuel Stop'),
              ),
            ),
            
            if (isEditing) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await DatabaseHelper.instance.deleteFuelStop(widget.existingFuelStop!.id!);
                    if (mounted) Navigator.pop(context, true);
                  },
                  child: const Text('Delete Fuel Stop', style: TextStyle(color: Colors.red)),
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