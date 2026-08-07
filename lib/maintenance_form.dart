import 'package:flutter/material.dart';
import 'package:fuelapp/models/company.dart';
import 'package:intl/intl.dart';
import 'database/database_helper.dart';
import 'models/maintenance_stop.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'l10n/app_localizations.dart';
import 'car_form.dart';
import 'company_form.dart';

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
  bool _showAllCompanies = false; // New state variable to toggle company visibility

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
              Row(children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: Text(AppLocalizations.of(context)!.photolibrary),
                    iconColor: Colors.blue,
                    onTap: () {
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Future<void> _loadDropdownData() async {
    final allCars = await DatabaseHelper.instance.getAllCars();
    //final companies = await DatabaseHelper.instance.getAllCompanies();
    final db = await DatabaseHelper.instance.database;
    String whereClause = _showAllCompanies ? "" : "WHERE isVisible = 1";
    _companies = await db.rawQuery('SELECT * FROM companies $whereClause');

    setState(() {
      // --- NEW: Safely filter the car list ---
      _cars = allCars.where((car) {
        final isActive = car['status'] == 'Active';
        final isAlreadySelected = widget.existingMaintenanceStop != null && car['id'] == widget.existingMaintenanceStop!.carId;
        return isActive || isAlreadySelected;
      }).toList();

      _companies = _companies;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.pleasefillfields)));
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
            const SizedBox(height: 30),
            Center(
              child: Text(isEditing ? AppLocalizations.of(context)!.editmaintenancestop : AppLocalizations.of(context)!.addMaintenanceStop, 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            Row(children: [
              Expanded(child: 
                  DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.selectcar, border: OutlineInputBorder()),
                  initialValue: _selectedCarId,
                  items: _cars.map((car) {
                    return DropdownMenuItem<int>(
                      value: car['id'] as int,
                      child: Text(car['carName']),
                    );
                  }).toList(),
                  onChanged: (int? newValue) => setState(() => _selectedCarId = newValue),
                  hint: _cars.isEmpty ? Text(AppLocalizations.of(context)!.nocarsavailable) : null,
                ),
              ),
              const SizedBox(width: 10),
              Container(decoration: BoxDecoration(
                    
                    border: Border.all(color: Colors.indigo) ,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                      icon: const Icon(Icons.format_list_bulleted_add),
                      color: Colors.indigo,
                      onPressed: () async {
                        // 1. Navigate to your Car creation form
                        // Replace 'AddCarScreen()' with the actual name of your screen
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CarForm()),
                        );
                        
                        // 2. If the user added a car (e.g., returned 'true'), reload the list
                        if (result == true) {
                          _loadDropdownData(); // Assuming you have this helper to refresh
                        }
                      },
                    ),
                  )
              ],),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: 
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.selectcompany, border: OutlineInputBorder()),
                    initialValue: _selectedCompanyId,
                    items: _companies.map((company) {
                      return DropdownMenuItem<int>(
                        value: company['id'] as int,
                        child: Text(company['name']),
                      );
                    }).toList(),
                    onChanged: (int? newValue) => setState(() => _selectedCompanyId = newValue),
                    hint: _companies.isEmpty ? Text(AppLocalizations.of(context)!.nocompanyavailable) : null,
                  ),
              ),
              const SizedBox(width: 10),
              Container(decoration: BoxDecoration(
                border: Border.all(color: Colors.purple),
                borderRadius: BorderRadius.circular(4),
              ),child: TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true; // Optional: show loading state while fetching
                    _showAllCompanies = !_showAllCompanies;
                  });
                  _loadDropdownData(); // Reload the list with the new filter
                },
                child: Text(
                  _showAllCompanies ? AppLocalizations.of(context)!.hideinactivecompanies : AppLocalizations.of(context)!.showhiddencompanies,
                  style: const TextStyle(fontSize: 12, color: Colors.purple),
                ),
              ),),

              const SizedBox(width: 10),
              Container(decoration: BoxDecoration(
                    
                    border: Border.all(color: Colors.purple) ,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                      icon: const Icon(Icons.add_business),
                      color: Colors.purple,
                      onPressed: () async {
                        // 1. Navigate to your Car creation form
                        // Replace 'AddCarScreen()' with the actual name of your screen
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CompanyForm()),
                        );
                        
                        // 2. If the user added a car (e.g., returned 'true'), reload the list
                        if (result == true) {
                          _loadDropdownData(); // Assuming you have this helper to refresh
                        }
                      },
                    ),
                  )
              ],),

            
            const SizedBox(height: 10),

            // --- NEW: Occurrence Dropdown ---
            DropdownButtonFormField<String>(
              initialValue: _selectedOccurrence,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.occurrence, border: OutlineInputBorder(),suffixIcon: Icon(Icons.build)),
              items: _occurrenceOptions.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedOccurrence = newValue),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.price, border: OutlineInputBorder(),suffixIcon: Icon(Icons.euro)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            
            // --- UPDATED DATE & TIME PICKER FIELD ---
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.dateandtime, border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
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
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.additionalinfo, border: OutlineInputBorder()),
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

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Trigger a satisfying physical tap sensation
                  HapticFeedback.mediumImpact();
                  // Then execute your save logic
                  _saveMaintenance(); 
                },
                child: Text(isEditing ? AppLocalizations.of(context)!.updatemaintenance : AppLocalizations.of(context)!.savemaintenance),
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
                  child: Text(AppLocalizations.of(context)!.deletemaintenance, style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}