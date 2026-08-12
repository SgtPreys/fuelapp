import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Helps us format dates cleanly
import 'database/database_helper.dart';
import 'models/fuel_stop.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'l10n/app_localizations.dart';
import 'car_form.dart';
import 'station_form.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  bool _showAllStations = true; // NEW: Control visibility of stations in dropdown

  

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
      await _performTextRecognition(savedImagePath); // Scan the receipt after saving the image
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
              const SizedBox(height: 150), // Optional: Add some spacing at the bottom
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
  Future<void> _performTextRecognition(String imagePath) async {
  try {
    // 1. Tell the user we are scanning (optional but good for UX)
    if (mounted) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.scanningimage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
    }

    // 2. Prepare the image for ML Kit
    final inputImage = InputImage.fromFilePath(imagePath);
    
    // 3. Initialize the text recognizer (Latin script covers English, German, etc.)
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    
    // 4. Process the image and extract the text
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String foundLiters = '';
    String foundPrice = '';
    String foundInfo = '';

    // This Regular Expression looks for numbers with decimals/commas (e.g., 45.60 or 45,60)
    final numberPattern = RegExp(r'\d+[.,]\d+');

    // 3. The Brains: Parse line by line
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        // Convert to lowercase to make searching easier (e.g., "Summe" becomes "summe")
        final text = line.text.toLowerCase();

        // --- HUNT FOR LITERS ---
        if (text.contains('liter') || text.contains('ltr') || text.endsWith(' l')) {
          final match = numberPattern.firstMatch(text);
          if (match != null) {
            // Replace comma with dot so Flutter can parse it as a double later
            foundLiters = match.group(0)!.replaceAll(',', '.'); 
          }
        }

        // --- HUNT FOR PRICE ---
        if (text.contains('summe') || text.contains('total') || text.contains('eur') || text.contains('€')) {
          final match = numberPattern.firstMatch(text);
          if (match != null) {
            foundPrice = match.group(0)!.replaceAll(',', '.');
          }
        }
        // --- HUNT FOR INFO ---
        if (text.contains('info') || text.contains('bemerkung') || text.contains('details')) {
          foundInfo = text.replaceAll(RegExp(r'(info|bemerkung|details):?\s*', caseSensitive: false), '').trim();
        }
      }
    }

    // 4. Update the UI (Fallback Strategy)
    // We update the controllers, but WE DO NOT SAVE automatically. 
    // This lets the user verify the AI's work and correct it if needed.
    setState(() {
      if (foundLiters.isNotEmpty) {
        _litersController.text = foundLiters;
      }
      if (foundPrice.isNotEmpty) {
        _priceController.text = foundPrice;
      }
      if (foundInfo.isNotEmpty) _additionalInfoController.text = foundInfo;
    });
    
    // 5. Close the recognizer to save memory
    textRecognizer.close();

    // TEMPORARY: Print the massive block of text to your VS Code terminal so we can see what it found!
    print("------- SCANNED IMAGE TEXT -------");
    print(recognizedText.text);
    print("------------------------------------");

    // Next step will go here: Searching the text for liters and prices!

  } catch (e) {
    print("Error scanning image: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to read image: $e')),
      );
    }
  }
  }



  // --- NEW: Fetch Cars and Stations for the Dropdowns ---
  Future<void> _loadDropdownData() async {
    final allCars = await DatabaseHelper.instance.getAllCars();
    //final stations = await DatabaseHelper.instance.getAllStations();
    
    final db = await DatabaseHelper.instance.database;
    String whereClause = "";
    if (!_showAllStations) {
      // If we have a station currently selected (like when editing), 
      // we MUST include it in the list so the dropdown doesn't crash!
      if (_selectedStationId != null) {
        whereClause = "WHERE isVisible = 1 OR id = $_selectedStationId";
      } else {
        // Standard behavior for a brand new form
        whereClause = "WHERE isVisible = 1";
      }
    }
    _stations = await DatabaseHelper.instance.database.then(
      (db) => db.rawQuery('SELECT * FROM stations $whereClause')
    );

    setState(() {
      // --- NEW: Safely filter the car list ---
      _cars = allCars.where((car) {
        final isActive = car['status'] == 'Active';
        final isAlreadySelected = widget.existingFuelStop != null && car['id'] == widget.existingFuelStop!.carId;
        return isActive || isAlreadySelected;
      }).toList();

      _stations = _stations;
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
    if (_selectedCarId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectcarfirst)),
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

    
    bool stationExists = _stations.any((station) => station['id'] == _selectedStationId);
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
              child: Text(isEditing ? AppLocalizations.of(context)!.editfuelstop : AppLocalizations.of(context)!.addFuelStop, 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            // --- DYNAMIC CAR DROPDOWN ---
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
            // --- DYNAMIC STATION DROPDOWN ---

            Row(children: [
              Expanded(child: 
                  DropdownButtonFormField<int>(
                    initialValue: stationExists ? _selectedStationId : null,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.selectstation, border: OutlineInputBorder()),
                    items: _stations.map((station) {
                      return DropdownMenuItem<int>(
                        value: station['id'] as int,
                        child: Text(station['name']),
                      );
                    }).toList(),
                    onChanged: (int? newValue) => setState(() => _selectedStationId = newValue),
                    hint: _stations.isEmpty ? Text(AppLocalizations.of(context)!.nostationsavailable) : null,
                  ),
              ),
              const SizedBox(width: 10),
              Container(decoration: BoxDecoration(
                border: Border.all(color: Colors.teal),
                borderRadius: BorderRadius.circular(4),
              ),child: TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true; // Optional: show loading state while fetching
                    _showAllStations = !_showAllStations;
                  });
                  _loadDropdownData(); // Reload the list with the new filter
                },
                child: Text(
                  _showAllStations ? AppLocalizations.of(context)!.hideinactivestations : AppLocalizations.of(context)!.showhiddenstations,
                  style: const TextStyle(fontSize: 12, color: Colors.teal),
                ),
              ),),
              
              const SizedBox(width: 10),
              Container(decoration: BoxDecoration(
                    
                    border: Border.all(color: Colors.teal) ,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                      icon: const Icon(Icons.format_list_bulleted_add),
                      color: Colors.teal,
                      onPressed: () async {
                        // 1. Navigate to your Car creation form
                        // Replace 'AddCarScreen()' with the actual name of your screen
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StationForm()),
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
            

            TextField(
              controller: _distanceController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.drivendistance, border: OutlineInputBorder(),suffixIcon: Icon(Icons.add_road)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _litersController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.liters, border: OutlineInputBorder(),suffixIcon: Icon(Icons.local_gas_station)),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.price, border: OutlineInputBorder(),suffixIcon: Icon(Icons.euro)),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.dateandtime, border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
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
                    label: Text(_imagePath == null ? AppLocalizations.of(context)!.addphotoscan : AppLocalizations.of(context)!.changephotoscan),
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
                child: Text(isEditing ? AppLocalizations.of(context)!.updatefuelstop : AppLocalizations.of(context)!.savefuelstop),
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
                  child: Text(AppLocalizations.of(context)!.deletefuelstop, style: TextStyle(color: Colors.red)),
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