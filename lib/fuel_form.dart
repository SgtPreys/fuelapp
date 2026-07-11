import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Helps us format dates cleanly
import 'database/database_helper.dart';
import 'models/fuel_stop.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
  final TextEditingController _additionalInfoController = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

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
    if (widget.existingFuelStop != null) {
      _additionalInfoController.text = widget.existingFuelStop!.additionalInfo ?? '';
      _imagePath = widget.existingFuelStop!.imagePath;
    }
  }
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      // Get the app's local directory
      final directory = await getApplicationDocumentsDirectory();
      
      // Create a unique file name
      final String fileName = path.basename(pickedFile.path);
      final String savedImagePath = '${directory.path}/$fileName';
      
      // Copy the image to the new secure location
      File(pickedFile.path).copySync(savedImagePath);

      setState(() {
        _imagePath = savedImagePath;
      });
    }
  }
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  void _showFullScreenImage(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero, // Makes it edge-to-edge
          child: Stack(
            fit: StackFit.expand,
            children: [
              // InteractiveViewer gives you pinch-to-zoom for free!
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                ),
              ),
              // A close button in the top right corner
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  // --- NEW: Fetch Cars and Stations for the Dropdowns ---
  Future<void> _loadDropdownData() async {
    final allCars = await DatabaseHelper.instance.getAllCars();
    final stations = await DatabaseHelper.instance.getAllStations();

    setState(() {
      // --- NEW: Safely filter the car list ---
      _cars = allCars.where((car) {
        final isActive = car['status'] == 'Active';
        final isAlreadySelected = widget.existingFuelStop != null && car['id'] == widget.existingFuelStop!.carId;
        return isActive || isAlreadySelected;
      }).toList();

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
        const SnackBar(content: Text('Please select a Car and a Station!')),
      );
      return;
    }

    final fuelData = FuelStop(
      id: widget.existingFuelStop?.id,
      carId: _selectedCarId!,
      stationId: _selectedStationId,
      distance: double.tryParse(_distanceController.text),
      liters: double.tryParse(_litersController.text),
      totalPrice: double.tryParse(_priceController.text),
      date: _dateController.text,
      imagePath: _imagePath,
      additionalInfo: _additionalInfoController.text.isEmpty ? null : _additionalInfoController.text,
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
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date & Time*', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
              readOnly: true, // Prevents manual typing
              onTap: () async {
                HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
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
            const SizedBox(height: 10),

            
            // Additional Info TextField
            TextField(
              controller: _additionalInfoController,
              decoration: const InputDecoration(
                labelText: 'Additional Info',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            
            // Image Picker Section
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showImagePickerOptions,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_imagePath == null ? 'Add Receipt/Photo' : 'Change Photo'),
                  ),
                ),
                if (_imagePath != null) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _imagePath = null;
                      });
                    },
                  ),
                ],
              ],
            ),
            
            // Image Preview (if image exists)
            if (_imagePath != null) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact(); // Nice physical touch
                  _showFullScreenImage(context, _imagePath!);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // The Thumbnail
                      Image.file(
                        File(_imagePath!),
                        height: 200, // Increased slightly for a better preview
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // A semi-transparent overlay icon indicating it can be enlarged
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),

            // --- UPDATED DATE & TIME PICKER FIELD ---

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Trigger a satisfying physical tap sensation
                  HapticFeedback.mediumImpact();
                  // Then execute your save logic
                  _saveFuelStop(); 
                },
                child: Text(isEditing ? 'Update Fuel Stop' : 'Save Fuel Stop'),
              ),
            ),
            
            if (isEditing) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () async {
                    HapticFeedback.heavyImpact();
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