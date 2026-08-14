import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database/database_helper.dart';
import 'models/station.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'l10n/app_localizations.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StationForm extends StatefulWidget {
  final Station? existingStation; // NEW: Accepts an existing station

  const StationForm({super.key, this.existingStation});

  @override
  State<StationForm> createState() => _StationFormState();
}

class _StationFormState extends State<StationForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isVisible = true; // NEW: Visibility toggle

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
      _contactController.text = widget.existingStation!.contactPerson ?? '';
      _emailController.text = widget.existingStation!.email ?? '';
      _phoneController.text = widget.existingStation!.telephone ?? '';
      _websiteController.text = widget.existingStation!.website ?? '';
      _selectedType = widget.existingStation!.type;
      _infoController.text = widget.existingStation!.additionalInfo ?? '';
      _additionalInfoController.text = widget.existingStation!.additionalInfo ?? '';
      _imagePath = widget.existingStation!.imagePath;
      _isVisible = widget.existingStation!.isVisible == 1; // Assuming isVisible is stored as 1 for true, 0 for false
      _emailController.addListener(_updateUI);
      _phoneController.addListener(_updateUI);
      _websiteController.addListener(_updateUI);
      _locationController.addListener(_updateUI);
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
      await _performTextRecognition(savedImagePath);
    }
  }
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true, // <-- ADD THIS ONE LINE
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
                      HapticFeedback.lightImpact();
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
                      HapticFeedback.lightImpact();
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
                  HapticFeedback.lightImpact();
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
   Future<void> _performTextRecognition(String imagePath) async {
  try {
    // 1. Tell the user we are scanning (optional but good for UX)
    if (mounted) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.scanningimage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
      // ScaffoldMessenger.of(context).showMaterialBanner(
      //   MaterialBanner(
      //     content: Text('Scanning receipt...'), actions: [
      //       TextButton(
      //         onPressed: () {
      //           ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      //         },
      //         child: Text('Dismiss'),
      //       ),
      //     ],
      //     //animation: Duration(seconds: 2),
      //     // behavior: SnackBarBehavior.floating,
      //     // margin: EdgeInsets.only(
      //     //   bottom: MediaQuery.of(context).size.height - 150, // Pushes it to the top
      //     //   left: 15, // Nice padding on the sides
      //     //   right: 15,
          
      //     // ),)
      //   )
      // );
    }

    // 2. Prepare the image for ML Kit
    final inputImage = InputImage.fromFilePath(imagePath);
    
    // 3. Initialize the text recognizer (Latin script covers English, German, etc.)
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    
    // 4. Process the image and extract the text
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String foundName = '';
    String foundContact = '';
    String foundLocation = '';
    String foundEmail = '';
    String foundPhone = '';
    String foundWebsite = '';
    String foundInfo = '';
    // --- REGEX PATTERNS ---
    // Matches standard emails (e.g., info@autohaus.de)
    final emailPattern = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    // Matches German/International phones (e.g., 06021 12345 or +49 170 12345)
    final phonePattern = RegExp(r'(\+49|0)[0-9\s\-\/]{6,}');
    // Matches standard URLs (e.g., www.reifen.simon.com)
    final urlPattern = RegExp(r'(www\.[a-zA-Z0-9\-]+\.[a-zA-Z]{2,})');
    // Matches German Zip + City (e.g., 63808 Haibach)
    final plzCityPattern = RegExp(r'\b\d{5}\s+[a-zA-ZäöüÄÖÜß\s\-]+\b'); 
    // Matches Street Names (e.g., Industriestraße 1 or Musterstr. 12)
    final streetPattern = RegExp(r'[a-zA-ZäöüÄÖÜß]+\s*(str\.|straße|strasse)\s*\d+', caseSensitive: false);

    bool isFirstLine = true;

    // --- THE BRAINS: PARSE LINE BY LINE ---
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final text = line.text;
        final textLower = text.toLowerCase();
        

        // 1. HUNT FOR NAME (Usually the very first line of the receipt/card)
        if (isFirstLine && text.isNotEmpty) {
          foundName = text;
          isFirstLine = false;
        }

        // 2. HUNT FOR EMAIL
        if (emailPattern.hasMatch(text)) {
          foundEmail = emailPattern.firstMatch(text)!.group(0)!;
        }

        // 3. HUNT FOR WEBSITE (Ensure we don't accidentally grab an email)
        else if (!text.contains('@') && (urlPattern.hasMatch(textLower) || textLower.contains('.de') || textLower.contains('.com'))) {
          final match = urlPattern.firstMatch(textLower);
          if (match != null) {
            foundWebsite = match.group(0)!;
          } else if (textLower.startsWith('www.')) {
            foundWebsite = textLower; 
          }
        }

        // 4. HUNT FOR PHONE (Look for keywords or matching regex)
        if (textLower.contains('tel') || textLower.contains('mobil') || textLower.contains('telefon')) {
          final match = phonePattern.firstMatch(text);
          if (match != null) {
            foundPhone = match.group(0)!;
          } else {
            // Fallback: Just strip the word "Tel:" and take the rest of the line
            // NEW WORKING LINE:
            foundPhone = text.replaceAll(RegExp(r'(tel\.?|telefon|mobil):?\s*', caseSensitive: false), '').trim();
          }
        } else if (phonePattern.hasMatch(text) && foundPhone.isEmpty) {
          // Catch phone numbers that don't have "Tel:" in front of them
          foundPhone = phonePattern.firstMatch(text)!.group(0)!;
        }

        // 5. HUNT FOR LOCATION (Combine Street and City if found)
        if (streetPattern.hasMatch(textLower)) {
          foundLocation += (foundLocation.isEmpty ? '' : ', ') + text;
        }
        if (plzCityPattern.hasMatch(text)) {
          foundLocation += (foundLocation.isEmpty ? '' : ', ') + text;
        }

        // --- HUNT FOR CONTACT PERSON ---
        if (textLower.contains('inhaber') || textLower.contains('geschäftsführer') || 
            textLower.contains('inh.') || textLower.contains('contact') || 
            textLower.contains('manager') || textLower.contains('inhaberin')
            || textLower.contains('contact person')|| textLower.contains('ansprechpartner')) {
          foundContact = text.replaceAll(RegExp(r'(inhaber|geschäftsführer|inh\.|contact|manager|inhaberin):?\s*', caseSensitive: false), '').trim();
        }
        // --- HUNT FOR INFO ---
        if (textLower.contains('info') || textLower.contains('bemerkung') || textLower.contains('details')) {
          foundInfo = text.replaceAll(RegExp(r'(info|bemerkung|details):?\s*', caseSensitive: false), '').trim();
        }
      }
    }

    // --- INJECT TO CONTROLLERS ---
    setState(() {
      if (foundName.isNotEmpty) _nameController.text = foundName;
      if (foundLocation.isNotEmpty) _locationController.text = foundLocation;
      if (foundEmail.isNotEmpty) _emailController.text = foundEmail;
      if (foundPhone.isNotEmpty) _phoneController.text = foundPhone;
      if (foundWebsite.isNotEmpty) _websiteController.text = foundWebsite;
      if (foundContact.isNotEmpty) _contactController.text = foundContact;
      if (foundInfo.isNotEmpty) _infoController.text = foundInfo;
    });
    
    // 5. Close the recognizer to save memory
    textRecognizer.close();

    // TEMPORARY: Print the massive block of text to your VS Code terminal so we can see what it found!
    print("------- SCANNED RECEIPT TEXT -------");
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
  Future<void> _launchEmail(String emailAddress) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: emailAddress,
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    // Optional: Show a snackbar if the user has no email app installed
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app')),
      );
    }
  }
}
Future<void> _launchPhone(String phoneNumber) async {
  // Removes spaces or dashes if the user input them
  final String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
  final Uri phoneUri = Uri(
    scheme: 'tel',
    path: cleanedNumber,
  );

  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open phone app')),
      );
    }
  }
}

Future<void> _launchWebsite(String websiteUrl) async {
  // Ensure the URL has a scheme (https://)
  String urlToLaunch = websiteUrl.trim();
  if (!urlToLaunch.startsWith('http')) {
    urlToLaunch = 'https://$urlToLaunch';
  }

  final Uri websiteUri = Uri.parse(urlToLaunch);

  if (await canLaunchUrl(websiteUri)) {
    await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open website')),
      );
    }
  }
}
Future<void> _launchMaps(String location) async {
  // Encode the location so it works even if it contains spaces or special characters
  final String encodedLocation = Uri.encodeComponent(location);
  final Uri mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedLocation');

  if (await canLaunchUrl(mapUri)) {
    await launchUrl(mapUri, mode: LaunchMode.externalApplication);
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }
}
void _updateUI() {
  setState(() {}); 
}

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _infoController.dispose();
    _contactController.removeListener(_updateUI);
    _emailController.removeListener(_updateUI);
    _phoneController.removeListener(_updateUI);
    _websiteController.removeListener(_updateUI);
    _locationController.removeListener(_updateUI);
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
      contactPerson: _contactController.text,
      email: _emailController.text,
      telephone: _phoneController.text,
      website: _websiteController.text,
      location: _locationController.text,
      type: _selectedType,
      imagePath: _imagePath,
      additionalInfo: _infoController.text,
      isVisible: _isVisible ? 1 : 0, // NEW: Include visibility in the data
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
            const SizedBox(height: 20), // A little spacing
            // NEW: The Visibility Switch
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.showindropdowns), // You can replace with AppLocalizations if you want!
              subtitle: Text(AppLocalizations.of(context)!.keepstationvisible), // Optional: A brief description
              value: _isVisible,
              activeThumbColor: Colors.teal,
              onChanged: (bool value) {
                setState(() {
                  _isVisible = value;
                });
                HapticFeedback.lightImpact(); // Optional: A nice touch if you are using haptics
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                isEditing ? AppLocalizations.of(context)!.editstation : AppLocalizations.of(context)!.addGasStation, 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.stationname, border: OutlineInputBorder(),suffixIcon: Icon(Icons.business)),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.location, border: OutlineInputBorder(),),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 10), // Spacing
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _locationController.text.isNotEmpty ? Colors.teal : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.map_sharp,
                      color: _locationController.text.isNotEmpty ? Colors.teal : Colors.grey,
                    ),
                    onPressed: _locationController.text.isNotEmpty 
                      ? () => _launchMaps(_locationController.text) 
                      : null, // Disables button if empty
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.type, border: OutlineInputBorder(),suffixIcon: Icon(Icons.category)),
              initialValue: _selectedType,
              items: _typeOptions.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedType = newValue),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.contactperson, border: OutlineInputBorder(),suffixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.emailaddress, border: OutlineInputBorder(),),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 10), // Spacing
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _emailController.text.isNotEmpty ? Colors.teal : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.email,
                      color: _emailController.text.isNotEmpty ? Colors.teal : Colors.grey,
                    ),
                    onPressed: _emailController.text.isNotEmpty 
                      ? () => _launchEmail(_emailController.text) 
                      : null, // Disables button if empty
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.telephonenumber, border: OutlineInputBorder(),),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 10), // Spacing
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _phoneController.text.isNotEmpty ? Colors.teal : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.phone,
                      color: _phoneController.text.isNotEmpty ? Colors.teal : Colors.grey,
                    ),
                    onPressed: _phoneController.text.isNotEmpty 
                      ? () => _launchPhone(_phoneController.text) 
                      : null, // Disables button if empty
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _websiteController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.website, border: OutlineInputBorder(),),
                    keyboardType: TextInputType.url,
                  ),
                ),
                const SizedBox(width: 10), // Spacing
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _websiteController.text.isNotEmpty ? Colors.teal : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.web,
                      color: _websiteController.text.isNotEmpty ? Colors.teal : Colors.grey,
                    ),
                    onPressed: _websiteController.text.isNotEmpty 
                      ? () => _launchWebsite(_websiteController.text) 
                      : null, // Disables button if empty
                  ),
                ),
              ],
            ),

            
            const SizedBox(height: 10),

            TextField(
              controller: _infoController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.additionalinfo, border: OutlineInputBorder()),
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
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Trigger a satisfying physical tap sensation
                  HapticFeedback.mediumImpact(); 
                  
                  // Then execute your save logic
                  _saveStation(); 
                  Fluttertoast.showToast(
                    msg: isEditing ? AppLocalizations.of(context)!.stationupdated : AppLocalizations.of(context)!.stationadded,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                },
                child: Text(isEditing ? AppLocalizations.of(context)!.updatestation : AppLocalizations.of(context)!.savestation),
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
                        title: Text(AppLocalizations.of(context)!.deletestation),
                        content: Text(AppLocalizations.of(context)!.deletestationtext),
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
                      await DatabaseHelper.instance.deleteStation(widget.existingStation!.id!);
                      if (mounted) {
                        Navigator.pop(context, true);
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.stationdeleted,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                        ); // Close form and trigger refresh
                      }
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.deletestation, style: TextStyle(color: Colors.red)),
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