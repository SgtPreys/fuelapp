import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'database/database_helper.dart';
import 'models/car.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
              Row(children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: Text(AppLocalizations.of(context)!.photolibrary),
                    iconColor: Colors.blue,
                    onTap: () {
                      HapticFeedback.lightImpact(); // Provide a subtle physical feedback
                      _pickImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: Text(AppLocalizations.of(context)!.camera),
                    iconColor: Colors.blue,
                    onTap: () {
                      HapticFeedback.lightImpact(); // Provide a subtle physical feedback
                      _pickImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: Text(AppLocalizations.of(context)!.cancel),
                iconColor: Colors.red,
                onTap: () {
                  HapticFeedback.lightImpact(); // Provide a subtle physical feedback
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 150), 
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
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
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
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseentercarname)),
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
      imagePath: _imagePath,
      additionalInfo: _additionalInfoController.text,
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

    return Material(
      //color: Colors.grey, // Keeps your background style
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
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
            // --- THE DRAG HANDLE ---
            Center(
              child: Container(
                width: 40, // How wide the bar is
                height: 5,  // How thick the bar is
                margin: const EdgeInsets.only(bottom: 20), // Space between bar and your title
                decoration: BoxDecoration(
                  color: Colors.grey[400], // A subtle grey color
                  borderRadius: BorderRadius.circular(10), // Rounds the edges perfectly
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                isEditing ? AppLocalizations.of(context)!.editcar : AppLocalizations.of(context)!.addNewCar, 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 20),

            Text(AppLocalizations.of(context)!.basicinfo, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.carname, border: OutlineInputBorder(),suffixIcon: Icon(Icons.directions_car)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _manufacturerController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.manufacturer, border: OutlineInputBorder(),suffixIcon: Icon(Icons.business)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _yearController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.yearofmanufacture, border: OutlineInputBorder(),suffixIcon: Icon(Icons.calendar_today)), 
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.status, border: OutlineInputBorder(),suffixIcon: Icon(Icons.check_circle)),
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
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.additionalinfo,
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
                    label: Text(_imagePath == null ? AppLocalizations.of(context)!.addphoto : AppLocalizations.of(context)!.changephoto),
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

            Text(AppLocalizations.of(context)!.specifications, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _plateController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.plate, border: OutlineInputBorder(),suffixIcon: Icon(Icons.card_membership)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tuevController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.nexttuev, border: OutlineInputBorder(),suffixIcon: Icon(Icons.calendar_today)),
              readOnly: true,
              onTap: () async {
                HapticFeedback.lightImpact();
                
                // 1. Pick the Date (User picks any day in the target month)
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                
                // 2. If a date was chosen, format it strictly to Year/Month
                if (pickedDate != null && mounted) {
                  setState(() { 
                    // This saves it as something like "2027-07"
                    _tuevController.text = DateFormat('MM/yyyy').format(pickedDate); 
                  });
                }
              },
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fueltype, border: OutlineInputBorder(),suffixIcon: Icon(Icons.local_gas_station)),
              initialValue: _selectedFuel,
              items: _fuelOptions.map((String fuel) {
                return DropdownMenuItem<String>(value: fuel, child: Text(fuel));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedFuel = newValue),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.tiretype, border: OutlineInputBorder(),suffixIcon: Icon(Icons.tire_repair)),
              initialValue: _selectedTire,
              items: _tireOptions.map((String tire) {
                return DropdownMenuItem<String>(value: tire, child: Text(tire));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedTire = newValue),
            ),
            const SizedBox(height: 20),

            Text(AppLocalizations.of(context)!.financials, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _boughtDateController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.boughtdate, border: OutlineInputBorder(),suffixIcon: Icon(Icons.calendar_today)),
              readOnly: true,
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
                      _boughtDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime); 
                    });
                  }
                }
              },
              //keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _boughtPriceController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.boughtprice, border: OutlineInputBorder(),suffixIcon: Icon(Icons.euro)), 
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _soldDateController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.solddate, border: OutlineInputBorder(),suffixIcon: Icon(Icons.calendar_today)),
              readOnly: true,
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
                      _boughtDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime); 
                    });
                  }
                }
              },
              //keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _soldPriceController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.soldprice, border: OutlineInputBorder(),suffixIcon: Icon(Icons.euro)), 
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
                  Fluttertoast.showToast(
                    msg: isEditing ? AppLocalizations.of(context)!.carupdated : AppLocalizations.of(context)!.caradded,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );

                },
                child: Text(isEditing ? AppLocalizations.of(context)!.updatecar : AppLocalizations.of(context)!.savecar),
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
                        title: Text(AppLocalizations.of(context)!.deletecar),
                        content: Text(AppLocalizations.of(context)!.deletecartext),
                        actions: [
                          TextButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.pop(context, false); // Cancel
                            },
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.pop(context, true);
                            }, // Confirm
                            child: Text(AppLocalizations.of(context)!.delete)
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
                        Navigator.pop(context, true);
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.cardeleted,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                        ); // Close form and trigger refresh
                      }
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.deletecar, style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    ));
  }
}