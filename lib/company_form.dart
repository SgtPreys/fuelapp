import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/company.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyForm extends StatefulWidget {
  final Company? existingCompany; // NEW: Accepts an existing company

  const CompanyForm({super.key, this.existingCompany});

  @override
  State<CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isVisible = true; // NEW: Visibility toggle

  @override
  void initState() {
    super.initState();
    // NEW: Pre-fill data if editing
    if (widget.existingCompany != null) {
      _nameController.text = widget.existingCompany!.name;
      _locationController.text = widget.existingCompany!.location ?? '';
      _contactController.text = widget.existingCompany!.contactPerson ?? '';
      _emailController.text = widget.existingCompany!.email ?? '';
      _phoneController.text = widget.existingCompany!.telephone ?? '';
      _websiteController.text = widget.existingCompany!.website ?? '';
      _infoController.text = widget.existingCompany!.additionalInfo ?? '';
      _imagePath = widget.existingCompany!.imagePath;
      _isVisible = widget.existingCompany!.isVisible == 1;
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
    _emailController.removeListener(_updateUI);
    _phoneController.removeListener(_updateUI);
    _websiteController.removeListener(_updateUI);
    _locationController.removeListener(_updateUI);
    super.dispose();
  }

  Future<void> _saveCompany() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseentercompany)),
      );
      return;
    }

    final companyData = Company(
      id: widget.existingCompany?.id, // Keep ID if editing
      name: _nameController.text,
      location: _locationController.text,
      contactPerson: _contactController.text,
      email: _emailController.text,
      telephone: _phoneController.text,
      website: _websiteController.text,
      additionalInfo: _infoController.text,
      isVisible: _isVisible ? 1 : 0, // NEW: Use the visibility toggle
    );

    if (widget.existingCompany == null) {
      await DatabaseHelper.instance.insertCompany(companyData.toMap());
    } else {
      await DatabaseHelper.instance.updateCompany(companyData.toMap());
    }

    if (mounted) {
      Navigator.pop(context, true); // Pass 'true' back to trigger refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCompany != null;

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
            const SizedBox(height: 20), // A little spacing
            // NEW: The Visibility Switch
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.showindropdowns), // You can replace with AppLocalizations if you want!
              subtitle: Text(AppLocalizations.of(context)!.keepscompanyvisible), // Optional: A brief description
              value: _isVisible,
              activeThumbColor: Colors.purple,
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
                isEditing ? AppLocalizations.of(context)!.editcompany : AppLocalizations.of(context)!.addCompany, 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.companyname, border: OutlineInputBorder(),suffixIcon: Icon(Icons.business)),
            ),
            const SizedBox(height: 10),

             Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.location, border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 10), // Spacing
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _locationController.text.isNotEmpty ? Colors.purple : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.map_sharp,
                      color: _locationController.text.isNotEmpty ? Colors.purple : Colors.grey,
                    ),
                    onPressed: _locationController.text.isNotEmpty 
                      ? () => _launchMaps(_locationController.text) 
                      : null, // Disables button if empty
                  ),
                ),
              ],
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
                      color: _emailController.text.isNotEmpty ? Colors.purple : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.email,
                      color: _emailController.text.isNotEmpty ? Colors.purple : Colors.grey,
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
                      color: _phoneController.text.isNotEmpty ? Colors.purple : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.phone,
                      color: _phoneController.text.isNotEmpty ? Colors.purple : Colors.grey,
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
                      color: _websiteController.text.isNotEmpty ? Colors.purple : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.web,
                      color: _websiteController.text.isNotEmpty ? Colors.purple : Colors.grey,
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
                  _saveCompany(); 
                },
                child: Text(isEditing ? AppLocalizations.of(context)!.updatecompany : AppLocalizations.of(context)!.savecompany),
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
                        title: Text(AppLocalizations.of(context)!.deletecompany),
                        content: Text(AppLocalizations.of(context)!.deletecompanytext),
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
                      await DatabaseHelper.instance.deleteCompany(widget.existingCompany!.id!);
                      if (mounted) {
                        Navigator.pop(context, true); // Close form and trigger refresh
                      }
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.deletecompany, style: TextStyle(color: Colors.red)),
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