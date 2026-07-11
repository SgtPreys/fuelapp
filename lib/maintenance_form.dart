import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database/database_helper.dart';
import 'models/maintenance_stop.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MaintenanceForm extends StatefulWidget {
  final MaintenanceStop? existingMaintenanceStop;

  const MaintenanceForm({super.key, this.existingMaintenanceStop});

  @override
  State<MaintenanceForm> createState() => _MaintenanceFormState();
}

class _MaintenanceFormState extends State<MaintenanceForm> {
  // --- NEW: Dropdown options and variable ---
  final List<String> _occurrenceOptions = ['Repair', 'Parts', 'Check/Service', 'Insurance', 'Tax', 'TÜV', 'Other'];
  String? _selectedOccurrence;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _cars = [];
  List<Map<String, dynamic>> _companies = [];

  int? _selectedCarId;
  int? _selectedCompanyId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    _loadDropdownData();
    if (widget.existingMaintenanceStop != null) {
      _additionalInfoController.text = widget.existingMaintenanceStop!.additionalInfo ?? '';
      _imagePath = widget.existingMaintenanceStop!.imagePath;
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



  Future<void> _loadDropdownData() async {
    final allCars = await DatabaseHelper.instance.getAllCars();
    final companies = await DatabaseHelper.instance.getAllCompanies();

    setState(() {
      // --- NEW: Safely filter the car list ---
      _cars = allCars.where((car) {
        final isActive = car['status'] == 'Active';
        final isAlreadySelected = widget.existingMaintenanceStop != null && car['id'] == widget.existingMaintenanceStop!.carId;
        return isActive || isAlreadySelected;
      }).toList();

      _companies = companies;
      _isLoading = false;

      if (widget.existingMaintenanceStop != null) {
        _selectedCarId = widget.existingMaintenanceStop!.carId;
        _selectedCompanyId = widget.existingMaintenanceStop!.companyId;
        _selectedOccurrence = widget.existingMaintenanceStop!.occurrence;
        if (!_occurrenceOptions.contains(_selectedOccurrence)) {
          _selectedOccurrence = 'Other'; // Fallback for old custom text entries
        }
        _priceController.text = widget.existingMaintenanceStop!.totalPrice?.toString() ?? '';
        _infoController.text = widget.existingMaintenanceStop!.additionalInfo ?? '';
        _dateController.text = widget.existingMaintenanceStop!.date;
      }
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _infoController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveMaintenance() async {
    if (_selectedCarId == null || _selectedCompanyId == null || _selectedOccurrence == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all required fields')));
      return;
    }

    final maintenanceData = MaintenanceStop(
      id: widget.existingMaintenanceStop?.id,
      carId: _selectedCarId!,
      companyId: _selectedCompanyId!,
      occurrence: _selectedOccurrence!,
      totalPrice: double.tryParse(_priceController.text),
      imagePath: _imagePath,
      additionalInfo: _infoController.text,
      date: _dateController.text,
    );

    if (widget.existingMaintenanceStop == null) {
      await DatabaseHelper.instance.insertMaintenanceStop(maintenanceData.toMap());
    } else {
      await DatabaseHelper.instance.updateMaintenanceStop(maintenanceData.toMap());
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
    }

    final isEditing = widget.existingMaintenanceStop != null;

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
              child: Text(isEditing ? 'Edit Maintenance' : 'Add Maintenance', 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

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

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Select Shop/Company*', border: OutlineInputBorder()),
              initialValue: _selectedCompanyId,
              items: _companies.map((company) {
                return DropdownMenuItem<int>(
                  value: company['id'] as int,
                  child: Text(company['name']),
                );
              }).toList(),
              onChanged: (int? newValue) => setState(() => _selectedCompanyId = newValue),
              hint: _companies.isEmpty ? const Text('No Shops Available - Add one first!') : null,
            ),
            const SizedBox(height: 10),

            // --- NEW: Occurrence Dropdown ---
            DropdownButtonFormField<String>(
              initialValue: _selectedOccurrence,
              decoration: const InputDecoration(labelText: 'Occurrence Type*', border: OutlineInputBorder()),
              items: _occurrenceOptions.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedOccurrence = newValue),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Total Cost', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            
            // --- UPDATED DATE & TIME PICKER FIELD ---
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date & Time*', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
              readOnly: true,
              onTap: () async {
                HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                
                if (pickedDate != null && mounted) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  
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
            
            

            
            TextField(
              controller: _infoController,
              decoration: const InputDecoration(labelText: 'Additional Info', border: OutlineInputBorder()),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(_imagePath!),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Trigger a satisfying physical tap sensation
                  HapticFeedback.mediumImpact();
                  // Then execute your save logic
                  _saveMaintenance(); 
                },
                child: Text(isEditing ? 'Update Maintenance' : 'Save Maintenance'),
              ),
            ),

            if (isEditing) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () async {
                    HapticFeedback.heavyImpact();
                    await DatabaseHelper.instance.deleteMaintenanceStop(widget.existingMaintenanceStop!.id!);
                    if (mounted) Navigator.pop(context, true);
                  },
                  child: const Text('Delete Maintenance', style: TextStyle(color: Colors.red)),
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