import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/car.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'l10n/app_localizations.dart';

class CarForm extends StatefulWidget {
  // NEW: This allows the form to accept an existing car when we want to edit!
  final Car? existingCar;

  const CarForm({super.key, this.existingCar});

  @override
  State<CarForm> createState() => _CarFormState();
}

class _CarFormState extends State<CarForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _tuevController = TextEditingController();
  final TextEditingController _boughtDateController = TextEditingController();
  final TextEditingController _boughtPriceController = TextEditingController();
  final TextEditingController _soldDateController = TextEditingController();
  final TextEditingController _soldPriceController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  final List<String> _statusOptions = ['Active', 'Sold', 'Retired'];
  final List<String> _fuelOptions = ['Gasoline E5','Gasoline E10', 'Diesel', 'Electric', 'Hybrid', 'Other'];
  final List<String> _tireOptions = ['Summer', 'Winter', 'All-Season'];

  String? _selectedStatus = 'Active';
  String? _selectedFuel;
  String? _selectedTire;

  // --- NEW: If we passed an existing car, fill the controllers with its data! ---
  @override
  void initState() {
    super.initState();
    if (widget.existingCar != null) {
      _nameController.text = widget.existingCar!.carName;
      _manufacturerController.text = widget.existingCar!.manufacturer ?? '';
      _yearController.text = widget.existingCar!.yearOfManufacture ?? '';
      _selectedStatus = widget.existingCar!.status ?? 'Active';
      _plateController.text = widget.existingCar!.licensePlate ?? '';
      _tuevController.text = widget.existingCar!.nextTuev ?? '';
      _selectedFuel = widget.existingCar!.fuelType;
      _selectedTire = widget.existingCar!.tireType;
      _boughtDateController.text = widget.existingCar!.boughtDate ?? '';
      _boughtPriceController.text = widget.existingCar!.boughtPrice?.toString() ?? '';
      _soldDateController.text = widget.existingCar!.soldDate ?? '';
      _soldPriceController.text = widget.existingCar!.soldPrice?.toString() ?? '';
      _additionalInfoController.text = widget.existingCar!.additionalInfo ?? '';
      _imagePath = widget.existingCar!.imagePath;
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

  Future<void> _saveCar() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Car Name!')),
      );
      return;
    }

    final carData = Car(
      // NEW: If we are editing, we MUST keep the same database ID!
      id: widget.existingCar?.id, 
      carName: _nameController.text,
      manufacturer: _manufacturerController.text,
      yearOfManufacture: _yearController.text,
      status: _selectedStatus,
      licensePlate: _plateController.text,
      nextTuev: _tuevController.text,
      fuelType: _selectedFuel,
      tireType: _selectedTire,
      boughtDate: _boughtDateController.text,
      boughtPrice: double.tryParse(_boughtPriceController.text),
      soldDate: _soldDateController.text,
      soldPrice: double.tryParse(_soldPriceController.text),
    );

    // --- NEW: Decide whether to Insert or Update ---
    if (widget.existingCar == null) {
      await DatabaseHelper.instance.insertCar(carData.toMap()); // It's a new car
    } else {
      await DatabaseHelper.instance.updateCar(carData.toMap()); // It's an existing car
    }
    
    if (mounted) {
      Navigator.pop(context, true); // We pass 'true' back so the previous screen knows to refresh!
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically change the title based on what we are doing
    final isEditing = widget.existingCar != null;

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
                isEditing ? 'Edit Vehicle' : 'Add New Vehicle', 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 20),

            const Text('Basic Information', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Car Name (e.g. Daily Driver)*', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _manufacturerController,
              decoration: const InputDecoration(labelText: 'Manufacturer', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Year of Manufacture', border: OutlineInputBorder()), 
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              initialValue: _selectedStatus,
              items: _statusOptions.map((String status) {
                return DropdownMenuItem<String>(value: status, child: Text(status));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedStatus = newValue),
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
                    label: Text(_imagePath == null ? 'Add Photo' : 'Change Photo'),
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
            const SizedBox(height: 20),

            const Text('Specifications & Details', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _plateController,
              decoration: const InputDecoration(labelText: 'License Plate', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tuevController,
              decoration: const InputDecoration(labelText: 'Next TÜV (MM/YYYY)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Fuel Type', border: OutlineInputBorder()),
              initialValue: _selectedFuel,
              items: _fuelOptions.map((String fuel) {
                return DropdownMenuItem<String>(value: fuel, child: Text(fuel));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedFuel = newValue),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Tire Type', border: OutlineInputBorder()),
              initialValue: _selectedTire,
              items: _tireOptions.map((String tire) {
                return DropdownMenuItem<String>(value: tire, child: Text(tire));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedTire = newValue),
            ),
            const SizedBox(height: 20),

            const Text('Financials', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _boughtDateController,
              decoration: const InputDecoration(labelText: 'Bought Date', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _boughtPriceController,
              decoration: const InputDecoration(labelText: 'Bought Price', border: OutlineInputBorder()), 
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _soldDateController,
              decoration: const InputDecoration(labelText: 'Sold Date', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _soldPriceController,
              decoration: const InputDecoration(labelText: 'Sold Price', border: OutlineInputBorder()), 
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 20),
            
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Trigger a satisfying physical tap sensation
                  HapticFeedback.mediumImpact();
                  // Then execute your save logic
                  _saveCar(); 
                },
                child: Text(isEditing ? 'Update Vehicle' : 'Save Vehicle'),
              ),
            ),
            
            // --- NEW: DELETE BUTTON ---
            if (isEditing) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () async {
                    // Show confirmation dialog
                    bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Vehicle'),
                        content: const Text('Are you sure you want to delete this vehicle? This action cannot be undone. In doing so you also delete all related data (fuel, maintenance, etc.)!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.pop(context, false); // Cancel
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.pop(context, true);
                            }, // Confirm
                            child: const Text('Delete')
                          ),
                        ],
                      ),
                    );

                    // Check if user confirmed
                    if (confirmDelete == true) {
                      HapticFeedback.heavyImpact();
                      // Tell the database to delete this ID
                      await DatabaseHelper.instance.deleteCar(widget.existingCar!.id!);
                      if (mounted) {
                        Navigator.pop(context, true); // Close form and trigger refresh
                      }
                    }
                  },
                  child: const Text('Delete Vehicle', style: TextStyle(color: Colors.red)),
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