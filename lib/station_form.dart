import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/station.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class StationForm extends StatefulWidget {
  final Station? existingStation; // NEW: Accepts an existing station

  const StationForm({super.key, this.existingStation});

  @override
  State<StationForm> createState() => _StationFormState();
}

class _StationFormState extends State<StationForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  final List<String> _typeOptions = [
    'Standard / City', 
    'Highway / Autobahn', 
    'Supermarket', 
    'Unmanned / Automatic',
    'Other'
  ];

  String? _selectedType;

  @override
  void initState() {
    super.initState();
    // NEW: Pre-fill data if editing
    if (widget.existingStation != null) {
      _nameController.text = widget.existingStation!.name;
      _locationController.text = widget.existingStation!.location ?? '';
      _selectedType = widget.existingStation!.type;
      _infoController.text = widget.existingStation!.additionalInfo ?? '';
      _additionalInfoController.text = widget.existingStation!.additionalInfo ?? '';
      _imagePath = widget.existingStation!.imagePath;
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
    _locationController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _saveStation() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Station Name!')),
      );
      return;
    }

    final stationData = Station(
      id: widget.existingStation?.id, // Keep ID if editing
      name: _nameController.text,
      location: _locationController.text,
      type: _selectedType,
      additionalInfo: _infoController.text,
    );

    if (widget.existingStation == null) {
      await DatabaseHelper.instance.insertStation(stationData.toMap());
    } else {
      await DatabaseHelper.instance.updateStation(stationData.toMap());
    }

    if (mounted) {
      Navigator.pop(context, true); // Pass 'true' back to trigger refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingStation != null;

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
                isEditing ? 'Edit Gas Station' : 'Add Gas Station', 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name (e.g. Shell, Aral)*', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location / City', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              initialValue: _selectedType,
              items: _typeOptions.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedType = newValue),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _infoController,
              decoration: const InputDecoration(labelText: 'Additional Information / Notes', border: OutlineInputBorder()),
              maxLines: 3,
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

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Trigger a satisfying physical tap sensation
                  HapticFeedback.mediumImpact(); 
                  
                  // Then execute your save logic
                  _saveStation(); 
                },
                child: Text(isEditing ? 'Update Gas Station' : 'Save Gas Station'),
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
                        title: const Text('Delete Gas Station'),
                        content: const Text('Are you sure you want to delete this gas station? This action cannot be undone. In doing so you also delete all related data (fuel, maintenance, etc.)!'),
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
                      await DatabaseHelper.instance.deleteStation(widget.existingStation!.id!);
                      if (mounted) {
                        Navigator.pop(context, true); // Close form and trigger refresh
                      }
                    }
                  },
                  child: const Text('Delete Gas Station', style: TextStyle(color: Colors.red)),
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